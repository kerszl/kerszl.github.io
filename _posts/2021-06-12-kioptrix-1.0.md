---
title: "Jak uruchomić Kioptrix: Level 1.0 (#1) na XCP-ng "
excerpt: " "
comments: true
categories:
  - Vulnhub
tags:
  - Hacking
  - Vulnhub
header:
  overlay_image: /assets/images/pasek.png
---
# Wstęp
Tym razem nie będę opisywał, jak się włamać na [Kioptrix: Level 1.0](https://www.vulnhub.com/entry/kioptrix-level-1-1,22/), ale jak go w ogóle poprawnie uruchomić na **XCP-NG**. Jest to dosyć stary system, Pierwszy wpis o nim jest z **17 Feb 2010**, ale kernel jest jeszcze starszy. System bazuje Redhacie. Niestety po uruchomieniu systemu karta sieciowa nie jest widoczna. Próbowałem wejść przez GRUB-a, ale po prostu nie mogłem. Za szybko znika ekran z oknem GRUB-a. Trzeba więc to zrobić inną metodą.
## Podpinamy dysk
