#!/bin/bash
cd "$(dirname "$0")/.." || exit 1

if [ ! -f src/data/documents.js ]; then
  echo "src/data/documents.js not found."
  exit 1
fi

echo "Which section is this document for?"
echo "  1) Election Documents"
echo "  2) Administration-related Documents"
echo "  3) Use of Funds"
echo "  4) Projects"
echo "  5) Events"
echo "  6) Organisational Documents"
read -rp "Enter 1-6: " choice

case "$choice" in
  1) section="election" ;;
  2) section="administrative" ;;
  3) section="funds" ;;
  4) section="projects" ;;
  5) section="events" ;;
  6) section="organisational" ;;
  *) echo "Please run again and enter a number from 1 to 6."; exit 1 ;;
esac

read -rp "Document title (as shown on the website): " title
if [ -z "$title" ]; then
  echo "Title cannot be empty."
  exit 1
fi

read -rp "Path to the file (upload it to the Codespace first, then type its path): " src
src="${src%\"}"; src="${src#\"}"; src="${src%\'}"; src="${src#\'}"
if [ ! -f "$src" ]; then
  echo "File not found: $src"
  exit 1
fi

read -rp "Date (YYYY-MM-DD, or press Enter to skip): " docdate
if [ -n "$docdate" ] && ! [[ "$docdate" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Date must look like 2026-10-01."
  exit 1
fi

fname=$(basename "$src" | tr 'A-Z' 'a-z' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9._-]//g')
if [ -z "$fname" ]; then
  echo "Could not make a safe file name from: $src"
  exit 1
fi

dest="public/documents/$section/$fname"
mkdir -p "public/documents/$section"

if [ -e "$dest" ] && [ "$(realpath "$src")" != "$(realpath "$dest")" ]; then
  echo "A file named $fname already exists in $section. Rename your file or delete the old one first."
  exit 1
fi

if [ "$(realpath "$src")" != "$(realpath -m "$dest")" ]; then
  cp "$src" "$dest" || { echo "Could not copy the file."; exit 1; }
  echo "COPIED: $dest"
else
  echo "File is already in place: $dest"
fi

SECTION="$section" TITLE="$title" FNAME="$fname" DOCDATE="$docdate" python3 << 'PY'
import os, re, sys

section = os.environ['SECTION']
title = os.environ['TITLE']
fname = os.environ['FNAME']
date = os.environ.get('DOCDATE', '')

path = 'src/data/documents.js'
with open(path, encoding='utf-8') as f:
    text = f.read()

def q(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'") + "'"

i = text.find("id: '%s'" % section)
if i == -1:
    sys.exit('Section "%s" not found in documents.js. Nothing changed.' % section)

j = text.find('documents: [', i)
if j == -1:
    sys.exit('No documents list found for "%s". Nothing changed.' % section)

start = j + len('documents: [')
rest = text[start:]

if rest.lstrip().startswith(']'):
    end = start + (len(rest) - len(rest.lstrip()))
else:
    m = re.search(r'\n[ \t]*\]', rest)
    if not m:
        sys.exit('Could not find the end of the list. Nothing changed.')
    end = start + m.end() - 1

inner = text[start:end]

parts = ['title: ' + q(title), 'file: ' + q(fname)]
if date:
    parts.append('date: ' + q(date))
entry = '{ ' + ', '.join(parts) + ' },'

if inner.strip() == '':
    new_inner = '\n      ' + entry + '\n    '
else:
    body = inner.rstrip()
    if not body.endswith(','):
        body += ','
    new_inner = body + '\n      ' + entry + '\n    '

text = text[:start] + new_inner + text[end:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('ADDED to src/data/documents.js: ' + entry)
PY

if [ $? -ne 0 ]; then
  echo "The file was copied but the list was not updated. Add the entry by hand in src/data/documents.js."
  exit 1
fi

echo ""
echo "Done. Check /documents in the browser, then push:"
echo "  git add -A && git commit -m \"Add document: $title\" && git push origin main"
