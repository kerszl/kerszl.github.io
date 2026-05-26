---
title: "LA CTF 2025 - rev/elfisyou"
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
  - LA
header:
  overlay_image: /assets/images/pasek-hack.png
---
# reverse/elfisyou
{: .text-justify}

## 00. Metainfo

|:----|:----|
|CTF:|[LA CTF 2025](https://lac.tf/)|
|Category:|Reverse|
|CTFtime|[CTFtime](https://ctftime.org/event/2592)|


# 01. Wstęp

![Description](/assets/images/hacking/2025/03/01.png)

Od razu wspomnę, że ta solucja jest również dostępna w języku angielskim na [tej stronie](http://mindcrafters.xyz/writeups/elfisyou).
{: .text-justify}
Zgodnie z opisem, **ELF** to gra polegająca na przesuwaniu klocków w celu zbudowania działającego programu. Na początku dostajemy wyjaśnienie, co należy zrobić, więc wydaje się, że nie powinno być trudno... Ale jest – i to bardzo.
{: .text-justify}
Pamiętacie kultową grę **`Baba Is You`**? To były czasy, gdy siedziało się przed ekranem, nie mając pojęcia, co zrobić, a rozwiązanie okazywało się zupełnie nieszablonowe – jak np. przesunięcie całego płotu. W nawiązaniu do tej gry pojawiło się świetne zadanie **`reverse`** z turnieju [CTF](https://lac.tf/). Nie, to nie jest *Baba Is You* – to jest **elfisyou**. Można się domyślać, że chodzi o plik w formacie **ELF**.
{: .text-justify}
Do pobrania mamy program w Pythonie, plik Dockera do uruchomienia lokalnie oraz uszkodzoną binarkę, którą możemy testować offline. Jednak głównym celem jest połączenie się online i odpowiednie ułożenie bajtów. Zadanie rozwiązało 14 drużyn, w tym moja – **[MindCrafters](http://mindcrafters.xyz/)** – jako ostatnia.
{: .text-justify}
![Description](/assets/images/hacking/2025/03/02.png)

{: .text-justify}
## Ale o co chodzi?
Łączac się na adres:
```bash
socat file:$(tty),raw,echo=0 tcp:chall.lac.tf:31189
```
Widzimy obrazek:
{: .text-justify}
![elf](/assets/images/hacking/2025/03/03.png)
{: .text-justify}
Na którym znajduje się pole o rozmiarach 13x13. To jest bardzo ważne, o czym później się przekonamy. W prawym górnym rogu znajduje się zielony kwadrat, którym możemy poruszać się po planszy i przesuwać inne bajty. Można również przesunąć kilka bajtów jednocześnie.
{: .text-justify}
Poruszamy się klawiszami `wsad`. Przesunąłem kilka bajtów, ale gdy okazało się, że trzeba wykonać wiele przesunięć, łatwo było o pomyłkę. Wtedy użyłem do tego biblioteki `PWN tools` w Pythonie. Ku mojemu zaskoczeniu działała dobrze, choć samo łączenie i przesuwanie trwało dość długo. Jednak po wyłączeniu p.clean() oraz pause działało płynnie – i to online! Byłem w szoku, bo na mało którym `CTF-ie` spotkałem tak świetną infrastrukturę. 
{: .text-justify}

## Struktura
Dobra, trzeba w końcu rozgryźć te bajty. Co właściwie widzimy? Na szczęście większość to zera, trochę tekstu. Wiemy, że musi być magiczny nagłówek ELF, a także pojawia się literka `f` z `flag.txt`. To już pewne ułatwienie.
{: .text-justify}

### Payload
Strukturą ELF-a zajmiemy się później. Najpierw trzeba ustalić, jaki to dokładnie `payload`. Program zazwyczaj znajduje się na końcu pliku, więc warto było tam zajrzeć i poszukać jakichś mnemoników. Jednak zamiast tego zacząłem od napisania programu w asemblerze, który otwiera plik, wczytuje go i wypisuje na ekran.
{: .text-justify}
Trzeba było ustalić, jaka to była wersja i czy przypadkiem nie chodziło o architekturę ARM (to już byłoby przegięcie). Patrząc na syscall-e, można było zauważyć, że to x86-64. Syscall-e `open`, `read`, `write` wymagają trzech argumentów, a tutaj były tylko dwie pary (`0F 05`). To sugerowało, że użyto sztuczki z `sendfile` (`ax=0x28`), czyli plik był otwierany i od razu wysyłany na ekran.
{: .text-justify}
Autor nie był aż takim sadystą i nie kombinował z zaciemnianiem kodu, więc kod był standardowy. Jednak popełniłem jeden błąd w kolejności instrukcji – przesuwanie nie działało, więc musiałem zmienić ich układ, ale nie było to dużym problemem. Kolejną przeszkodą był sam NASM. Payload miał wyglądać tak.
{: .text-justify}

```asm
section .text
    global _start

_start:

push   0                          ; Push 0 onto the stack (null terminator for the filename string)
mov    rax,0x7478742e67616c66    ; Move the string 'flag.txt' (reversed due to little-endian format) into RAX
push   rax                        ; Push the filename onto the stack
mov    eax,0x2                    ; Set EAX to 2 (sys_open syscall number)
mov    rdi,rsp                    ; Set RDI to point to the filename on the stack
syscall                           ; Call sys_open (open file "flag.txt")

mov    rax,0x28                   ; Set RAX to 40 (sys_sendfile syscall number)
mov    edi,0x1                    ; Set EDI to 1 (stdout file descriptor)
mov    esi,0x3                    ; Set ESI to 3 (assumed file descriptor returned from sys_open)
mov    r10,0x100                  ; Set R10 to 256 (number of bytes to transfer)
syscall                           ; Call sys_sendfile to send file content to stdout
```
Wersja z mnemonikami:
{: .text-justify}
```asm
;    1000:       6a 00                   push   0x0
;    1002:       48 b8 66 6c 61 67 2e    movabs rax,0x7478742e67616c66
;    1009:       74 78 74 
;    100c:       50                      push   rax
;    100d:       b8 02 00 00 00          mov    eax,0x2
;    1012:       48 89 e7                mov    rdi,rsp
;    1015:       0f 05                   syscall
;    1017:       48 c7 c0 28 00 00 00    mov    rax,0x28
;    101e:       bf 01 00 00 00          mov    edi,0x1
;    1023:       be 03 00 00 00          mov    esi,0x3
;    1028:       49 c7 c2 00 01 00 00    mov    r10,0x100
;    102f:       0f 05                   syscall
```
Niestety po kompilacji:
{: .text-justify}
```bash
nasm -f elf64 -o payload.o payload.asm
ld -shared -o payload.so payload.o
```
Tak to wygląda:
```bash
objdump -d -M intel payload
```
```asm
  401000:       6a 00                   push   0x0
  401002:       48 b8 66 6c 61 67 2e    movabs rax,0x7478742e67616c66
  401009:       74 78 74 
  40100c:       50                      push   rax
  40100d:       b8 02 00 00 00          mov    eax,0x2
  401012:       48 89 e7                mov    rdi,rsp
  401015:       0f 05                   syscall
  401017:       b8 28 00 00 00          mov    eax,0x28
  40101c:       bf 01 00 00 00          mov    edi,0x1
  401021:       be 03 00 00 00          mov    esi,0x3
  401026:       41 ba 00 01 00 00       mov    r10d,0x100
  40102c:       0f 05                   syscall
```

`Nasm` zamienił `mov r10,0x100` na `mov r10d,0x100`. W rezultacie zmieniły się mnemoniki. Zamiast `49 c7 c2 00 01 00 00` pojawiło się `41 ba 00 01 00 00`. Ponieważ było to kilka instrukcji i mnemoników, przepisałem je jako `db`.
{: .text-justify}
```asm
section .data
    
section .text
    global _start

_start:
db 0x6a ,0x00               ; push 0
db 0x48 ,0xB8 ,0x66 ,0x6C ,0x61 ,0x67 ,0x2E ,0x74 ,0x78 ,0x74 ;mov rax, 0x7478742E67616C66 ; flag.txt
db 0x50                     ;push rax    
db 0xb8, 0x2,0x00,0x00,0x00 ; mov rax, 2              
db 0x48, 0x89 ,0xe7         ;mov rdi, rsp
db 0x0f, 0x05               ; syscall                   


db 0x48, 0xc7, 0xc0, 0x28,0x00,0x00,0x00  ; mov rax, 0x28
db 0xbf, 0x01, 0x00,0x00,0x00             ; mov rdi, 1 
db 0xbe, 0x03, 0x00, 0x00, 0x00           ; mov si, 03 
db 0x49, 0xc7, 0xc2,0x00,0x01,0x00,0x00   ; mov r10, 10
db 0x0f, 0x05                             ; syscall                    
```

Poźniej to sobie rozbiłem na 4 dolne linie po 13 bajtów i już miałem ułożony `payload` w dole binarki.
{: .text-justify}
```plaintext
00 00 00 6a 00 48 B8 66 6C 61 67 2E 74
78 74 50 b8 02 00 00 00 48 89 e7 0f 05
48 c7 c0 28 00 00 00 bf 01 00 00 00 be
03 00 00 00 49 c7 c2 00 01 00 00 0f 05
``` 
### ELF
`Payload` mamy, czas na `ELF`. Powiem szczerze, nie znam go aż tak dokładnie, ale od czego jest [Wikipedia](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)? Tam ten format jest dokładnie opisany. 
{: .text-justify}
Podczas wcześniejszego przeglądania i dopasowywania bajtów zauważyłem, że wg mnie kilka cyfr się nie zgadzało. Nie wiedziałem, do czego służy `03`. Okazało się, że w pewnym miejscu oznacza `Shared object`, co miało sens. Do tego doszły jeszcze offsety `0x64`, wielkość nagłówka `0x56` i dużo innych ciekawych bajtów`. 
{: .text-justify}
Spędziłem nad tym kilka dobrych godzin. Szczerze mówiąc, `010 Editor` ma świetną opcję do analizy nagłówków różnych formatów plików. Nie ukrywam, że dłubałem przy tym naprawdę długo, zanim udało mi się poprawnie złożyć i uruchomi cały plik (oczywiście offline). 
{: .text-justify}
Miałem sporo problemów, zwłaszcza z `program table element`—skasowałem za dużo bajtów, źle ustawiłem wartości itd. W końcu program się uruchomił, ale do zakończenia CTF-a została tylko godzina, a jeszcze trzeba było wszystko dopracować. Na szczęście `payload` był już gotowy, pozostawało jedynie dokończyć nagłówek `ELF`—i to nie w całości.

![010 editor](/assets/images/hacking/2025/03/04.png)
## Rozwiązanie
Rozwiązanie w kodzie wydaję się proste. Idziesz 5 razy do dołu, potem w lewo itd. Musiałem przebyć długą drogę, żeby to rozwiązać. Zastanawiam się czy Chatgpt by mi to napisał. Wolałem nie próbować, bo mógł więcej w tym wypadku namącić niż pomóc. Oto kod źródłowy, który pozwolił wydobyć mi szybko flagę:
{: .text-justify}

```python
from pwn import *             

HOST="chall.lac.tf:31189"
ADDRESS,PORT=HOST.split(":")

p = remote(ADDRESS,PORT)

wait=0.00
def down(count):    
    for i in range(count):
        #p.clean()
        p.sendline(b"s")
        sleep(wait)

def left(count):    
    for i in range(count):
        #p.clean()
        p.sendline(b"a")
        sleep(wait)

def right(count):    
    for i in range(count):
        #p.clean()
        p.sendline(b"d")
        sleep(wait)

def up(count):    
    for i in range(count):
        #p.clean()
        p.sendline(b"w")
        sleep(wait)

down(5)
left(1)
down(2)
right(1)
down(3)
left(1)
down(1)
left(1)
down(1)
left(1)
up(2)
right(2)
left(1)
up(5)
right(2)
down(2)
left(1)
down(2)
up(2)
right(1)
down(1)
left(4)
down(1)
left(1)
down(1)
right(2)
down(1)
right(1)
up(1)
left(4)
down(1)
left(2)
up(1)
right(6)
up(2)
left(1)
up(1)
left(4)
down(2)
left(2)
down(1)
right(5)
left(3)
up(3)
left(2)
up(2)
left(2)
down(4)
up(2)
right(1)
down(2)
up(2)
right(1)
down(2)
up(2)
right(5)
down(1)
right(1)
down(1)
left(3)
right(1)
up(2)
left(3)
down(1)
right(1)
down(1)
right(5)
up(1)
right(2)
down(1)
left(4)
up(1)
left(2)
down(2)
right(1)
up(1)
left(3)
up(1)
left(2)
down(1)
right(10)
up(4)
right(2)
up(2)
left(1)
down(4)
right(1)
down(1)
left(1)
up(1)
left(1)
down(1)
up(3)
left(1)
up(2)
left(1)
up(1)
left(1)
down(6)
left(1)
up(1)
left(1)
down(1)
up(1)
left(1)
down(1)
left(1)
right(3)
down(1)
right(2)
up(1)
right(4)
up(8)
left(4)
down(3)
right(1)
down(1)
left(1)
up(1)
left(1)
down(5)
right(5)
up(8)
left(1)
down(7)
right(1)
down(1)
left(3)
up(1)
left(1)
down(1)
left(5)
down(1)
right(1)
left(2)
up(5)
right(1)
down(4)
right(5)
up(2)
right(2)
down(1)
right(1)
up(6)
right(1)
up(1)
left(4)
down(3)
right(1)
up(2)
right(1)
up(1)
left(7)
right(6)
down(7)
left(5)
up(2)
right(1)
up(1)
left(1)
up(1)
left(1)
down(1)
right(1)
down(1)
left(3)
right(2)
down(2)
left(3)
up(6)
down(3)
right(2)
down(1)
right(2)
up(2)
left(1)
down(3)
left(1)
down(1)
right(8)
down(1)
right(1)
up(7)
right(1)
up(1)
left(8)
right(4)
down(2)
left(1)
up(1)
right(1)
up(1)
left(1)
down(5)
left(2)
up(5)
down(2)
left(1)
p.clean()
up(2)
down(1)
left(2)
up(1)
right(5)
up(1)
right(1)
down(1)
left(6)
down(1)
left(2)
up(1)
right(9)
down(2)
left(1)
up(1)
right(1)
up(1)
left(5)
right(5)
up(1)
right(2)
down(1)
left(5)
right(1)
down(4)
left(2)
up(1)
right(1)
down(1)
right(1)
up(3)
down(1)
right(3)
up(1)
left(1)
up(1)
right(1)
down(2)
left(7)
up(1)
left(1)
down(1)
right(7)
down(1)
right(2)
down(3)
left(6)
up(2)
right(1)
up(1)
left(1)
right(4)
down(1)
left(5)
right(2)
down(1)
left(4)
up(1)
left(1)
down(2)
p.sendline(b'x')
p.interactive()

```
## Podsumowanie
Flagę udało się wbić 8-10 minut przed końcem CTF, chociaż miałem wątpliwości czy zdążę. To było świetne zadanie. Nauczyłem się dużo o strukturze `ELF`, poukładałem `payloada`, pobawiłem się w tę grę i zdobyłem flagę. Te 20-30 godzin nie było zmarnowane ;)
{: .text-justify}
![final](/assets/images/hacking/2025/03/05.png)

Flaga:
`lactf{1m_r3ally_s0rry_1f_th1s_w4s_annoy1ng}`
