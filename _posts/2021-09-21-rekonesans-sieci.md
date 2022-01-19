---
title: "[01] Rekonesans sieci"
excerpt: " "
comments: true
categories:
  - Hacking
  - Tools
tags:
  - Hacking
  - Tools
  - Vulnhub
  - nmap
  - nping
  - netdiscover
  - masscan
  - fping  
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Wstęp
Od jakiegoś czasu zacząłem opisywać solucje maszyn z serwisu [Vulnhub](https://www.vulnhub.com/). Pewnie też zahaczę o serwis [hackmyvm](https://hackmyvm.eu/), bo jest tam parę ciekawych wirtualek, ale bardzo słabo, a wręcz zdawkowo opisywałem narzędzia, które są pomocne do ich przejścia. Bez nich raczej ciężko sobie poradzić. Będę opisywał (wg mnie) najciekawsze programy, ale też i przydatne skrypty, sposoby pomagające w przejściu naszej VM.
{: .text-justify}
# Zaczynamy
## Nmap
### Z czym to się skanuje?
[Nmap](https://nmap.org) jest chyba najstarszym skanerem sieciowym jakiego znam (nie licząc programu **Ping** - ale czy go można zaliczyć do skanerów sieci?). Komendy się wydaje stosując linię komend, co dla niektórych może nie być wygodne, ale na szczęście dla tych osób, są nakładki graficzne, które pomagają się odnaleźć w gąszczu komend. Pierwsza wersja **Nmap**a pochodzi z 1997 roku, czyli aż z XX wieku. :smiley: Program jest ciągle rozwijany i na obecną chwilę chyba nie ma sobie równych. Jest dostępny na wszystkie ważniejsze platformy. To co mi się w nim podoba, oprócz multum funkcji, to wygodne podawanie zakresu sieci w hostach.
{: .text-justify}
### Przykłady
Człowiek się uczy na przykładach, więc podam parę przykładów:
{: .text-justify}
<div class="notice--primary" markdown="1">
Szybkie skanowanie sieci:
```bash
nmap -n -sn 172.16.1.100-200
```
```console
Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-21 18:06 CEST
Nmap scan report for 172.16.1.108
Host is up (0.00089s latency).
MAC Address: 92:25:CA:13:80:8A (Unknown)
Nmap scan report for 172.16.1.135
Host is up (0.00090s latency).
MAC Address: 00:17:9A:25:46:BF (D-Link)
Nmap scan report for 172.16.1.194
Host is up (0.00048s latency).
MAC Address: B6:B6:42:48:B5:89 (Unknown)
Nmap done: 101 IP addresses (3 hosts up) scanned in 1.83 seconds
```
</div>
Wygląda to nie do końca czytelnie, więc możemy trochę upiększyć nasz wynik, dodając skrypt na koniec:
{: .text-justify}
<div class="notice--primary" markdown="1">
```bash
nmap -n -sn 172.16.1.100-200 | awk '{if ($1~/Nmap/) printf ($5" "); if ($1~/MAC/) print $3} END{print}' 
```
```console
172.16.1.108 92:25:CA:13:80:8A
172.16.1.135 00:17:9A:25:46:BF
172.16.1.194 B6:B6:42:48:B5:89
```
</div>
Jeżeli już wyczailiśmy swoją podatną maszynę z obrazu do testów, zazwyczaj się używa komendy:
{: .text-justify}
<div class="notice--primary" markdown="1">
Pełne skanowanie
```bash
nmap -T5 -A -p- 172.16.1.108
```
```console
Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-21 18:21 CEST
Nmap scan report for hundred.lan (172.16.1.108)
Host is up (0.00040s latency).
Not shown: 65532 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| -rwxrwxrwx    1 0        0             435 Aug 02 06:19 id_rsa [NSE: writeable]
| -rwxrwxrwx    1 1000     1000         1679 Aug 02 06:11 id_rsa.pem [NSE: writeable]
| -rwxrwxrwx    1 1000     1000          451 Aug 02 06:11 id_rsa.pub [NSE: writeable]
|_-rwxrwxrwx    1 0        0             187 Aug 02 06:27 users.txt [NSE: writeable]
| ftp-syst:
|   STAT:
| FTP server status:
|      Connected to ::ffff:172.16.1.10
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 2
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey:
|   2048 ef:28:1f:2a:1a:56:49:9d:77:88:4f:c4:74:56:0f:5c (RSA)
|   256 1d:8d:a0:2e:e9:a3:2d:a1:4d:ec:07:41:75:ce:47:0e (ECDSA)
|_  256 06:80:3b:fc:c5:f7:7d:c5:58:26:83:c4:f7:7e:a3:d9 (ED25519)
80/tcp open  http    nginx 1.14.2
|_http-server-header: nginx/1.14.2
|_http-title: Site doesn't have a title (text/html).
MAC Address: 92:25:CA:13:80:8A (Unknown)
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.6
Network Distance: 1 hop
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
```
</div>
### Metasploit
Tak, możemy też użyć **Nmap**a w Metasploicie. Parametry są takie same jak w "zwykłym" programie.
{: .text-justify}
#### Przykład użycia
<div class="notice--primary" markdown="1">
```console
msf6 > workspace -a hundred
[*] Added workspace: hundred
[*] Workspace: hundred
msf6 > db_nmap -T5 -A -p- 172.16.1.108
[*] Nmap: Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-21 20:42 CEST
[*] Nmap: Nmap scan report for hundred.lan (172.16.1.108)
[*] Nmap: Host is up (0.00039s latency).
[*] Nmap: Not shown: 65532 closed ports
[*] Nmap: PORT   STATE SERVICE VERSION
[*] Nmap: 21/tcp open  ftp     vsftpd 3.0.3
[*] Nmap: | ftp-anon: Anonymous FTP login allowed (FTP code 230)
[*] Nmap: | -rwxrwxrwx    1 0        0             435 Aug 02 06:19 id_rsa [NSE: writeable]
[*] Nmap: | -rwxrwxrwx    1 1000     1000         1679 Aug 02 06:11 id_rsa.pem [NSE: writeable]
[*] Nmap: | -rwxrwxrwx    1 1000     1000          451 Aug 02 06:11 id_rsa.pub [NSE: writeable]
[*] Nmap: |_-rwxrwxrwx    1 0        0             187 Aug 02 06:27 users.txt [NSE: writeable]
[*] Nmap: | ftp-syst:
[*] Nmap: |   STAT:
[*] Nmap: | FTP server status:
[*] Nmap: |      Connected to ::ffff:172.16.1.10
[*] Nmap: |      Logged in as ftp
[*] Nmap: |      TYPE: ASCII
[*] Nmap: |      No session bandwidth limit
[*] Nmap: |      Session timeout in seconds is 300
[*] Nmap: |      Control connection is plain text
[*] Nmap: |      Data connections will be plain text
[*] Nmap: |      At session startup, client count was 2
[*] Nmap: |      vsFTPd 3.0.3 - secure, fast, stable
[*] Nmap: |_End of status
[*] Nmap: 22/tcp open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
[*] Nmap: | ssh-hostkey:
[*] Nmap: |   2048 ef:28:1f:2a:1a:56:49:9d:77:88:4f:c4:74:56:0f:5c (RSA)
[*] Nmap: |   256 1d:8d:a0:2e:e9:a3:2d:a1:4d:ec:07:41:75:ce:47:0e (ECDSA)
[*] Nmap: |_  256 06:80:3b:fc:c5:f7:7d:c5:58:26:83:c4:f7:7e:a3:d9 (ED25519)
[*] Nmap: 80/tcp open  http    nginx 1.14.2
[*] Nmap: |_http-server-header: nginx/1.14.2
[*] Nmap: |_http-title: Site doesn't have a title (text/html).
[*] Nmap: MAC Address: 92:25:CA:13:80:8A (Unknown)
[*] Nmap: Device type: general purpose
[*] Nmap: Running: Linux 4.X|5.X
[*] Nmap: OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
[*] Nmap: OS details: Linux 4.15 - 5.6
[*] Nmap: Network Distance: 1 hop
[*] Nmap: Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
[*] Nmap: TRACEROUTE
[*] Nmap: HOP RTT     ADDRESS
[*] Nmap: 1   0.39 ms hundred.lan (172.16.1.108)
[*] Nmap: OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 9.98 seconds
msf6 >
```
</div>
Parametry programu:
{: .text-justify}
- -A - tak jakby skanowanie pełne, skanuje najpotrzebniejsze dla nas rzeczy
- -p- skanuje wszystkie porty (ważne żeby podać, bo czasami są zmyłki)
- -T5 - czym wyższa cyfra, tym skanowanie jest szybsze

## Nping
Jest jakby "uboższym" bratem **Nmap**a. Można go ściągnąć [stąd](https://nmap.org/nping/). Służy głównie do pingowania sieci z naciskiem na protokoły ICMP, ARP, TCP itd. Używam go głównie w zastępstwie starego **Arping**a do szybkiego skanowania po **MAC**ach. Tak samo jak **Nmap** ma wygodny format zapisu hostów do skanowania.
{: .text-justify}
### Parę przykładów
<div class="notice--primary" markdown="1">
```bash
nping -c 1 --arp-type ARP 172.16.1.108-109
```
```console
Starting Nping 0.7.91 ( https://nmap.org/nping ) at 2021-09-21 16:16 CEST
SENT (0.9052s) ARP who has 172.16.1.108? Tell 172.16.1.10
RCVD (0.9060s) ARP reply 172.16.1.108 is at 92:25:CA:13:80:8A
SENT (1.9062s) ARP who has 172.16.1.109? Tell 172.16.1.10
```console
</div>
<div class="notice--primary" markdown="1">
```bash
nping -H 172.16.1.100-110
```
```console
Starting Nping 0.7.91 ( https://nmap.org/nping ) at 2021-09-21 16:37 CEST
RCVD (8.0513s) ICMP [172.16.1.108 > 172.16.1.10 Echo reply (type=0/code=0) id=31782 seq=1] IP [ttl=64 id=41652 iplen=28 ]

nping -c1 -H --arp 172.16.1.108-109

Starting Nping 0.7.91 ( https://nmap.org/nping ) at 2021-09-21 16:43 CEST
RCVD (0.9011s) ARP reply 172.16.1.108 is at 92:25:CA:13:80:8A
```
</div>

<div class="notice--primary" markdown="1">
```bash
nping -c1 -H --tcp -p 80 172.16.1.108
```
```console
Starting Nping 0.7.91 ( https://nmap.org/nping ) at 2021-09-21 16:45 CEST
RCVD (0.0382s) TCP 172.16.1.108:80 > 172.16.1.10:62426 SA ttl=64 id=0 iplen=44  seq=2890728634 win=64240 <mss 1460>

nping -c1 -H --tcp -p 20,21,22,80,443 172.16.1.108-109

Starting Nping 0.7.91 ( https://nmap.org/nping ) at 2021-09-21 16:55 CEST
RCVD (0.0387s) TCP 172.16.1.108:20 > 172.16.1.10:26710 RA ttl=64 id=0 iplen=40  seq=0 win=0
RCVD (2.0406s) TCP 172.16.1.108:21 > 172.16.1.10:26710 SA ttl=64 id=0 iplen=44  seq=2253657139 win=64240 <mss 1460>
RCVD (4.0434s) TCP 172.16.1.108:22 > 172.16.1.10:26710 SA ttl=64 id=0 iplen=44  seq=2652345888 win=64240 <mss 1460>
RCVD (6.0464s) TCP 172.16.1.108:80 > 172.16.1.10:26710 SA ttl=64 id=0 iplen=44  seq=401423770 win=64240 <mss 1460>
RCVD (8.0494s) TCP 172.16.1.108:443 > 172.16.1.10:26710 RA ttl=64 id=0 iplen=40  seq=0 win=0
```
</div>
## Netdiscover
[Netdiscover](https://github.com/alexxy/netdiscover) wyświetla **na żywo** hosty, które znalazł w sieci. Program jest przydatny np., kiedy chcemy zobaczyć kto się nowy pojawił, albo zniknął. Niestety w programie mamy tylko możliwość wpisania całego zakresu sieci, ale to nie powinno przeszkadzać.
{: .text-justify}
### Przykład użycia
<div class="notice--primary" markdown="1">
```bash
netdiscover -i eth0 -r 172.16.1.0/24
```
```console
 Currently scanning: 172.16.1.0/24   |   Screen View: Unique Hosts

 3 Captured ARP Req/Rep packets, from 3 hosts.   Total size: 408
 _____________________________________________________________________________
   IP            At MAC Address     Count     Len  MAC Vendor / Hostname
 -----------------------------------------------------------------------------
 172.16.1.108    92:25:ca:13:80:8a      1      42  Unknown vendor
 172.16.1.135    00:17:9a:25:46:bf      1      60  D-Link Corporation
 172.16.1.194    b6:b6:42:48:b5:89      1      42  Unknown vendor
```
</div>
## Masscan
Bardzo szybki skaner, który znajduje się w [repozytorium](https://github.com/robertdavidgraham/masscan). W sumie nie używam go za często do wyszukiwania otwartych portów wirtualek, ale zamieszczam go tutaj ze względu na jego szybkość.
{: .text-justify}
### Przykład użycia
<div class="notice--primary" markdown="1">
```bash
masscan 172.16.1.108-172.16.1.200 -p80
```
```console
Starting masscan 1.3.2 (http://bit.ly/14GZzcT) at 2021-09-21 17:51:10 GMT
Initiating SYN Stealth Scan
Scanning 93 hosts [1 port/host]
Discovered open port 80/tcp on 172.16.1.135
Discovered open port 80/tcp on 172.16.1.194
Discovered open port 80/tcp on 172.16.1.108
```
</div>
## Fping
Mały i prosty program do szybkiego pingowania, dobrze się sprawdza w skryptach. Ale uwaga działa tylko na protokole **ICMP**.
{: .text-justify}
### Przykład użycia
<div class="notice--primary" markdown="1">
```bash
fping -qag 172.16.1.0/24
```
```console
172.16.1.108
172.16.1.135
172.16.1.194
172.16.1.244
```
</div>
## NBTscan
Dosyć [stary](http://www.unixwiz.net/tools/nbtscan.html) program, ale pozwala nam szybko zeskanować komputery głównie pod systemami Windows. W wirtualkach jest raczej nieprzydatny, za to w dużych windosowskich sieciach - na pewno się przyda. Zamieszczam go tu jako ciekawostkę. Inną ciekawą rzeczą jest to, że program pamięta czasy **DOS**a. :smiley:
{: .text-justify}
### Przykład użycia:
<div class="notice--primary" markdown="1">
```bash
nbtscan 172.16.1.0/24
```
```console
Doing NBT name scan for addresses from 172.16.1.0/24

IP address       NetBIOS Name     Server    User             MAC address
------------------------------------------------------------------------------
172.16.1.35      SATMAH96S       <server>   SATMMAH96S       00:00:00:00:00:00
172.16.1.44      KOMP1            <server>  KOMP1            00:00:00:00:00:00
172.16.1.113     DESKTOP-32RQ3IP  <server>  <unknown>        xx:xx:xx:1b:xx:e2
```
</div>

# I to już wszystko
Jak się podobał wpis, daj znać na mejla. A może znasz jakiś ciekawy program, który warto tutaj dodać? Myślę, że będę kontynuował tę serię.
{: .text-justify}
