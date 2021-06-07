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
Nie spodobało mi się to. Jak się włamać na coś, co nawet nie ma swojego adresu ip? Więc włammy się na jakiś obraz. **Ofiarą** tym razem będzie [recon: 1](https://www.vulnhub.com/entry/recon-1,438/). W opisie obrazu jest wzmianka o automatycznym przypisaniu IP, jednak po zainstalowaniu nie widzimy nowego maka. (Mała dygresja. Jakiś czas temu wyszedł XCP-ng z numerem 8.2. Jednak nie wiadomo czemu, ale obrazy wirtualne się wrzucały na niego masakrycznie długo. Wróciłem więc do wersji 8.1) 
