---
title: "XCP-ng i obrazy z Vulnhub"
excerpt: "XCP-ng i Vulnhub"
comments: true
categories:
  - Vulnhub
tags:
  - Hacking
  - Vulnhub
  - XCP-ng
header:
  overlay_image: /assets/images/pasek.png
---
# Wstęp
## Czemu serwer na obrazy do pentestów wybrałem XCP-ng?
XCP-ng sprawia dużo problemów, a VMware ESXi jest prawie bezbłędny(?) Przypomnę, że oba są darmowe. Powód jest jeden. Po prostu na VMware obrazy w formacie [OVA](https://pl.wikipedia.org/wiki/Open_Virtualization_Format) nie chciały się importować. Niby to jest otwarty format, a jednak bywają problemy. OVA najlepiej działa na Virtualbox, ale nie będę sobie systemu zaśmiecał, skoro do tego celu kupiłem **HP EliteDesk 800 G1 DM**. Co prawda dokupiłem 8 GB ramu, bo XCP-ng dostawał zadyszki przy 3-4 wirtualkach, ale niestety takie są wady tego systemu. Na VMware mółgbym, i odpalić 10 obrazów, i nie byłoby problemu. Po prostu VM lepiej zarządza pamięcią. Wracając do XCP-ng zauważyłem, że nie wszystkie wirtualki, które się instalują, mają przypisany adres z DHCP. Na Vulnhubie, większość (a przynajmniej się nie spotkałem) obrazów przydziela adres sieciowy z automatu, czyli z DHCP. Systemy, które mają ten problem są zazwyczaj nowszymi obrazami (wpis na rok 2021): Debian, Ubuntu. Na starym Centosie zazwyczaj obywało się bez problemów.

# Gmeranie czas zacząć
Nie spodobało mi się to, że nie widzę ip serwera. Jak włamać się na coś, co nawet nie ma swojego adresu? Żeby zilustrować sytuację przetestujmy jakiś obraz. **Ofiarą** tym razem będzie [recon: 1](https://www.vulnhub.com/entry/recon-1,438/). W opisie obrazu jest wzmianka o automatycznym przypisaniu IP, jednak po zainstalowaniu i rekonensansie nie widzimy nowego maka. (Mała dygresja. Jakiś czas temu wyszedł XCP-ng z numerem 8.2. Nie wiadomo czemu, ale obrazy wirtualne wrzucały się na niego masakrycznie długo. Wróciłem więc do wersji 8.1). Pomyślałem, że brak przyznania ip może wiązać się z problemem nazewnictwa interfejsów sieciowych. To co pod VMware działa bezbłędnie, tutaj niestety nie do końca. Na VMware ISO-a odpalają się normalnie, niezależnie czy to jest eth0, czy enp0s, czy jakieś inne cuda. Takie to są skutki zastąpienia starej dobrej nazwy w stylu eth(x) w jakiś dziwoląg typu enp0s3. Wiem, że w niektórych sytuacjach to nazewnictwo jest przydatne i odchodzi się od eth(x, zwłaszcza w chmurze, ale na XCP-ng są przez to problemy. 

## Jak zmienić nazwę interfejsu sieciowego na eth0
Pozostaje nam zmienić nazwę sieciówki. Podczas startu systemu powinno się nam pokazać okno Grub-a. Jeżeli się nie pojawi, to trzymamy przycisk **SHIFT**. 
![grub](/assets/images/xcp-ng-i-vulnhub/01.png)
Następnie klawisz **e** i szukamy wpis, gdzie zazwyczaj na początku jest Linux, na końcu RO, chociaż nie jest to regułą. U nas to będzie

``` 
linux  /boot/vmlinuz-4.4.0-142-generic root=UUID=ed440236-4e13-4670-... ro
```

```ro``` Zamieniamy na ```rw init=/bin/bash```. Wygląda to mnie więcej tak:

```
linux  /boot/vmlinuz-4.4.0-142-generic root=UUID=ed440236-4e13-4670-80d6-7617e64... rw init=/bin/bash
```

klawisz **F10** i po chwili ładuje się konsola do root-a

![grub](/assets/images/xcp-ng-i-vulnhub/02.png)

Sprawdzamy jaki to jest system

```
cat /etc/os-release
```

Wychodzi, że to jest Ubuntu 16.04. Więc ustawienie sieciówek jest prawdopodobnie w ```/etc/network/interface```

_Mała uwaga: czasami ustawienie sieciówek jest ```/etc/netplan/*.yml```. Tam przy edycji należy uważać z odstępami; nie robić tabów, tylko
spacje. I mają być równe odstępy. Kiedyś, kiedy nie znałem Yaml-a wywalał mi się konfig i nie wiedziałem czemu._

```
cat /etc/network/interface

auto enp0s3
iface enp0s3 inet dhcp
```

Zamieniamy enp0s3 na eth0, potem trzeba wyedytować Grub-a

```
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
```

Wrzucić konfig w odpowiednie miejsce

```
grub-mkconfig -o /boot/grub/grub.cfg
```

Ps. Taki sposób trochę nam ułatwia włamanie się na serwer. Jednak to jest zabawa i sądzę, że robisz to tylko po to, żeby dobrze ustawić nazwę karty sieciowej, a na serwer się włamiesz metodą przewidzianą przez twórców.

# Koniec
Jak się podobał ten wpis, pomógł Ci,  wpisz jakiś komentarz, lub napisz mejla.
