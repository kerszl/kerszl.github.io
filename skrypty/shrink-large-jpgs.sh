#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Uzycie: $0 KATALOG"
  echo "Przyklad: $0 assets/images/rower/2024/1daytrip/01"
  exit 1
fi

ROOT_DIR="$1"
LIMIT_KB=500
LIMIT_BYTES=$((LIMIT_KB * 1024))
SCALE="90%"

if ! command -v convert >/dev/null 2>&1; then
  echo "ERROR: Brak ImageMagick. Zainstaluj pakiet z komenda: sudo apt install imagemagick"
  exit 1
fi

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "ERROR: Katalog nie istnieje: $ROOT_DIR"
  exit 1
fi

echo "Skanuje katalog: $ROOT_DIR"
echo "Limit: ${LIMIT_KB} KB"
echo

find "$ROOT_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 |
while IFS= read -r -d '' file; do
  size=$(stat -c '%s' "$file")

  if (( size <= LIMIT_BYTES )); then
    echo "OK: $file ($(numfmt --to=iec --suffix=B "$size"))"
    continue
  fi

  echo "DUZY: $file ($(numfmt --to=iec --suffix=B "$size"))"

  iteration=0

  while (( size > LIMIT_BYTES )); do
    iteration=$((iteration + 1))
    tmp="${file}.tmp.jpg"

    echo "  [$iteration] zmniejszam do ${SCALE} aktualnego rozmiaru..."

    convert "$file" \
      -auto-orient \
      -resize "$SCALE" \
      -strip \
      -quality 85 \
      "$tmp"

    old_size="$size"
    new_size=$(stat -c '%s' "$tmp")

    if (( new_size >= old_size )); then
      echo "  UWAGA: plik po zmniejszeniu nie jest mniejszy (${new_size} >= ${old_size}), przerywam dla tego pliku"
      rm -f "$tmp"
      break
    fi

    mv "$tmp" "$file"
    size="$new_size"

    echo "  nowy rozmiar: $(numfmt --to=iec --suffix=B "$size")"
  done

  if (( size <= LIMIT_BYTES )); then
    echo "GOTOWE: $file ($(numfmt --to=iec --suffix=B "$size"))"
  else
    echo "NADAL DUZY: $file ($(numfmt --to=iec --suffix=B "$size"))"
  fi

  echo
done

echo "Koniec."
