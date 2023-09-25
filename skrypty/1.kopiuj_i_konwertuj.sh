#!/bin/bash

if [ $# -le 0 ]; then
echo parametr to nazwa wycieczki, np "1daytrip"
exit
fi
YEAR=$(date +'%Y')



PICTURES_BLOG_PATH='/data/data/com.termux/files/home/storage/pictures/blog'
PODROZ_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/assets/images/rower/$YEAR/$1"

echo $PODROZ_PATH
exit
count=1

if [ -f "$PODROZ_PATH"/$1/01.jpg ]; 
then

	echo uwaga sa pliki z obrazkami, skasuj recznie
	exit
fi



echo zmienian nazwy na cyfry i kopiuje do $1
for i in "$PICTURES_BLOG_PATH"/*.jpg "$PICTURES_BLOG_PATH"/*.JPG

do
	newfile=$(printf "%02d.jpg" $count)
	((count++))
	cp -f $i "$PODROZ_PATH"/$1/$newfile
done

echo redukuje rozmiar do 30%


for i in "$PODROZ_PATH/$1"/*.jpg
do                                                 
convert  $i -resize 30% $i
                                                        done

							echo kopiuje mapke  - mapka.png
							cp -f $PICTURES_BLOG_PATH/*.png "$PODROZ_PATH/$1"/mapka.png

