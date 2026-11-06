#!/bin/bash
# Extract a page range from a PDF into a new file
# Usage: pdfslice <input.pdf> <start> <end> [output.pdf]

set -e

usage() {
  echo "Usage: pdfslice <input.pdf> <start_page> <end_page> [output.pdf]" >&2
  echo "  Pages are 1-indexed." >&2
  echo "  Output defaults to <input>_p<start>-<end>.pdf" >&2
  exit 1
}

[ $# -lt 3 ] && usage

INPUT="$1"
START="$2"
END="$3"

[ ! -f "$INPUT" ] && { echo "Error: file not found: $INPUT" >&2; exit 1; }
[[ "$START" =~ ^[0-9]+$ ]] || { echo "Error: start page must be a number" >&2; exit 1; }
[[ "$END" =~ ^[0-9]+$ ]]   || { echo "Error: end page must be a number" >&2; exit 1; }
[ "$START" -gt "$END" ]    && { echo "Error: start ($START) > end ($END)" >&2; exit 1; }

if [ -n "$4" ]; then
  OUTPUT="$4"
else
  BASE="${INPUT%.pdf}"
  OUTPUT="${BASE}_p${START}-${END}.pdf"
fi

gs -q -dNOPAUSE -dBATCH -dSAFER \
   -sDEVICE=pdfwrite \
   -dFirstPage="$START" \
   -dLastPage="$END" \
   -sOutputFile="$OUTPUT" \
   "$INPUT"

echo "$OUTPUT"
