#plik był w katalogu _posts
dzien=1
for i in {03..31}
do
sed '2s/Dzień:/Dzień: '$dzien'/; 16,$s/wielka_podroz\/01/wielka_podroz\/'$i/ 2023-08-wielka-podroz-szablon.md > 2023-08-$i-wielka-podroz.md
((dzien++))
done

echo android
