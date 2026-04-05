#!/usr/bin/env bash
set -euo pipefail

# --- minimal config ---
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:$PATH"

LOG="$HOME/.pdfx.log"
: >"$LOG"  # clear per run

debug() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG" >&2; }
SED="$(command -v sed || echo /usr/bin/sed)"
PDFINFO="$(command -v pdfinfo || true)"
PDFTOTEXT="$(command -v pdftotext || true)"
AEROSPACE="$(command -v aerospace || true)"

pdf_open() {
  local app="$HOME/Applications/Zathura.app"
  command -v open >/dev/null 2>&1 || { echo "open(1) not found"; return 127; }
  open -a "$app" "$@"
}

[[ -z "$AEROSPACE" ]] && { echo "aerospace not found" >&2; exit 1; }

export SED PDFINFO PDFTOTEXT AEROSPACE

# --- find PDFs (keep as you had) ---
SEARCH_DIRS=( "$HOME/Documents/uni-work/second-year" )
if command -v fd >/dev/null 2>&1; then
  mapfile -t FILES < <(fd -t f -e pdf -E .git . "${SEARCH_DIRS[@]}")
else
  mapfile -t FILES < <(find "${SEARCH_DIRS[@]}" -type f -iname '*.pdf' 2>/dev/null)
fi
((${#FILES[@]})) || { echo "No PDFs found" >&2; exit 1; }

MENU=$(
  printf '%s\n' "${FILES[@]}" | awk -v HOME="$HOME" '{full=$0; disp=$0; sub("^"HOME"/","~/",disp); print disp "\t" full}'
)

# --- pick PDF ---
SELECTED_LINE=$(printf '%s\n' "$MENU" | sk \
  --ansi --prompt='PDF> ' --with-nth=1 --delimiter=$'\t' \
  --preview '
    path={2}
    if [ -n "$PDFINFO" ]; then "$PDFINFO" "$path"; else echo "(no pdfinfo)"; fi
    echo
    if [ -n "$PDFTOTEXT" ]; then
      echo "— First page —"
      "$PDFTOTEXT" -l 1 -nopgbrk -q "$path" - | '"$SED"' -n "1,60p"
    else
      echo "(no pdftotext)"
    fi
  ' \
  --preview-window 'right:60%:wrap' --margin '10%' --color='bw'
)
[[ -z "${SELECTED_LINE:-}" ]] && exit 0
PDF_PATH=$(awk -F'\t' '{print $2}' <<<"$SELECTED_LINE")
debug "PDF_PATH=$PDF_PATH"

# --- pick workspace (single key) ---
existing_ws="$("$AEROSPACE" list-workspaces --all --format '%{workspace}' 2>/dev/null | sort -u)"
common_ws=$(printf '%s\n' {1..9} {A..Z})
menu_ws=$(printf '%s\n%s\n' "$existing_ws" "$common_ws" | awk 'NF' | sort -u)
EXPECT_KEYS=$(printf '%s,' {0..9} {a..z} {A..Z} | sed 's/,$//')

mapfile -t OUT < <(printf '%s\n' "$menu_ws" | sk --prompt='Workspace (key): ' \
  --expect "$EXPECT_KEYS" --no-sort --margin '10%' --color='bw' \
  --preview 'echo "Press a single key to choose workspace"')
KEY="${OUT[0]:-}"; SEL="${OUT[1]:-}"
if   [[ -n "$KEY" ]]; then WS="$KEY"
elif [[ -n "$SEL" ]]; then WS="$SEL"
else exit 0; fi
debug "WS=$WS"


# Make lookup non-fatal (avoid set -e killing the script if aerospace returns nonzero)
set +e

# --- launch in current workspace, then move to selected WS ---

# Current focused workspace (where we will spawn Zathura)
CUR_WS="$("$AEROSPACE" list-workspaces --focused 2>/dev/null | head -n1)"
debug "CUR_WS=$CUR_WS  TARGET_WS=$WS"

# Launch Zathura here (current/focused workspace)
pdf_open "$PDF_PATH"

# Resolve the real PID: prefer the process that has THIS file open
Z_PID=""
deadline=$((SECONDS + 6))
while [ $SECONDS -lt $deadline ]; do
  # lsof: -t (just pid), -a (AND the filters), -c zathura (proc name starts with 'zathura')
  Z_PID="$(lsof -t -a -c zathura -- "$PDF_PATH" 2>/dev/null | head -n1 || true)"
  [ -n "$Z_PID" ] && break
  sleep 0.1
done

# Resolve window-id by PID (no workspace filter since we spawned in CUR_WS)
WIN_ID=""
for i in {1..60}; do
  WIN_ID="$($AEROSPACE list-windows --workspace $CUR_WS --pid $Z_PID --format '%{window-id}' 2>/dev/null | head -n1)"
  debug "$AEROSPACE list-windows --workspace $CUR_WS --pid $Z_PID --format '%{window-id}')"
  debug "WINID = $WIN_ID"
  [[ -n "$WIN_ID" ]] && break
  sleep 0.05
done
debug "WIN_ID=${WIN_ID:-<empty>} (from PID)"

# Move to selected workspace and focus
if [[ -n "$WIN_ID" ]]; then
  debug "MOVE: $AEROSPACE move-node-to-workspace $WS --window-id $WIN_ID --focus-follows-window"
  "$AEROSPACE" move-node-to-workspace "$WS" --window-id "$WIN_ID" --focus-follows-window

  # Return the window id on stdout so callers can capture it
  printf '%s\n' "$WIN_ID"
  exit 0
else
  debug "Could not resolve window-id; not moving."
  exit 1
fi

