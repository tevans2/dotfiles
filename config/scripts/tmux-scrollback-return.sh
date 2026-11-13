#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'usage: %s save|restore <pane-id>\n' "${0##*/}" >&2
  exit 2
}

[[ $# -eq 2 ]] || usage

mode="$1"
pane_id="$2"

case "$mode" in
  save)
    abs_line="$(tmux display-message -p -t "$pane_id" '#{e|+|:#{e|-:#{history_size},#{scroll_position}},#{copy_cursor_y}}')"
    cursor_y="$(tmux display-message -p -t "$pane_id" '#{copy_cursor_y}')"

    tmux set-option -p -t "$pane_id" @scrollback_return_abs "$abs_line"
    tmux set-option -p -t "$pane_id" @scrollback_return_y "$cursor_y"
    ;;
  restore)
    abs_line="$(tmux display-message -p -t "$pane_id" '#{@scrollback_return_abs}')"
    cursor_y="$(tmux display-message -p -t "$pane_id" '#{@scrollback_return_y}')"

    if [[ -z "$abs_line" || -z "$cursor_y" ]]; then
      tmux display-message -t "$pane_id" 'No saved scrollback position'
      exit 0
    fi

    target_scroll="$(tmux display-message -p -t "$pane_id" '#{e|+|:#{e|-:#{history_size},#{@scrollback_return_abs}},#{@scrollback_return_y}}')"
    if (( target_scroll < 0 )); then
      target_scroll=0
    fi

    tmux send-keys -t "$pane_id" -X history-bottom
    if (( target_scroll > 0 )); then
      tmux send-keys -t "$pane_id" -X -N "$target_scroll" scroll-up
    fi
    tmux send-keys -t "$pane_id" -X top-line
    if (( cursor_y > 0 )); then
      tmux send-keys -t "$pane_id" -X -N "$cursor_y" cursor-down
    fi
    ;;
  *)
    usage
    ;;
esac
