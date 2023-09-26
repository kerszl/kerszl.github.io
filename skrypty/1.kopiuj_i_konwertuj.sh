#!/bin/bash

YEAR=$(date +'%Y')

#ANDROID
PICTURES_BLOG_PATH='/data/data/com.termux/files/home/storage/pictures/blog'

#ANDROID
PODROZ_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/assets/images/rower/$YEAR/$1"
#PC
#PODROZ_PATH="/mnt/d/moje programy i inne/GNU/kerszl.github.io/assets/images/rower/$YEAR/$1"

#ANDROID
SKRYPT_PATH='/data/data/com.termux/files/home/repo/kerszl.github.io/skrypty/'
#PC
#SKRYPT_PATH='/mnt/d/moje programy i inne/GNU/kerszl.github.io/skrypty/'

TEKST_DO_WKLEJENIA=$SKRYPT_PATH"tekst_do_wklejenia.txt"
SZABLON01="$SKRYPT_PATH"szablon01.txt
SZABLON02="$SKRYPT_PATH"szablon02.txt

#ANDROID
POST_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/_posts/"

#PC
#POST_PATH="/mnt/d/moje programy i inne/GNU/kerszl.github.io/_posts/"

#1 etap - sprawdzanie katalogow

if [ $# -eq 1 ]; then
	if [ ! -d "$PODROZ_PATH" ]; then
		echo "Nie ma katalogu $PODROZ_PATH"		
	else
	  echo zawartosc "$PODROZ_PATH"
	  ls -lah "$PODROZ_PATH"
	fi
exit	
fi	


if [ $# -ne 2 ]; then
echo Parametry to [nazwa wycieczki][katalog]
plik=$(basename "$0")
echo './'$plik "1daytrip     -" wyswietla zawartosc "1daytrip"
echo './'$plik "1daytrip  01 -" tworzy katalog
exit
fi

grep -q ^[0-9][0-9]$ <<< $2
if (($?!=0));then
echo Katalog powinien skladac sie z dwoch cyfr np: "01"
exit
fi


if [ ! -d "$PODROZ_PATH/$2" ]; then
mkdir "$PODROZ_PATH/$2"
fi


if [ -f "$PODROZ_PATH"/$2/01.jpg ]; 
then
	echo Uwaga: sa pliki z obrazkami, skasuj recznie
	exit
fi





#2 etap
count=1

echo zmienian nazwy na cyfry i kopiuje do $1
for i in "$PICTURES_BLOG_PATH"/*.jpg "$PICTURES_BLOG_PATH"/*.JPG

do
	newfile=$(printf "%02d.jpg" $count)
	((count++))
	cp -f $i "$PODROZ_PATH"/$2/$newfile
done

echo redukuje rozmiar do 30%


for i in "$PODROZ_PATH/$2"/*.jpg
do                                                 
	convert  $i -resize 30% $i
done

echo kopiuje mapke  - mapka.png
cp -f $PICTURES_BLOG_PATH/*.png "$PODROZ_PATH/$2"/mapka.png


#---3 etap
#przeniesc na koniec - poczatek

SCIEZKA_WIELKIEJ_PODROZY="$PODROZ_PATH/$2/"

if [ ! "$(ls -A "$SCIEZKA_WIELKIEJ_PODROZY")" ]; then
    echo "Brak plikow w $SCIEZKA_WIELKIEJ_PODROZY"
	exit
fi	
	

Y_M_D=$(date +'%Y-%m-%d-')
PLIK_MD=$Y_M_D$1"-"$2".md"
POST_FILE_PATH="$POST_PATH$PLIK_MD"

echo Tworze i edytuje plik: "$POST_FILE_PATH"


echo --- > "$POST_FILE_PATH"
echo -n "title: " >> "$POST_FILE_PATH"
sed -n '1{s/.*/"&"/p}' "$TEKST_DO_WKLEJENIA" >> "$POST_FILE_PATH"
cat "$SZABLON01" >> "$POST_FILE_PATH"

OBRAZKI_JPG=("$SCIEZKA_WIELKIEJ_PODROZY"*.jpg)


for plik in "${OBRAZKI_JPG[@]}"; do
echo -n "  - url: " >> "$POST_FILE_PATH"
echo ${plik/*kerszl.github.io/} >> "$POST_FILE_PATH"
echo -n "    image_path: " >> "$POST_FILE_PATH"
echo ${plik/*kerszl.github.io/} >> "$POST_FILE_PATH"
done

echo "---" >> "$POST_FILE_PATH"
echo '<!---'>> "$POST_FILE_PATH"
echo '<a href="https://connect.garmin.com/modern/activity/embed/wpisz_numer" onclick="window.open(this.href); return false;">' >> "$POST_FILE_PATH"
echo "![mapka]("${SCIEZKA_WIELKIEJ_PODROZY/*kerszl.github.io/}"mapka.png)" >> "$POST_FILE_PATH"
echo '</a>' >> "$POST_FILE_PATH"
echo '-->'>> "$POST_FILE_PATH"

echo "[![mapka]("${SCIEZKA_WIELKIEJ_PODROZY/*kerszl.github.io/}"mapka.png)]" >> "$POST_FILE_PATH"
echo >> "$POST_FILE_PATH"
sed '1d;2,${/[[:alpha:]]/,$!d};s/^$/{: .text-justify}/'  "$TEKST_DO_WKLEJENIA" >> "$POST_FILE_PATH"
cat "$SZABLON02" >> "$POST_FILE_PATH"


sed -i "s/NAZWA_SPECJALNA_WYCIECZKI/$1/" "$POST_FILE_PATH"


