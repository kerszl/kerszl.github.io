#!/bin/bash

if [ $# -le 0 ]; then
echo parametr to dzien blogu, np 03
exit
fi

PICTURES_BLOG_PATH='/data/data/com.termux/files/home/storage/pictures/blog'
WIELKA_PODROZ_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/assets/images/rower/2023/wielka_podroz"
	count=1

if [ -f "$WIELKA_PODROZ_PATH"/$1/01.jpg ]; 
then

	echo uwaga sa pliki z obrazkami, skasuj recznie
	exit
fi



echo zmienian nazwy na cyfry i kopiuje do $1
for i in "$PICTURES_BLOG_PATH"/*.jpg "$PICTURES_BLOG_PATH"/*.JPG

do
	newfile=$(printf "%02d.jpg" $count)
	((count++))
	cp -f $i "$WIELKA_PODROZ_PATH"/$1/$newfile
done

echo redukuje rozmiar do 30%


for i in "$WIELKA_PODROZ_PATH/$1"/*.jpg
do                                                 
convert  $i -resize 30% $i
                                                        done

							echo kopiuje mapke  - mapka.png
							cp -f $PICTURES_BLOG_PATH/*.png "$WIELKA_PODROZ_PATH/$1"/mapka.png

