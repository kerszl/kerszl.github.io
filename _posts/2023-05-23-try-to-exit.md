---
title: "Try to exit"
comments: true
categories:  
  - Hacking
tags:
  - exit
  - infinity loop
  - funky
gallery1:
  - url: /assets/images/hacking/2023/01/01.jpg
    image_path: /assets/images/hacking/2023/01/01.jpg  
---
# Wstęp
Trochę ten artykuł jest żartobliwy, bo z hakingiem to jednak ma mało wspólnego, ale może kogoś wkurzyć.
{: .text-justify}

# Przygotowanie

## Serwer1
Wchodzimy na serwer i generujemy, jeżeli nie mamy, klucz komendą: 
```bash
ssh-keygen
```
potem wrzucamy klucz na serwer2 komendą:
```bash
ssh-copy-id user@serwer2 
```
potwierdzamy wszystko.
{: .text-justify}

## Serwer2
Wchodzimy na serwer i generujemy, jeżeli nie mamy, klucz komendą: 
```bash
ssh-keygen
```
potem wrzucamy klucz na serwer1 komendą:
```bash
ssh-copy-id user@serwer1 
```
potwierdzamy wszystko.
{: .text-justify}

# Działanie
Na pierwszym serwerze (serwer1) odpalamy komendę:
```bash
while true; do ssh -t user@serwer2 ssh -t user@serwer1; done
```

Życzę udanego wyjścia :smile:
{% include gallery id="gallery1" %}
