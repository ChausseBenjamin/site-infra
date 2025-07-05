#!/bin/sh

dir=$1

if [ -z "$dir" ]; then
  echo "Usage: $0 /path/to/dir"
  exit 1
fi

# Find all *.jpg starting with lr- in the given dir (non-recursive)
for f in "$dir"/lr-*.jpg; do
  [ -e "$f" ] || continue
  printf 'Converting %s: ' "$f"
  if magick "$f" -interlace Plane "$f"; then
    printf 'Success\n'
  else
    printf 'Failure\n'
  fi
done
