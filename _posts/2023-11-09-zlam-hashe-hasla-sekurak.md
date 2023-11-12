---
title: "Konkurs Sekuraka - złam hashe 2023-10-31"
excerpt: " "
comments: true
categories:
  - Hacking  
tags:
  - sekurak
  - hashe
  - academy2024
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Słowem wstępu
Ostatnio [Sekurak](https://sekurak.pl) ogłosił dnia 31.10.2023 kolejny [konkurs](https://sekurak.pl/zlam-hashe-hasla-i-zdobadz-bezplatne-wejscie-na-sekurak-academy-2024/) na złamanie hashy. Pierwsze 10 osób otrzymało bezpłatne wejście na [Sekurak Academy 2024](https://sekurak.academy/). Termin nadsyłania wyników minął 07.11.2023. Dzisiaj jest już 09.11.2023, więc publikuje sposób tego co udało mi się złamać (niestety tylko 9 z 10 hashy), ale opisze przebieg w jaki udało mi się tego dokonać. Do całej operacji użyłem programu Hashcat, wspomogła mnie karta graficzna **Radeon RX 6600** oraz troszkę **Intel(R) UHD Graphics 770**.
{: .text-justify}

# Hashe
```bash
61e5851b40d661bd046bdd96577fc4e81b7ae625
db13ca089eb4860896567399a30558f2c1fc69e7
9ca2065c0db9c96e7c2610bc3646991b590620f8
cc713abadd413446b499a795a963e3358e6bea37
11611d749d0a4df9a91bdc6967a05a4a85df7ffb
e68e8854e4da8055832f1a00ced5ac8772611a64
3c37442f864f1921808a2440c7657311df38b919
61d54fe02ce6edcde2f5762f2677b3c83d876417
d451fa69378f9a246cff1a0f3bf0979b1df643ee
283d5cb401e9de6a2e56f97166a639479fb86aee
```
Hashe są zakodowane przez **SHA1**. Można to bardzo łatwo sprawdzić przez samego **Hashcata**.
{: .text-justify}

```powershell
PS C:\temp\sekurak-hash-2024\hashcat> .\hashcat.exe .\hashe.txt
hashcat (v6.2.6) starting in autodetect mode

hiprtcCompileProgram is missing from HIPRTC shared library.

OpenCL API (OpenCL 2.1 AMD-APP (3584.0)) - Platform #1 [Advanced Micro Devices, Inc.]
=====================================================================================
* Device #1: AMD Radeon RX 6600, 8064/8176 MB (6732 MB allocatable), 14MCU

OpenCL API (OpenCL 3.0 ) - Platform #2 [Intel(R) Corporation]
=============================================================
* Device #2: Intel(R) UHD Graphics 770, 6464/13015 MB (2047 MB allocatable), 32MCU

The following 7 hash-modes match the structure of your input hash:

      # | Name                                                       | Category
  ======+============================================================+======================================
    100 | SHA1                                                       | Raw Hash
   6000 | RIPEMD-160                                                 | Raw Hash
    170 | sha1(utf16le($pass))                                       | Raw Hash
   4700 | sha1(md5($pass))                                           | Raw Hash salted and/or iterated
  18500 | sha1(md5(md5($pass)))                                      | Raw Hash salted and/or iterated
   4500 | sha1(sha1($pass))                                          | Raw Hash salted and/or iterated
    300 | MySQL4.1/MySQL5                                            | Database Server

Please specify the hash-mode with -m [hash-mode].
```
Tak jak wyżej napisałem, nasuwa się odpowiedź że został użyty **SHA1**.
## 1. 2. i 3. hash
Do łamania użyłem **Hashcata**. John the ripper, też sobie by poradził, ale nie tak szybko jak Hashcat. Pierwsza próba ze słownikiem **rockyou.txt** nie dała żadnych efektów, ale łamanie bruteforce to był strzał w dziesiątke. To było najprostsze, wystarczyło uruchomić tryb a3 czyli bruteforce z **domyślnymi** parametrami i poczekać aż program skończy łamać od jednego do ośmiu znaków. Najpierw zacząłem kombinować z różnymi maskami, ale domyślne są najlepsze. Czyli maska **?1?2?2?2?2?2?2?3**, a opis maski wygląda tak **-1 ?l?d?u**, **-2 ?l?d**, **-3 ?l?d*!$@_**. Ustawiając __wszystko__ dla ośmiu znaków łamanie trwałoby dużo dłużej.
{: .text-justify}

```powershell
.\hashcat.exe -O -m100 -a3 .\hashe.txt
```
Już po paru sekundach dwa hashe zostały złamane:
{: .text-justify}

Pierwszy i drugi hash:
{: .text-justify}
```
cc713abadd413446b499a795a963e3358e6bea37:Ow0jw2
61e5851b40d661bd046bdd96577fc4e81b7ae625:seqrak
```
Po pięciu, sześciu minutach poległ trzeci hash:

```powershell
Session..........: hashcat
Status...........: Running
Hash.Mode........: 100 (SHA1)
Hash.Target......: .\hashe.txt
Time.Started.....: Thu Nov 09 20:24:07 2023 (5 mins, 41 secs)
Time.Estimated...: Thu Nov 09 20:35:45 2023 (5 mins, 57 secs)
Kernel.Feature...: Optimized Kernel
Guess.Mask.......: ?1?2?2?2?2?2?2?3 [8]
Guess.Charset....: -1 ?l?d?u, -2 ?l?d, -3 ?l?d*!$@_, -4 Undefined
Guess.Queue......: 8/15 (53.33%)
Speed.#1.........:  7483.1 MH/s (7.53ms) @ Accel:128 Loops:128 Thr:256 Vec:1
Speed.#2.........:   425.8 MH/s (9.96ms) @ Accel:32 Loops:32 Thr:128 Vec:4
Speed.#*.........:  7908.7 MH/s
Recovered........: 2/10 (20.00%) Digests (total), 0/10 (0.00%) Digests (new)
Progress.........: 2707827982336/5533380698112 (48.94%)
Rejected.........: 0/2707827982336 (0.00%)
Restore.Point....: 29687808/68864256 (43.11%)
Restore.Sub.#1...: Salt:0 Amplifier:39680-39808 Iteration:0-128
Restore.Sub.#2...: Salt:0 Amplifier:70624-70656 Iteration:0-32
Candidate.Engine.: Device Generator
Candidates.#1....: svftlrv4 -> c8bss46k
Candidates.#2....: 0k6wo20d -> Cn764en9
Hardware.Mon.#1..: Temp: 58c Fan: 58% Util: 95% Core:2300MHz Mem:1740MHz Bus:8
Hardware.Mon.#2..: N/A

11611d749d0a4df9a91bdc6967a05a4a85df7ffb:anw22ii2
[s]tatus [p]ause [b]ypass [c]heckpoint [f]inish [q]uit =>
```
Poczekałem aż program skończy łamać osiem znaków i kiedy **Hashcat** zaczął łamać dziewięć znaków, po prostu przerwałem. Za długo to by trwało na początek. Trzeba było znaleźć inną metodę.
{: .text-justify}
## 4. Hash
Tym razem użyłem popularnego słownika **rockyou.txt**. Komenda tym razem wyglądała tak:
{: .text-justify}
```powershell
.\hashcat.exe -O -m100 -a0 .\hashe.txt .\dict\rockyou.txt
```
```
Session..........: hashcat
Status...........: Exhausted
Hash.Mode........: 100 (SHA1)
Hash.Target......: .\hashe.txt
Time.Started.....: Thu Nov 09 20:46:30 2023 (7 secs)
Time.Estimated...: Thu Nov 09 20:46:37 2023 (0 secs)
Kernel.Feature...: Optimized Kernel
Guess.Base.......: File (.\dict\rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  1511.3 kH/s (0.70ms) @ Accel:512 Loops:1 Thr:128 Vec:1
Speed.#2.........:   730.3 kH/s (4.25ms) @ Accel:256 Loops:1 Thr:64 Vec:4
Speed.#*.........:  2241.6 kH/s
Recovered........: 3/10 (30.00%) Digests (total), 0/10 (0.00%) Digests (new)
Progress.........: 14344385/14344385 (100.00%)
Rejected.........: 3094/14344385 (0.02%)
Restore.Point....: 14323499/14344385 (99.85%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Restore.Sub.#2...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: ...twat... -> $wishon1$
Candidates.#2....: $HEX[2477696e737761736572] -> $HEX[042a0337c2a156616d6f732103]
Hardware.Mon.#1..: Temp: 42c Fan:  0% Util:  1% Core:  30MHz Mem:  46MHz Bus:8
Hardware.Mon.#2..: N/A
```
Niestety, mimo błyskawicznej analizy, nie przyniosło to efektu. Spróbowałem z regułami **OneRuleToRuleThemAll.rule**
{: .text-justify}
```powershell
Session..........: hashcat
Status...........: Running
Hash.Mode........: 100 (SHA1)
Hash.Target......: .\hashe.txt
Time.Started.....: Thu Nov 09 20:51:12 2023 (3 secs)
Time.Estimated...: Thu Nov 09 20:53:40 2023 (2 mins, 25 secs)
Kernel.Feature...: Optimized Kernel
Guess.Base.......: File (.\dict\rockyou.txt)
Guess.Mod........: Rules (.\rules\OneRuleToRuleThemAll.rule)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  4902.8 MH/s (11.17ms) @ Accel:256 Loops:64 Thr:256 Vec:1
Speed.#2.........:   110.6 MH/s (4.57ms) @ Accel:4 Loops:8 Thr:512 Vec:4
Speed.#*.........:  5014.0 MH/s
Recovered........: 3/10 (30.00%) Digests (total), 0/10 (0.00%) Digests (new)
Progress.........: 14593231496/745836298075 (1.96%)
Rejected.........: 1247880/14593231496 (0.01%)
Restore.Point....: 0/14344385 (0.00%)
Restore.Sub.#1...: Salt:0 Amplifier:15552-15616 Iteration:0-64
Restore.Sub.#2...: Salt:0 Amplifier:4928-4936 Iteration:0-8
Candidate.Engine.: Device Generator
Candidates.#1....: yoyanscott -> yompton608
Candidates.#2....: 123456971 -> computer?962
Hardware.Mon.#1..: Temp: 49c Fan: 18% Util: 90% Core:2188MHz Mem:1738MHz Bus:8
Hardware.Mon.#2..: N/A

d451fa69378f9a246cff1a0f3bf0979b1df643ee:grzechu1234
[s]tatus [p]ause [b]ypass [c]heckpoint [f]inish [q]uit =>
```
Czwarty hash, jak widać został złamany. Zostało jeszcze sześć. Poczekałem jeszcze do końca, ale tą metodą nic więcej nie zostało osiągnięte. 
{: .text-justify}
## 5. i 6. hash
Spróbowałem teraz pozgrywać słowa ze strony [strona](https://sekurak.pl/zlam-hashe-hasla-i-zdobadz-bezplatne-wejscie-na-sekurak-academy-2024/). Do tego użyłem programu **Cewl**.
{: .text-justify}
```bash
cewl https://sklep.securitum.pl/ > sekurak-academy-2024.txt
```
Zanim wszystko **Cewl** przemielił, trochę czasu mu to zabrało. Jednak po parunastu (parudziesięciu) minutach miałem gotowy słownik ze słowami. Zakładałem, że w haśle nie ma polskich liter więc się ich pozbyłem programem **Iconv**. Przy okazji posortowałem słownik i pozbyłem się duplikatów.
{: .text-justify}
```bash
iconv -f=utf-8 -t=ascii//TRANSLIT < sekurak-academy-2024.txt | tr '[:upper:]' '[:lower:]' | sort | uniq  > sekurak-academy-2024-no-diacritic.txt
```
Na początku poniższa komenda nie przyniosła efektu:
{: .text-justify}
```powershell
.\hashcat.exe -O -m100 -a0 .\hashe.txt .\dict\sekurak-academy-2024-no-diacritic.txt
```
Ale po połączeniu słowników, uzyskałem bardzo dobry efekt:
```powershell
.\hashcat.exe -O -m100 -a1 .\hashe.txt .\dict\sekurak-academy-2024-no-diacritic.txt .\dict\sekurak-academy-2024-no-diacritic.txt
```
Dwa kolejne hasła zostały odkryte:
{: .text-justify}
```
3c37442f864f1921808a2440c7657311df38b919:bezpiecznykurak
283d5cb401e9de6a2e56f97166a639479fb86aee:akademiasekuraka
```
## 7. i 8. hash
Zacząłem kombinować ze słowami ze strony o konkursie. Do wygenerowanego słownika ze strony dorzuciłem między innymi **Sekurak.Academy**. Zdziwił mnie trochę zapis tego słowa. Na początku nic to nie dało, ale z regułami **OneRuleToRuleThemAll.rule** sprawa wyglądała lepiej.
{: .text-justify}
```powershell
.\hashcat.exe -O -m100 -a0 .\hashe.txt .\dict\sekurak-academy-2024-no-diacritic.txt -r .\rules\OneRuleToRuleThemAll.rule
```
```
db13ca089eb4860896567399a30558f2c1fc69e7:sekurak.academy
9ca2065c0db9c96e7c2610bc3646991b590620f8:sekurak2024
```
**sekurak.academy** został złamany i przy okazji **sekurak2024**.
{: .text-justify}
## 9. hash
Już zostało mało hashy do złamania, więc zacząłem się bawić z różnymi maskami i z bruteforce z ośmioma, dziewięcioma, dziesięcioma literami. Niestety - zero efektów. Pomyślałem sobie, że może coś jest ukryte na stronie w obrazkach, ale nie mogłem tam nic znaleźć (okazało się, że nie tędy droga). W akcie desperacji spróbowałem z nowym słownikiem. Tym razem użyłem polskiego. Ściągnąłem plik ze strony [sjp](https://sjp.pl/sl/odmiany/) i przerobiłem na słownik przyjazny dla **Hashcata**. Poniżej podaje skrypt, który pomaga to ściągnąć i przerobić.
{: .text-justify}
```bash
#uwaga, sprawdz czy są polskie znaki
#pl_PL.UTF-8
#dpkg-reconfigure locales
#takie trzeb wybrać pl_PL.UTF-8

https://sjp.pl/sl/odmiany/

#skrypt
#!/bin/bash
LOCALE_=pl_PL.UTF-8
PLIK_WYNIKOWY_DIAC=odm_pl_diacritic.txt
PLIK_WYNIKOWY_NO_DIAC=odm_pl_no_diacritic.txt
PLIK_W_SJP=odm.txt
SJP_SITE='https://sjp.pl/sl/odmiany/'
SJP_WER=$(curl -sk $SJP_SITE | grep  -o '[a-z0-9-]*\.zip' | uniq)
    
if [[ $LANG != $LOCALE_ ]] then echo Uwaga moze być niepoprawna konwersja z polskich znaków; fi

echo Pobieram najnowsza wersje slownika z $SJP_SITE
curl -ks $SJP_SITE$SJP_WER --output $SJP_WER
    
echo Rozpakowuje $SJP_SITE$SJP_WER
unzip -o $SJP_WER $PLIK_W_SJP
    	
echo Przetwarzanie - dzielimy wyrazy na wiersze, usuwamy przecinek, sortujemy - $PLIK_WYNIKOWY_DIAC
tr ',' '\n' < $PLIK_W_SJP | tr -d '\t '  | tr '[:upper:]' '[:lower:]'| sort | uniq > $PLIK_WYNIKOWY_DIAC

echo Przetwarzanie - usuwanie polskich znakow - $PLIK_WYNIKOWY_NO_DIAC
iconv -f=utf-8 -t=ascii//TRANSLIT  $PLIK_WYNIKOWY_DIAC > $PLIK_WYNIKOWY_NO_DIAC
```
Odpaliłem słownik w trybie dwóch słowników.
{: .text-justify}
```powershell
.\hashcat.exe -O -m100 -a1 .\hashe.txt .\dict\odm_pl_no_diacritic.txt .\dict\odm_pl_no_diacritic.txt
```
```powershell
[s]tatus [p]ause [b]ypass [c]heckpoint [f]inish [q]uit =>

Session..........: hashcat
Status...........: Running
Hash.Mode........: 100 (SHA1)
Hash.Target......: .\hashe.txt
Time.Started.....: Thu Nov 09 22:12:41 2023 (15 secs)
Time.Estimated...: Thu Nov 09 23:15:58 2023 (1 hour, 3 mins)
Kernel.Feature...: Optimized Kernel
Guess.Base.......: File (.\dict\odm_pl_no_diacritic.txt), Left Side
Guess.Mod........: File (.\dict\odm_pl_no_diacritic.txt), Right Side
Speed.#1.........:  5045.9 MH/s (10.34ms) @ Accel:16 Loops:1024 Thr:256 Vec:1
Speed.#2.........:   122.6 MH/s (8.08ms) @ Accel:64 Loops:16 Thr:32 Vec:4
Speed.#*.........:  5168.5 MH/s
Recovered........: 8/10 (80.00%) Digests (total), 0/10 (0.00%) Digests (new)
Progress.........: 73449178480/19624111467921 (0.37%)
Rejected.........: 70878576/73449178480 (0.10%)
Restore.Point....: 0/4429911 (0.00%)
Restore.Sub.#1...: Salt:0 Amplifier:1249280-1250304 Iteration:0-1024
Restore.Sub.#2...: Salt:0 Amplifier:26544-26560 Iteration:0-16
Candidate.Engine.: Device Generator
Candidates.#1....: 3dnazewnictwem -> beczalabysnazranski
Candidates.#2....: antygazemalbercikow -> beczalemalberski
Hardware.Mon.#1..: Temp: 51c Fan: 38% Util: 77% Core:2092MHz Mem:  96MHz Bus:8
Hardware.Mon.#2..: N/A

e68e8854e4da8055832f1a00ced5ac8772611a64:bezpiecznakura
[s]tatus [p]ause [b]ypass [c]heckpoint [f]inish [q]uit =>
```
Dziewiąte hasełko pękło.
{: .text-justify}
## 10. hash
Niestety nie udało mi się złamać dziesiątego hasła. Okazało się, że jest to połączenie trzech różnych słów. [Tutaj](https://nfsec.pl/security/6547) można o tym poczytać. Ogólnie to była świetna zabawa. Dzięki Sekurak.
{: .text-justify}

