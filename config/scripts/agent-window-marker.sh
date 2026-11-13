#!/usr/bin/env bash
set -euo pipefail

# Minimal AI-agent -> tmux state bridge.
# Sets per-window tmux options used by the status line. It intentionally does
# not track sessions, parse transcripts, rename windows, or maintain a registry.

agent="${1:-}"
action="${2:-}"
input=$(cat || true)

case "$agent" in
  claude|codex|pi|omp) ;;
  *) exit 0 ;;
esac

case "$action" in
  working|blocked|idle|release) ;;
  *) exit 0 ;;
esac

[[ -n "${TMUX_PANE:-}" ]] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

# Do not let subagent completion clear the parent pane while the parent turn is
# still running. Hooks that do not send JSON simply skip this guard.
if [[ -n "$input" ]] && command -v jq >/dev/null 2>&1; then
  hook_event_name=$(jq -r '.hook_event_name // ""' <<<"$input" 2>/dev/null || true)
  agent_id=$(jq -r '.agent_id // ""' <<<"$input" 2>/dev/null || true)

  [[ "$hook_event_name" == "SubagentStop" ]] && exit 0
  if [[ -n "$agent_id" && ( "$action" == "idle" || "$action" == "release" ) ]]; then
    exit 0
  fi
fi

window_active=$(tmux display-message -p -t "$TMUX_PANE" "#{window_active}" 2>/dev/null || printf '0')

case "$action" in
  working)
    tmux set-window-option -t "$TMUX_PANE" @agent_name "$agent" >/dev/null 2>&1 || true
    tmux set-window-option -t "$TMUX_PANE" @agent_state working >/dev/null 2>&1 || true
    if [[ "$window_active" == "1" ]]; then
      tmux set-window-option -t "$TMUX_PANE" -u @agent_unread >/dev/null 2>&1 || true
    fi
    ;;
  blocked)
    tmux set-window-option -t "$TMUX_PANE" @agent_name "$agent" >/dev/null 2>&1 || true
    tmux set-window-option -t "$TMUX_PANE" @agent_state blocked >/dev/null 2>&1 || true
    if [[ "$window_active" == "1" ]]; then
      tmux set-window-option -t "$TMUX_PANE" -u @agent_unread >/dev/null 2>&1 || true
    fi
    ;;
  idle|release)
    tmux set-window-option -t "$TMUX_PANE" @agent_name "$agent" >/dev/null 2>&1 || true
    tmux set-window-option -t "$TMUX_PANE" -u @agent_state >/dev/null 2>&1 || true
    if [[ "$window_active" == "1" ]]; then
      tmux set-window-option -t "$TMUX_PANE" -u @agent_unread >/dev/null 2>&1 || true
    else
      tmux set-window-option -t "$TMUX_PANE" @agent_unread 1 >/dev/null 2>&1 || true
    fi
    ;;
esac
