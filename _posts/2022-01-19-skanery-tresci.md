---
title: "[02] Skanery treści"
excerpt: " "
comments: true
categories:
  - Hacking
  - Tools
tags:
  - Hacking
  - Tools
  - Dirb
  - Gobuster
  - Dirsearch
  - Feroxbuster
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Do czego to służy?
Na serwerach **HTTP** często znajduje się dużo ukrytych plików lub katalogów, które nie są udostępniane w linkach strony.  Przypadkowo ktoś może zapomnieć usunać jakieś zdjęcie, zapomniany kod w PHP, ZIP, repozytorium, a nawet plik z hasłami. Dzięki odkrytym przez nas plikom, możemy mieć jakiś punkt zaczepienia w poznaniu słabego punktu serwera i ogólnie dowiedzieć się o nim czegoś więcej. Znajdowanie plików najczęściej odbywa się metodą słownikową. Sukces jednak w dużej mierze zależy od dobrego słownika i wcześniejszego rozpoznania środowiska. Dobrze wiedzieć czego szukać. Dobry skaner też tutaj ma znaczenie, chociaż wg mnie ważniejszy jest słownik. Większość programów skanujących oferuje podobne funkcje, mimo to preferuję [Feroxbuster](https://github.com/epi052/feroxbuster). Wszystkie testy "wyszukiwaczy" zostały wykonane na wirtualnej maszynie [serve](https://hackmyvm.eu/machines/machine.php?vm=Serve), która się znajduje na świetnym serwisie z podatnymi wirtualkami [hackmyvm](https://hackmyvm.eu).
{: .text-justify}

# Programy
## Dirb
**Dirb** jest jednym z najstarszym znanym mi skanerem treści. Można go znaleźć w Kali Linuxie. Wersja 2.2 pochodzi z 2009 roku i nie widać następnej. Jednak ten podeszły wiek programu nie przeszkadza w jego funkcjonowaniu. Skaner jest bardzo prosty w użyciu. Wystarczy w parametrze podać scieżkę do serwera **WWW** i ewentualnie do słownika. Program standardowo identyfikuje się jako "Mozilla/4.0" :smiley: i tak jak wszystkie znane mi skanery przeszukuje rekurencyjnie, co oczywiście można zmienić.
{: .text-justify}
```bash
root@kali:/usr/share/wordlists# dirb http://serve.lan
```
```bash
-----------------
DIRB v2.22
By The Dark Raver
-----------------

START_TIME: Wed Jan 19 21:50:14 2022
URL_BASE: http://serve.lan/
WORDLIST_FILES: /usr/share/dirb/wordlists/common.txt

-----------------

GENERATED WORDS: 4612

---- Scanning URL: http://serve.lan/ ----
+ http://serve.lan/index.html (CODE:200|SIZE:10701)
==> DIRECTORY: http://serve.lan/javascript/
==> DIRECTORY: http://serve.lan/secrets/
+ http://serve.lan/server-status (CODE:403|SIZE:274)
+ http://serve.lan/webdav (CODE:401|SIZE:456)

---- Entering directory: http://serve.lan/javascript/ ----
==> DIRECTORY: http://serve.lan/javascript/jquery/

---- Entering directory: http://serve.lan/secrets/ ----
+ http://serve.lan/secrets/index.html (CODE:200|SIZE:7)

---- Entering directory: http://serve.lan/javascript/jquery/ ----
+ http://serve.lan/javascript/jquery/jquery (CODE:200|SIZE:271756)

-----------------
END_TIME: Wed Jan 19 21:50:24 2022
DOWNLOADED: 18448 - FOUND: 5
```
Słownik zawiera tylko 4612 słów, wiec nie jest zbyt obszerny, jednak dosłownie w dziesięć sekund znalazł pięc elementów. To niestety nie wszystko, ale używając innego słownika, pewnie byłoby lepiej. Prosty skaner na start.
{: .text-justify}

## Gobuster
[Gobuster](https://github.com/OJ/gobuster) jest już nowszym programem, który działa od razu na dziesięciu wątkach. Ma podstawowe funkcje, co programy tego typu. Jest możliwość doklejenia do nazwy rozszerzenia. Oprócz przeszukiwania katalogów można też enumerować **DNS**y, wirtualne hosty, a nawet kubełki **S3** na **Amazonie**.
{: .text-justify}
```bash
root@kali:/usr/share/wordlists# gobuster dir -u http://serve.lan -w /usr/share/dirb/wordlists/common.txt
```
```bash
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://serve.lan
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/dirb/wordlists/common.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.1.0
[+] Timeout:                 10s
===============================================================
2022/01/19 22:15:15 Starting gobuster in directory enumeration mode
===============================================================
/.htpasswd            (Status: 403) [Size: 274]
/.htaccess            (Status: 403) [Size: 274]
/.hta                 (Status: 403) [Size: 274]
/index.html           (Status: 200) [Size: 10701]
/javascript           (Status: 301) [Size: 311] [--> http://serve.lan/javascript/]
/secrets              (Status: 301) [Size: 308] [--> http://serve.lan/secrets/]
/server-status        (Status: 403) [Size: 274]
/webdav               (Status: 401) [Size: 456]

===============================================================
2022/01/19 22:15:15 Finished
```

## Dirsearch
[Dirsearch](https://github.com/maurosoria/dirsearch) został napisany w **Pythonie** i wymaga co najmniej wersji 3.7. Niestety jego instalacja nastręcza sporo problemów. Jest to raczej spowodowane dziwnymi zależnościami bibliotek. Dobrze, jakby był w jakimś repozytorium. Niestety, na razie go nie ma. Zaletą programu jest wynik skanowania, który jest wyświetlany w kolorze, który to ułatwia przejrzenie wyniku. Z ciekawszych rzeczy jest opcja zamiany słów ze słownika na duże, małe litery lub tylko zamianę pierwszą dużą literę. Używałem go jakiś czas, jednak jego crashe zniechęciły mnie do niego, a nowsze wersje nie chciały się poprawnie zainstalować. Domyślnie ustawia najbardziej popularne rozszerzenia plików. Tak jak w **Dirb** wystarczy tylko podać ścieżkę do serwera. Resztę załatwia program.
{: .text-justify}
```bash
root@kali:/usr/share/wordlists# dirsearch -u http://serve.lan/
```
```bash

  _|. _ _  _  _  _ _|_    v0.4.2
 (_||| _) (/_(_|| (_| )

Extensions: php, aspx, jsp, html, js | HTTP method: GET | Threads: 30 | Wordlist size: 10903

Output File: /usr/local/lib/python3.9/dist-packages/dirsearch/reports/serve.lan/-_22-01-19_22-08-24.txt

Error Log: /usr/local/lib/python3.9/dist-packages/dirsearch/logs/errors-22-01-19_22-08-24.log

Target: http://serve.lan/

[22:08:24] Starting:
[22:08:25] 403 -  274B  - /.ht_wsr.txt
[22:08:25] 403 -  274B  - /.htaccess.bak1
[22:08:25] 403 -  274B  - /.htaccess.save
[22:08:25] 403 -  274B  - /.htaccess.sample
[22:08:25] 403 -  274B  - /.htaccess_extra
[22:08:25] 403 -  274B  - /.htaccess.orig
[22:08:25] 403 -  274B  - /.htaccess_sc
[22:08:25] 403 -  274B  - /.htaccessBAK
[22:08:25] 403 -  274B  - /.htaccessOLD
[22:08:25] 403 -  274B  - /.htaccess_orig
[22:08:25] 403 -  274B  - /.htaccessOLD2
[22:08:25] 403 -  274B  - /.htm
[22:08:25] 403 -  274B  - /.htpasswd_test
[22:08:25] 403 -  274B  - /.httr-oauth
[22:08:25] 403 -  274B  - /.htpasswds
[22:08:25] 403 -  274B  - /.html
[22:08:26] 403 -  274B  - /.php
[22:08:36] 200 -   10KB - /index.html
[22:08:36] 301 -  311B  - /javascript  ->  http://serve.lan/javascript/
[22:08:40] 301 -  308B  - /secrets  ->  http://serve.lan/secrets/
[22:08:40] 200 -    7B  - /secrets/
[22:08:40] 403 -  274B  - /server-status
[22:08:40] 403 -  274B  - /server-status/
[22:08:42] 401 -  456B  - /webdav/
[22:08:42] 401 -  456B  - /webdav/index.html
[22:08:42] 401 -  456B  - /webdav/servlet/webdav/

Task Completed
<dirsearch.dirsearch.Program object at 0x7f8c2bea9a90>
```
Jak widać program na końcu się "wyłożył".
{: .text-justify}

## Feroxbuster
[Feroxbuster](https://github.com/epi052/feroxbuster) to mój ulubiony skaner. W przeciwieństwie do **Dirsearch**a znajduje się w repozytorium, więc raczej nie powinno być problemu z jego zainstalowaniem. Ma bardzo czytelny i wprost bajerancki ekran wynikowy z różnymi ikonkami, ale nie tylko ikonkami człowiek żyje. Widać ile znaleziony plik ma linii, słów, jest widoczny kod odpowiedzi i nawet bezpośredni link do niego, co jest bardzo przydatne, a nie wszędzie to widziałem. Ogromną zaletą tego skanera jest to, że podczas pracy można podczas anulować przeszukiwanie wybranego katalogu. Dodatkowo program używa rekurencji, czyli wchodzi w głąb katalogów i je przeszukuje. Jednak, co jest moim zdaniem wadą i zaletą, domyślnie wyszukuje tylko elementy bez rozszerzeń, ale można to zmienić parametrem **-x**. I uwaga, program domyślnie używa aż pięćdziesiąt wątków, więc może narobić szumu. Z dodatkowych zalet, to można używać też IPv6, co jest bardzo rzadkie w tego typu programach (tylko to tu widziałem). Jest też opcja przeszukiwania linków ze znalezionego dokumentu. 
{: .text-justify}

```bash
root@kali:/tmp/dirsearch# feroxbuster -u http://serve.lan
```
```bash
 ___  ___  __   __     __      __         __   ___
|__  |__  |__) |__) | /  `    /  \ \_/ | |  \ |__
|    |___ |  \ |  \ | \__,    \__/ / \ | |__/ |___
by Ben "epi" Risher 🤓                 ver: 2.4.1
───────────────────────────┬──────────────────────
 🎯  Target Url            │ http://serve.lan
 🚀  Threads               │ 50
 📖  Wordlist              │ /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
 👌  Status Codes          │ [200, 204, 301, 302, 307, 308, 401, 403, 405, 500]
 💥  Timeout (secs)        │ 7
 🦡  User-Agent            │ feroxbuster/2.4.1
 💉  Config File           │ /etc/feroxbuster/ferox-config.toml
 🔃  Recursion Depth       │ 4
 🎉  New Version Available │ https://github.com/epi052/feroxbuster/releases/latest
───────────────────────────┴──────────────────────
 🏁  Press [ENTER] to use the Scan Management Menu™
──────────────────────────────────────────────────
301        9l       28w      311c http://serve.lan/javascript
401       14l       54w      456c http://serve.lan/webdav
403        9l       28w      274c http://serve.lan/server-status
301        9l       28w      308c http://serve.lan/secrets
301        9l       28w      318c http://serve.lan/javascript/jquery
200    10363l    41520w   271756c http://serve.lan/javascript/jquery/jquery
[####################] - 27s   119996/119996  0s      found:6       errors:121
[####################] - 18s    29999/29999   1681/s  http://serve.lan
[####################] - 26s    29999/29999   1186/s  http://serve.lan/javascript
[####################] - 25s    29999/29999   1192/s  http://serve.lan/secrets
[####################] - 25s    29999/29999   1183/s  http://serve.lan/javascript/jquery
```
Jak widzimy wynik jest bardzo czytelny, jednak program znalazł tylko to co wcześniejsze skanery.
{: .text-justify}

# Słowniki
Drugą ważna sprawą są słowniki. Najpopularniejszym jest *rockyou.txt*, ale jest on bardzo duży i nie polecam nim na początek skanowania zasobów **WWW**. Inne dostępne słowniki w **Kali** można sprawdzić komendą *wordlists*.
{: .text-justify}
```bash
root@kali:/tmp/dirsearch# wordlists
> wordlists ~ Contains the rockyou wordlist
/usr/share/wordlists
├── dirb -> /usr/share/dirb/wordlists
├── dirbuster -> /usr/share/dirbuster/wordlists
├── dnsmap.txt -> /usr/share/dnsmap/wordlist_TLAs.txt
├── fasttrack.txt -> /usr/share/set/src/fasttrack/wordlist.txt
├── fern-wifi -> /usr/share/fern-wifi-cracker/extras/wordlists
├── metasploit -> /usr/share/metasploit-framework/data/wordlists
├── nmap.lst -> /usr/share/nmap/nselib/data/passwords.lst
├── rockyou.txt
└── seclists -> /usr/share/seclists
```
Słowniki znajdują się w katalogu */usr/share/wordlists*. Najczęściej używanym jest */usr/share/dirb/wordlists/common.txt*, lecz on nie zawsze znajduje wszystko. Używam też słownika */usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-small.txt* i większego */usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt*. Polecam też słownik z seclist */usr/share/seclists/Discovery/Web-Content/common.txt*. W katalogu */usr/share/seclists* jest bardzo dużo plików, nawet za dużo, i na odpowiednie okazje. Dobrze też wiedzieć czego się szuka. Inne są słowniki do imion, nazwisk, kont systemowych, aplikacji.
{: .text-justify}
<div class="notice--primary" markdown="1">
Lista słowników które używam wg kolejności
<pre>
<p style="background-color:white;">
/usr/share/dirb/wordlists/common.txt
/usr/share/wordlists/seclists/Discovery/Web-Content/common.txt
/usr/share/seclists/Discovery/Web-Content/big.txt
/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
/usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-small.txt
/usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt
/usr/share/wordlists/rockyou.txt
</p>
</pre>
</div>

# Koniec
Czy nam się uda coś znaleźć czy nie, to tak jak wcześniej napisałem, dużo zależy od słownika, odpowiednio dobranych rozszerzeń, trochę szczęścia i wiedzy co możemy znaleźć. Program jest w mniejszym stopniu ważny. Oprócz wymienionych wcześniej narzędzi, to fuzzery takie jak **Ffuf** lub **Wfuzz** też można użyć do przeszukiwania katalogów, jednak są raczej używane do szukania parametrów w pliku np. w **PHP**. Jeżeli znalazłeś jakieś błędy, masz sugestie, napisz na[kerszi@protonmail.com](mailto:kerszi@protonmail.com).
{: .text-justify}

