#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
md2pdf.sh [-o output.pdf] input.md

Converts Markdown to PDF with Pandoc.
Defaults to basename of input with .pdf if -o not provided.

Features:
  - Obsidian-style image embeds: ![[file.png]], ![[file.png|200]], ![[file.png|200x120]], ![[file.png|Alt text]]
  - TOC, numbered sections, syntax highlighting (breezeDark)
  - 1in margins, clickable links
  - Auto-fix for \tightlist
  - Auto-select PDF engine: tectonic -> xelatex -> lualatex
  - Resource search path: ., file's dir, assets, attachments, img

Examples:
  md2pdf.sh README.md
  md2pdf.sh -o paper.pdf paper.md
USAGE
}

# --- parse args ---
out_file=""
while getopts ":o:h" opt; do
  case "$opt" in
    o) out_file="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 2 ;;
  esac
done
shift $((OPTIND-1))

if [[ $# -ne 1 ]]; then
  usage; exit 2
fi

in_file="$1"
if [[ ! -f "$in_file" ]]; then
  echo "Input file not found: $in_file" >&2; exit 1
fi
if [[ -z "$out_file" ]]; then
  base="${in_file%.*}"
  out_file="${base}.pdf"
fi

# --- prerequisites ---
if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc is required but not found in PATH." >&2
  exit 1
fi

pandoc_version=$(pandoc -v | awk 'NR==1{print $2}')
ver_ge() { printf "%s\n%s\n" "$1" "$2" | sort -V | head -n1 | grep -qx "$2"; }

# Highlighting flag (Pandoc >= 3.8 -> --syntax-highlighting)
highlight_style="breezeDark"
if ver_ge "$pandoc_version" "3.8"; then
  HL_FLAG=( --syntax-highlighting="$highlight_style" )
else
  HL_FLAG=( --highlight-style="$highlight_style" )
fi

# PDF engine preference
if command -v lualatex >/dev/null 2>&1; then
  PDF_ENGINE="lualatex"
elif command -v xelatex >/dev/null 2>&1; then
  PDF_ENGINE="xelatex"
elif command -v tectonic >/dev/null 2>&1; then
  PDF_ENGINE="tectonic"
else
  PDF_ENGINE=""
fi

ENGINE_FLAG=()
if [[ -n "$PDF_ENGINE" ]]; then
  ENGINE_FLAG=( --pdf-engine="$PDF_ENGINE" )
fi

# Temp workspace
tmpdir="$(mktemp -d 2>/dev/null || mktemp -d -t md2pdf)"
trap 'rm -rf "$tmpdir"' EXIT

# Header to fix \tightlist
tightlist_header="$tmpdir/tightlist.tex"
cat > "$tightlist_header" <<'TEX'
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
TEX

# --- Preprocess Obsidian image embeds ---
# Converts:
#   ![[file.png]]              -> ![](<file.png>)
#   ![[file.png|200]]          -> ![](<file.png>){ width=200px }
#   ![[file.png|200x120]]      -> ![](<file.png>){ width=200px height=120px }
#   ![[file.png|Alt text]]     -> ![Alt text] (<file.png>)
# Handles optional #... fragment by dropping it for images.
pre_md="$tmpdir/preprocessed.md"

if command -v perl >/dev/null 2>&1; then
  perl -0777 -pe '
    s{
      !\[\[                                   # opener
      ([^\]|#]+)                              # 1: filename (stop at | ] or #)
      (?:\#[^\]|]+)?                          # optional fragment (ignored)
      (?:\|([^\]]+))?                         # 2: optional pipe payload (size or alt)
      \]\]
    }{
      my ($f,$p) = ($1,$2 // "");
      my ($alt,$attr) = ("","");
      if ($p ne "") {
        if ($p =~ m{^\s*(\d+)\s*(?:x\s*(\d+)\s*)?$}i) {
          my ($w,$h) = ($1,$2);
          $attr = "{ width=${w}px" . (defined $h ? " height=${h}px" : "") . " }";
        } else {
          $alt = $p;
        }
      }
      # Use angle brackets to safely keep spaces in paths
      my $target = "![" . $alt . "]" . "(<" . $f . ">)" . $attr;
      $target;
    }egx;
  ' "$in_file" > "$pre_md"
else
  # Simple fallback: just convert to ![](<file>) without alt/size handling
  sed -E 's/!\[\[([^]|#]+)(\#[^]|]+)?(\|[^]]+)?\]\]/![](<\1>)/g' "$in_file" > "$pre_md"
  echo "Note: perl not found; image sizes/alt in ![[...|...]] not interpreted." >&2
fi

# --- Resource path (so images can be found) ---
in_dir="$(cd "$(dirname "$in_file")" && pwd)"
RESOURCE_PATH="${in_dir}:.:${in_dir}/assets:${in_dir}/attachments:${in_dir}/img"

# Extras
GEOM_FLAG=( -V geometry:margin=1in )
LINK_FLAGS=( -V colorlinks=true -V linkcolor=blue -V urlcolor=blue -V citecolor=blue )

# Build command
cmd=(
  pandoc "$pre_md" -o "$out_file"
  -s
  --toc --number-sections
  "${HL_FLAG[@]}"
  "${ENGINE_FLAG[@]}"
  "${GEOM_FLAG[@]}"
  "${LINK_FLAGS[@]}"
  -H "$tightlist_header"
  --resource-path="$RESOURCE_PATH"
)

log_file="${out_file%.pdf}.log"
rm -f "$log_file"

echo "-> Converting: $in_file"
echo "using $PDF_ENGINE"
if "${cmd[@]}" >"$log_file" 2>&1; then
  rm -f "$log_file"
  echo "✓ Wrote ${out_file}"
else
  echo "✗ Failed. See log: $log_file" >&2
  exit 1
fi

