---
title: "Workspace w Metasploicie"
excerpt: " "
comments: true
categories:
  - Hacking  
tags:
  - Hacking
  - Metasploit
  - Tools
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Słowem wstępu
Czasami lepiej jest zainstalować od nowa Kali Linux niż motać się z aktualizacjami z dawnych wersji. Ale co z naszymi workspace'-ami. Problem z eksportowaniem jednego workspace praktycznie nie istnieje. Wystarczy jedna komenda. Gorzej jest jak chcesz ich przenieść dużo więcej. Możesz to zrobić ręcznie, ale od czego są skrypty?
{: .text-justify}

# Skrypt kopiujący workspace do plików
W tablicy są tworzone nazwy workspace, które są pobierane z Metasploita. Zawieruchy z Sedem są potrzebne, aby skasować kolory i spacje. Następnie w pętli są odczytywane nazwy workspace i dzięki komendzie msfconsole są eksportowane workspace do plików.
{: .text-justify}
```bash
#!/bin/bash
mapfile -t WORKSPACE <<<$(msfconsole -q -x 'workspace; exit' | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g; s/^[[:space:]]*//' | grep -v '\*' )

SCIEZKA="/sciezka/do/zgrania/workspace/"
PLIK_XML_SUFFIX="_export.xml"
PLIK_PWDUMP_SUFFIX="_export.pwdump"

#Odzytuje i zapisuje worspace do pliku
for PLIK in "${WORKSPACE[@]}"; do

#xlm
msfconsole -q -x "workspace $PLIK; db_export -f xml $SCIEZKA$PLIK$PLIK_XML_SUFFIX; exit"
echo "Eksportowano workspace $PLIK do $SCIEZKA$PLIK$PLIK_XML_SUFFIX"
#pwdump
msfconsole -q -x "workspace $PLIK; db_export -f pwdump $SCIEZKA$PLIK$PLIK_PWDUMP_SUFFIX; exit"
echo "Eksportowano workspace $PLIK do $SCIEZKA$PLIK$PLIK_PWDUMP_SUFFIX"
done
```
# Skrypt kopiujący workspace z plików
Skrypt jest praktycznie odwrotnością wcześniejszego. W tablicy są tworzone nazwy workspace, które są pobierane z plików.Następnie w pętli są odczytywane nazwy workspace i dzięki msfconsole są importowane do Metasploita. Najpierw jest to tworzone dla plików *.xml, następnie dla plików *.pwdump. Proponuję się zapoznać z komendami wykonanymi przez msfconsole.
{: .text-justify}
```bash
#!/bin/bash

SCIEZKA="/sciezka/do/zgrania/workspace/"
PLIK_XML_SUFFIX="_export.xml"
PLIK_PWDUMP_SUFFIX="_export.pwdump"

mapfile -t WORKSPACE <<<$(ls -1 $SCIEZKA*.xml)

for FULLNAME in "${WORKSPACE[@]}"; do
NAME=${FULLNAME/#$SCIEZKA}
NAME=${NAME/%$PLIK_XML_SUFFIX}
msfconsole -q -x "workspace -a $NAME; db_import $FULLNAME; exit"
echo Importowano workspace $NAME z $FULLNAME
done

mapfile -t WORKSPACE <<<$(ls -1 $SCIEZKA*.pwdump)

for FULLNAME in "${WORKSPACE[@]}"; do
NAME=${FULLNAME/#$SCIEZKA}
NAME=${NAME/%$PLIK_PWDUMP_SUFFIX}
msfconsole -q -x "workspace $NAME; db_import $FULLNAME; exit"
echo Importowano workspace $NAME z $FULLNAME
done
```
