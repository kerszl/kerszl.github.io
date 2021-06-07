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
Czemu serwer na obrazy do pentestów wybrałem XCP-ng, który sprawia tyle problemów, a nie wypróbowany VMware ESXi? Przypomnę, że oba są darmowe. Powód jest jeden. Po prostu na VMware obrazy w formacie [OVA](https://pl.wikipedia.org/wiki/Open_Virtualization_Format) nie chciały się importować. Niby otwarty format, a jednak bywają problemy. Ova najlepiej działa na Virtualbox, ale nie będę sobie systemu zaśmiecał, skoro do tego celu kupiłem HP EliteDesk 800 G1 DM. Co prawda dokupiłem 8 GB ramu, bo XCP-ng dostawał zadyszki przy 3-4 wirtualkach, ale niestety takie są wady tego systemu. Na VMware mołgbym i 10 odpalić i nie byłoby problemu. Po prostu ten system lepiej zarządza pamięcią. Wracając do XCP-ng zauważyłem, że niektóre wirtualki się instalują, jednak nie każdej jest przypisywany adres z DHCP. Na Vulnhubie, większość (a przynajmniej się nie spotkałem) obrazów przydziela adres z automatu, czyli z DHCP. Głównie są to nowsze wirtualki,Debian, Ubuntu, na starym Centosie zazwyczaj poszło bez problemu.

# Gmeranie czas zacząć
Nie spodobało mi się to. Jak się włamać na coś, co nawet nie ma swojego adresu ip? Więc włammy się na jakiś obraz. **Ofiarą** tym razem będzie [recon: 1](https://www.vulnhub.com/entry/recon-1,438/). W opisie obrazu jest wzmianka o automatycznym przypisaniu IP, jednak po zainstalowaniu nie widzimy nowego maka. (Mała dygresja. Jakiś czas temu wyszedł XCP-ng z numerem 8.2. Jednak nie wiadomo czemu, ale obrazy wirtualne się wrzucały na niego masakrycznie długo. Wróciłem więc do wersji 8.1). Brak przyznania ip wiąże się niestety z problemem nazewnistwa interfejsów sieciowych. To co pod VMware działa bezbłędnie, tutaj niestety nie do końca. Tam ISO-a odpalają się normalnie, niezależnie czy to jest eth0, czy enp0s, czy jakieś inne cuda. Takie to są skutki zastąpienia sterej dobrej nazwy w stylu eth(x) w jakiś dziwoląg typu enp0s3. Wiem, że w niektórych sytuacjach jest to przydatne i odchodzi się od nazewnictwa eth(x). Zwłaszcza w chmurze, ale u nas przez to są problemy. 

## Jak zmienić nazwę interfejsu sieciowego na eth0
Podczas startu systemu powinno się nam pokazać okno Grub-a. Jeżeli się nie pojawi trzymamy przycisk **SHIFT**. 
![grub](/assets/images/xcp-ng-i-vulnhub/01.png)
Następnie klawisz **e** i szukamy wpis gdzie zazwyczaj na początku jest Linux, na końcu RO, chociaż nie jest to regułą. U nas to będzie

``` linux  /boot/vmlinuz-4.4.0-142-generic root=UUID=ed440236-4e13-4670-... ro```

Zamieniamy na 

``` linux  /boot/vmlinuz-4.4.0-142-generic root=UUID=ed440236-4e13-4670-80d6-7617e64... rw init=/bin/bash```

klawisz **F10** i mamy root-a

![grub](/assets/images/xcp-ng-i-vulnhub/02.png)

Patrzymy jaki to jest system

```cat /etc/network/interface```

Wychodzi, że Ubuntu 16.04. Więc ustawienie sieciówek jest prawdopodobnie w ```/etc/network/interface```
_Uwaga, czasami ustawienie sieciówek jest ```/etc/netplan/*.yml``` Tam przy edycji należy uważać z odstępami, nie robić tabów, tylko
spacje. I to ma być równe. Kiedyś, kiedy nie znałem Yaml-a wywalał mi się konfig i nie wiedziałem czemu._

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

Ps. Taki sposób trochęnam  ułatwia włamanie się na serwer. Jednak to jest zabawa i sądzę, że robisz to tylko po to, żeby dobrze ustawić nazwę karty sieciowej.
