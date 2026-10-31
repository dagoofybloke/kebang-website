#!/bin/bash
cd "$(dirname "$0")/.." || exit 1

if [ ! -f src/data/bulletinCategories.js ]; then
  echo "Bulletin setup not found. Run the Bulletin setup first."
  exit 1
fi
mkdir -p src/bulletins public/bulletin

mapfile -t CATS < <(grep -o "name: *'[^']*'" src/data/bulletinCategories.js | sed -E "s/name: *'([^']*)'/\1/")
if [ ${#CATS[@]} -eq 0 ]; then
  echo "No categories found in src/data/bulletinCategories.js"
  exit 1
fi

echo "Category:"
for i in "${!CATS[@]}"; do
  echo "  $((i+1))) ${CATS[$i]}"
done
read -rp "Enter number: " cnum
if ! [[ "$cnum" =~ ^[0-9]+$ ]] || [ "$cnum" -lt 1 ] || [ "$cnum" -gt "${#CATS[@]}" ]; then
  echo "Please enter a number from the list."
  exit 1
fi
category="${CATS[$((cnum-1))]}"

read -rp "Title: " title
if [ -z "$title" ]; then
  echo "Title cannot be empty."
  exit 1
fi

today=$(date +%F)
read -rp "Date (YYYY-MM-DD) [$today]: " bdate
bdate="${bdate:-$today}"
if ! [[ "$bdate" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Date must look like 2026-11-15."
  exit 1
fi

echo "Show as:  1) Text post   2) Image post (picture instead of text)"
read -rp "Enter 1 or 2 [1]: " kind
display="text"
[ "$kind" = "2" ] && display="image"

safe_name() {
  basename "$1" | tr 'A-Z' 'a-z' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9._-]//g'
}

copy_asset() {
  local src="$1"
  src="${src%\"}"; src="${src#\"}"; src="${src%\'}"; src="${src#\'}"
  if [ ! -f "$src" ]; then
    echo "File not found: $src" >&2
    return 1
  fi
  local name
  name=$(safe_name "$src")
  local dest="public/bulletin/$name"
  if [ -e "$dest" ] && [ "$(realpath "$src")" != "$(realpath "$dest")" ]; then
    echo "NOTE: public/bulletin/$name already exists, using that file." >&2
  elif [ "$(realpath "$src")" != "$(realpath -m "$dest")" ]; then
    cp "$src" "$dest" && echo "COPIED: $dest" >&2
  fi
  echo "$name"
}

image=""
if [ "$display" = "image" ]; then
  read -rp "Path to the image (upload it to the Codespace first): " ipath
  if [ -z "$ipath" ]; then
    echo "An image post needs an image."
    exit 1
  fi
  image=$(copy_asset "$ipath") || exit 1
else
  read -rp "Picture to show inside the post (press Enter to skip): " ipath
  if [ -n "$ipath" ]; then
    image=$(copy_asset "$ipath") || exit 1
  fi
fi

read -rp "Attach a PDF or other file (press Enter to skip): " fpath
file=""
if [ -n "$fpath" ]; then
  file=$(copy_asset "$fpath") || exit 1
fi

read -rp "Pin to the top? (y/N): " pin
pinned="no"
[[ "$pin" =~ ^[Yy] ]] && pinned="yes"

button=""
if [ "$display" = "image" ]; then
  read -rp "Button label [View achievement]: " button
fi

echo ""
echo "Now type the text. The first paragraph is the short summary shown in the feed."
echo "Leave a blank line between paragraphs. When finished, type END on a line by itself."
echo "(For an image post you can type just END to skip the text.)"
body=""
while IFS= read -r line; do
  [ "$line" = "END" ] && break
  body+="$line"$'\n'
done

slug=$(echo "$title" | tr 'A-Z' 'a-z' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' | cut -c1-50)
[ -z "$slug" ] && slug="bulletin"
out="src/bulletins/$bdate-$slug.txt"
if [ -e "$out" ]; then
  echo "$out already exists. Change the title or date."
  exit 1
fi

{
  echo "Title: $title"
  echo "Date: $bdate"
  echo "Category: $category"
  echo "Display: $display"
  echo "Image: $image"
  echo "File: $file"
  echo "Pinned: $pinned"
  echo "Button: $button"
  echo ""
  printf '%s' "$body"
} > "$out"

echo ""
echo "CREATED: $out"
echo "Check it at /bulletin, then push:"
echo "  git add -A && git commit -m \"Add bulletin: $title\" && git push origin main"
