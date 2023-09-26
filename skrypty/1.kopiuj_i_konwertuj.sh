#!/bin/bash

YEAR=$(date +'%Y')
PICTURES_BLOG_PATH='/data/data/com.termux/files/home/storage/pictures/blog'
#PODROZ_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/assets/images/rower/$YEAR/$1"
PODROZ_PATH="/mnt/d/moje programy i inne/GNU/kerszl.github.io/assets/images/rower/$YEAR/$1"



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


if [ -f "$PODROZ_PATH"/$2/01.jpg ]; 
then
	echo Uwaga: sa pliki z obrazkami, skasuj recznie
	exit
fi

if [ ! -d "$PODROZ_PATH/$2" ]; then
mkdir "$PODROZ_PATH/$2"
fi

SCIEZKA_WIELKIEJ_PODROZY="$PODROZ_PATH/$2"


Y_M_D=$(date +'%Y-%m-%d-')
PLIK_MD=$Y_M_D$1"-"$2".md"
echo $PLIK_MD

exit

./2.edytuj_post.sh $SCIEZKA_WIELKIEJ_PODROZY
exit

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

