#!/bin/bash

if [ $# -le 0 ]; then
echo parametr to dzien blogu, np 03
exit
fi

sciezka="/data/data/com.termux/files/home/repo/kerszl.github.io/_posts/"
plik="2023-08-$1-wielka-podroz-$1.md"

vim $sciezka$plik

