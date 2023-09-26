#!/bin/bash

#MAIN_PATH='/data/data/com.termux/files/home/repo/kerszl.github.io/skrypty/'
MAIN_PATH='/mnt/d/moje programy i inne/GNU/kerszl.github.io/skrypty/'
TEKST_DO_WKLEJENIA=$MAIN_PATH"tekst_do_wklejenia.txt"
SZABLON01="$MAIN_PATH"szablon01.txt
SZABLON02="$MAIN_PATH"szablon02.txt
SZABLON03="$MAIN_PATH"szablon03.txt


echo --- > wywalic1.txt
echo -n "title: " >> wywalic1.txt
sed -n '1{s/.*/"&"/p}' tekst_do_wklejenia.txt >> wywalic1.txt
cat "$SZABLON01" >> wywalic1.txt


katalog="/mnt/d/moje programy i inne/GNU/kerszl.github.io/assets/images/rower/2023/1daytrip/02/"
katalog2=("$katalog"*.jpg)


for plik in "${katalog2[@]}"; do
echo -n "  - url: " >> wywalic1.txt
echo ${plik/*kerszl.github.io/} >> wywalic1.txt
echo -n "    image_path: " >> wywalic1.txt
echo ${plik/*kerszl.github.io/} >> wywalic1.txt
done

echo "---" >> wywalic1.txt
cat "$SZABLON02" >> wywalic1.txt
echo "[![mapka]("${katalog/*kerszl.github.io/}"mapka.png)]" >> wywalic1.txt
echo >> wywalic1.txt
sed '1d;2,${/[[:alpha:]]/,$!d};s/^$/{: .text-justify}/'  "$TEKST_DO_WKLEJENIA" >> wywalic1.txt
cat "$SZABLON03" >> wywalic1.txt


exit

echo $TEKST_DO_WKLEJENIA


if [ $# -ne 2 ]; then
echo parametr to cala sciezka do obrazkow i nazwa_pliku bloga
echo uzyj ./kopiuj_i_konwertuj ...
exit
fi

exit


sciezka="/data/data/com.termux/files/home/repo/kerszl.github.io/_posts/"
plik="2023-08-$1-wielka-podroz-$1.md"

vim $sciezka$plik

