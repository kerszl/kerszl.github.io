#!/bin/bash

wyswietl_help ()
{
echo Wymagany jest parametr -a i -m
echo -a autor
echo -d data wydania maszyny [opcjonalnie]
echo -j jezyk [opcjonalnie]
echo -m nazwa maszyny
echo -p Poziom trudności [opcjonalnie]
echo -s system [opcjonalnie]
}

if  [ $# -lt 3 ]; then
wyswietl_help
exit
fi

SYSTEM_P="Linux"
JEZYK_P="polski"
# Chat GPT pomogł
# Pętla przetwarzająca argumenty
while [ $# -gt 0 ]; do
    case "$1" in
        -a)
            shift
            AUTOR_P="$1"
            ;;
        -d)
            shift
            DATA_P="$1"
            ;;

        -j)
            shift
            JEZYK_P="$1"
            ;;
        -m)
            shift
            MASZYNA_P="$1"
            ;;
        -p)
            shift
            POZIOM_P="$1"            
            ;;

        -s)
            shift
            SYSTEM_P="$1"
            ;;

        *)
            echo "Nieznany parametr: $1"
            wyswietl_help
            exit 1
            ;;
    esac
    shift
done

YEAR=$(date +'%Y')
Y_M_D=$(date +'%Y-%m-%d-')

#ANDROID
KATALOG="../../_posts/"
NAZWA_PLIKU=${KATALOG}${Y_M_D}${MASZYNA_P}.md
#touch $NAZWA_PLIKU
#echo $NAZWA_PLIKU
# Wyświetlenie wyników

if [[ $JEZYK_P == 'polski' ]]; then
NAZWA_N="Nazwa"
AUTOR_N="Autor"
WYPUSZCZONY_N="Wypuszczony"
SCIAGNIJ_N="Ściągnij"
POZIOM_N="Poziom"
SYSTEM_N="System"
NAUCZYSZ_N="Nauczysz się"
case "$POZIOM_P" in
1)
POZIOM_NP="Łatwy"
;;
2)
POZIOM_NP="Średni"
;;
3)
POZIOM_NP="Trudny"
;;
esac

elif [[ $JEZYK_P == 'angielski' ]]; then
NAZWA_N="Title"
AUTOR_N="Author"
WYPUSZCZONY_N="Release date"
SCIAGNIJ_N="Download from"
POZIOM_N="Level"
SYSTEM_N="System"
NAUCZYSZ_N="You'll learn"
case "$POZIOM_P" in
1)
POZIOM_NP="Easy"
;;
2)
POZIOM_NP="Medium"
;;
3)
POZIOM_NP="Hard"
;;
esac
fi

echo "---" > $NAZWA_PLIKU
echo "title: \"$MASZYNA_P - $AUTOR_P\"" >> $NAZWA_PLIKU
echo "excerpt: \" \"" >> $NAZWA_PLIKU
echo "comments: true" >> $NAZWA_PLIKU
echo "categories:" >> $NAZWA_PLIKU
echo "  - Hacking" >> $NAZWA_PLIKU
echo "  - Walkthrough" >> $NAZWA_PLIKU
echo "tags:" >> $NAZWA_PLIKU
echo "  - Hacking" >> $NAZWA_PLIKU
echo "  - Walkthrough" >> $NAZWA_PLIKU
echo "  - HackMyVM" >> $NAZWA_PLIKU
echo "  - $MASZYNA_P" >> $NAZWA_PLIKU
echo "header:" >> $NAZWA_PLIKU
echo "  overlay_image: /assets/images/pasek-hack.png" >> $NAZWA_PLIKU
echo "---" >> $NAZWA_PLIKU
echo "# $MASZYNA_P - $AUTOR_P" >> $NAZWA_PLIKU
echo "{: .text-justify}" >> $NAZWA_PLIKU
echo >> $NAZWA_PLIKU
echo "## 00. Metainfo" >> $NAZWA_PLIKU
echo >> $NAZWA_PLIKU
echo "|:----|:----|" >> $NAZWA_PLIKU
echo "|$NAZWA_N:|$MASZYNA_P|" >> $NAZWA_PLIKU
echo "|$AUTOR_N:|[$AUTOR_P](https://hackmyvm.eu/profile/?user=$AUTOR_P)|" >> $NAZWA_PLIKU
echo "|$WYPUSZCZONY_N:|$DATA_P|" >> $NAZWA_PLIKU
echo "|$SCIAGNIJ_N:|[HackMyVM](https://hackmyvm.eu/machines/machine.php?vm=$MASZYNA_P)|" >> $NAZWA_PLIKU
echo "|$POZIOM_N:|$POZIOM_NP|" >> $NAZWA_PLIKU
echo "|$SYSTEM_N:|$SYSTEM_P|" >> $NAZWA_PLIKU
echo "|$NAUCZYSZ_N:| |" >> $NAZWA_PLIKU
echo >> $NAZWA_PLIKU
echo "# 01. Wstęp" >> $NAZWA_PLIKU



exit 0

#ANDROID
PODROZ_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/assets/images/rower/$YEAR/$1"
#PC
#PODROZ_PATH="/mnt/d/moje programy i inne/GNU/kerszl.github.io/assets/images/rower/$YEAR/$1"

#ANDROID
SKRYPT_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/skrypty/"
#PC
#SKRYPT_PATH="/mnt/d/moje programy i inne/GNU/kerszl.github.io/skrypty/"

TEKST_DO_WKLEJENIA=$SKRYPT_PATH"tekst_do_wklejenia.txt"
SZABLON01="$SKRYPT_PATH"szablon01.txt
SZABLON02="$SKRYPT_PATH"szablon02.txt
SZABLON03="$SKRYPT_PATH"szablon02.txt.video

#ANDROID
POST_PATH="/data/data/com.termux/files/home/repo/kerszl.github.io/_posts/"

#PC
#POST_PATH="/mnt/d/moje programy i inne/GNU/kerszl.github.io/_posts/"

#1 etap - sprawdzanie katalogow