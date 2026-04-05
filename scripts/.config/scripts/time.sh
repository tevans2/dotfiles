#!/bin/bash

DEBUG=${DEBUG:-0}
log() { [[ "$DEBUG" == "1" ]] && printf "[dbg] %s\n" "$*" >&2; }

log "starting"

CATEGORIES=("WORK" "NIMBLE" "WASTE" "STOP")

slug() {
  # make a safe timew tag from free text
  printf "%s" "$1" | tr -s '[:space:]' ' ' | cut -c1-60 | tr -cs '[:alnum:]#' '_' | sed 's/^_*//; s/_*$//'
}

selected=$(printf "%s\n" "${CATEGORIES[@]}" | sk --margin 10% --color="bw" --bind 'q:abort') || { echo "failed"; exit 0; }
[[ -z "$selected" ]] && { echo "failed"; exit 0; }

tmux set -g status-interval 5

if [[ "$selected" == "STOP" ]]; then
  timew stop >/dev/null 2>&1
  tmux set -g status-right ""
  exit 0
fi

# start timer and base status
timew start "$selected" >/dev/null 2>&1
tmux set -g status-right "$selected #(timew | awk '/^ *Total/ {print \$NF}')"

if [[ "$selected" == "NIMBLE" ]]; then
  # cd to current tmux pane dir so gh uses the right repo
  cd "$(tmux display-message -p -F "#{pane_current_path}")" 2>/dev/null || true

  log "getting issues"

  issues=""
  if command -v gh >/dev/null 2>&1; then
    # issues="$(gh issue list --assignee "@me" --limit 100 --json number,title \
    #   --template '{{range .}}{{printf "#%v\t%s\n" .number .title}}{{end}}' 2>/dev/null)"
    issues="$(gh issue list --limit 100 --json number,title \
      --template '{{range .}}{{printf "#%v\t%s\n" .number .title}}{{end}}' 2>/dev/null)"
  fi

  log "got issues"

  log "selected=$selected"

  # one prompt: pick an issue or type custom text
  out="$(printf "%s\n" "$issues" | sk --prompt 'Issue or type a note: ' --print-query --margin 10% --color='bw' --bind 'q:abort')" || exit 0
  log "out=$(printf '%q' "$out")"


  query="$(printf "%s\n" "$out" | sed -n '1p')"
  log "query=$(printf '%q' "$query")"

  sel="$(printf "%s\n" "$out" | sed -n '2p')"
  log "sel=$(printf '%q' "$sel")"


  if [[ -n "$sel" && "$sel" =~ ^#([0-9]+)[[:space:]] ]]; then
    num="${BASHREMATCH[1]:-${BASH_REMATCH[1]}}"  # compat if shell lacks BASHREMATCH alias
    timew tag @1 "gh#${num}" >/dev/null 2>&1
    tmux set -g status-right "NIMBLE (#${num}) #(timew | awk '/^ *Total/ {print \$NF}')"
  else
    # tag timew with custom message (slug) but keep tmux minimal
    msg="$(printf "%s" "$query" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    if [[ -n "$msg" ]]; then
      # timew tag @1 "msg_$(slug "$msg")" >/dev/null 2>&1
      timew tag @1 "testtag" >/dev/null 2>&1

    fi
    tmux set -g status-right "NIMBLE #(timew | awk '/^ *Total/ {print \$NF}')"
  fi
fi

