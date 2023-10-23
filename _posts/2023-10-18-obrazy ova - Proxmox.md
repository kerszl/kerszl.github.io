---
title: "Jak przenieść obrazy z formatu ova na Proxmox "
excerpt: " "
comments: true
categories:
  - Hacking  
tags:
  - Hacking
  - Proxmox
  - VirtualBox
  - HackMyVM
  - Tools
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Słowem wstępu
Nie każdy chce odpalać obrazy w formacie ovm z [hackmyvm](https://hackmyvm.eu/machines/) na VirtualBoxie, chociaż to jest bardzo wygodne. Ale osoby, które posiadają serwer na Proxmoxie mogą również tam wrzucić wirtualki w formacie ovm. Niestety, to nie jest takie proste, jak tylko wrzucenie obrazu. Problemy są dwa: sam format, który trzeba przekonwertować na pliki, które rozpoznaje Proxmox; drugim problemem jest inna nazwy sieciówki (wiąże się to ze specyfikacją sprzętu).
{: .text-justify}
# 1. Przesłanie obrazu
Aby to wszystko działało najpierw trzeba obraz przesłać. Można to zrobić standardowa przez **scp**, **sftp**. Jednak, żeby nie było za łatwo skorzystamy z **nc** (wersja OpenBSD i standalone) oraz z **pv** (aby oglądać na bieżąco pasek postępu)
{: .text-justify}
## 1.1 Proxmox nasłuchuje
Wchodzimy na serwer **Proxmoxa** i nasłuchujemy na porcie 12345 (port można zmienić). Na tym serwerze nie instalujemy **pv**.
{: .text-justify}
```bash
nc -vnl -p 12345 > hakujemy.ovm 
```
## 1.2 Serwer wysyła plik
Na serwerze, skąd jest wysyłany obraz, odpalamy **nc** (najlepiej wersję OpenBSD) i wysyłamy plik. Jeżeli to nie jest wersja OpenBSD, to nie działa przełącznik -N i trzeba ręcznie zatrzymać po wysłaniu obrazu. Oczywiscie wcześniej zalecam zainstalować pakiet **pv**. Jeżeli nie chcesz używać pv, możesz zamienić na **cat**.
{: .text-justify}
```bash
pv -p -t hakujemy.ovm | nc -N 10.0.0.5 12345
```
# 2. Konwersja
## 2.1 Rozpakowanie
Na samym początku z obrazu **hakujemy.ovm** należy wyciągnąć pliki. Tak naprawdę to jest plik w formacie tar.
{: .text-justify}
```bash
tar xvf hakujemy.ovm
```
## 2.2 Operacje na Proxmoxie
Teraz przystępujemy do konwersji: 
- tworzymy kolejny numer ID maszyny
- tworzymy wirtualkę (należy wziąć pod uwagę, że nazwa musi być zgodna z FQDM)
- importujemy dysk 
- przypisujemy dysk do wirtualki
- ustawiamy w biosie startowanie z naszego dysku
Poniżej są komendy, które to robią:
{: .text-justify}
```bash
#Bierzemy Najwieksze ID i dodajemy kolejny numer
NEW_ID=$(qm list | awk '$1 ~ /[[:digit:]]/ {if ($1>b) (b=$1)} END{print b+1}')
#Tworzymy wirtualke
qm create $NEW_ID --name $NAME --memory 1024 --net0 virtio,bridge=vmbr0
#Importujemy dysk
qm importdisk $NEW_ID $NAME-disk001.vmdk local-lvm -format qcow2
#Przypisowujemy dysk
qm set $NEW_ID --scsi0 local-lvm:vm-$NEW_ID-disk-0
#Ustawiamy w biosie bootowanie na dysk
qm set $NEW_ID --boot c --bootdisk scsi0
```
# 3. Edycja sieciówki
## Jak zmienić nazwę interfejsu?
Pozostaje nam zmienić nazwę sieciówki. Podczas startu systemu powinno się nam pokazać okno **GRUB**a. Jeżeli się nie pojawi, to trzymamy przycisk _Shift_. 
{: .text-justify}
![grub](/assets/images/hacking/2021/02/01.png)
Następnie klawisz _e_ i szukamy wpis, gdzie zazwyczaj na początku jest Linux, na końcu RO, chociaż nie jest to regułą. U nas to będzie
{: .text-justify}
``` 
linux  /boot/vmlinuz-4.4.0-142-generic root=UUID=ed440236-4e13-4670-... ro
```
_ro_ Zamieniamy na _rw init=/bin/bash_ Wygląda to mnie więcej tak:
{: .text-justify}
```
linux  /boot/vmlinuz-4.4.0-142-generic root=UUID=ed440236-4e13-4670-80d6-7617e64... rw init=/bin/bash
```
klawisz _F10_ i po chwili ładuje się konsola do **root**a
{: .text-justify}
![grub](/assets/images/hacking/2021/02/02.png)
Teraz w zależności od systemu należy zmienić kartę sieciową na prawidłową, nie będziemy zamieniać na _eth0_ jak przy XCP. Załóżmy, że jest to system **Ubuntu 16.04**. Więc ustawienie sieciówek jest prawdopodobnie w _/etc/network/interface_
{: .text-justify}
```bash
cat /etc/network/interface

auto enp0s3
iface enp0s3 inet dhcp
```
Można sprawdzić jaką kartę sieciową wykrył system. Do tego służy komenda *ip a*. Najczęściej to jest _ens18_. Aby wszystko wstało poprawnie nazwę można zmienić poprzez *sed*.
{: .text-justify}
```bash
sed -i 's/enp0s3/ens18/g' /etc/network/interface
```
# 4. Koniec
Restart i hakujemy. Na koniec załączam mój skrypt, który ułatwia większość operacji.
{: .text-justify}
```bash
#!/bin/bash

#1. ustawienie odbierania
#2. ustawienie nadawania
#3. konwersja
KATALOG_OBRAZOW="/mnt/g/utils/obrazy systemowe/Linux/hacking/virtualki do testow/obrazy-hackmyvm/"
KATALOG_PROXMOX="/var/lib/vz/ova"
IP_PROXMOX='172.16.1.6'
PORT_PROXMOX='12345'

if [ ! $#  -eq 2 ]; then
echo "Parametry to: [odbieram, wysylam, konwertuje] nazwa-obrazu"
exit
fi

if ! $( grep -q '.\.ova$' <<< $2 )
then
echo Nazwa pliku powinna się konczyć na ova
exit
fi


NAME=${2/%.ova/}


if [ $1 == 'odbieram' ]; then
    cd $KATALOG_PROXMOX
    nc -vnl -p $PORT_PROXMOX > $2
fi

if [ $1 == 'wysylam' ]; then
    #cd $CATALOG_WSL
    echo "Szukam           : $2"
    SZUKANY_PLIK=$(find "$KATALOG_OBRAZOW" -name  $2 -print -quit)

    if [ -z "$SZUKANY_PLIK" ]; then
    echo "Nie mogę znaleźć : $2"
    exit
    else
    #przełącznik -N działa tylko z wersja netcat-OpenBSD
    echo "Wysyłam          : $SZUKANY_PLIK"
    pv -p -t "$SZUKANY_PLIK" | nc -N $IP_PROXMOX $PORT_PROXMOX
    fi
fi

if [ $1 == 'konwertuje' ]; then
    if [ ! -f $2 ]; then
    echo "Brak pliku: $2"
    exit
    fi

#Sprawdzamy czy nie nie ma w nazwie obrazu znaku _
NAME_DISK=$(tar tf "$2" --wildcards '*.vmdk')

if [[ "$NAME" =~ "_" ]]; then
echo "Uwaga: w nazwie maszyny "$NAME" jest znak \"_\". Zamieniam nazwe z "$NAME" na ${NAME//_/-}"
NAME=${NAME//_/-}
fi

echo Wyodrebniam plik $NAME_DISK z "$2"
tar xf "$2" "$NAME_DISK"


#Bierzemy Najwieksze ID i dodajemy kolejny numer
NEW_ID=$(qm list | awk '$1 ~ /[[:digit:]]/ {if ($1>b) (b=$1)} END{print b+1}')
#Tworzymy wirtualke
qm create $NEW_ID --name $NAME --memory 1024 --net0 virtio,bridge=vmbr0
#Importujemy dysk
qm importdisk $NEW_ID $NAME_DISK local-lvm -format qcow2
#Przypisowujemy dysk
qm set $NEW_ID --scsi0 local-lvm:vm-$NEW_ID-disk-0
#Ustawiamy w biosie bootowanie na dysk
qm set $NEW_ID --boot c --bootdisk scsi0

echo Kasuje pl $NAME_DISK
rm $NAME_DISK
#-----Ostatni komunikat


echo
echo Edytuj karte sieciową w wirtualce:
echo
echo Debian
echo sed -i \'s/enp0s3/ens18/\' /etc/network/interface
echo
echo Ubuntu
fi

```
