# Zoxide + fzf interactive directory picker
c() {
  if [ $# -eq 0 ]; then
    cd ~
    return
  fi
  local dir
  dir="$(zoxide query -l -- "$*" | fzf)" || return
  cd "$dir"
}

# Switch AWS profile and verify the active caller identity.
awsp() {
  if [ $# -ne 1 ]; then
    print -u2 "usage: awsp <profile>"
    return 2
  fi

  export AWS_PROFILE="$1"
  aws sts get-caller-identity
}

# Ctrl+L: snap current command to top without nuking terminal scrollback
snap_to_top_widget() {
  zle clear-screen
}
zle -N snap_to_top_widget

# ssh/mosh to a server: tint the terminal in the server's colour while connected, so it never looks
# like the Mac. Ghostty: the window background (OSC 11) and title; inside tmux: just this pane.
# Reset when the connection ends, even if it drops. Add a server: one line in _host_tint.
_host_tint() {
  case $1 in
    thinker | thinker.*) print '#1f1611' ;; # bronze-black
  esac
}
_with_tint() {
  local cmd=$1 tint="" host="" a
  shift
  for a in "$@"; do
    tint=$(_host_tint "${a#*@}")
    [[ -n $tint ]] && { host=${a#*@}; break; }
  done
  if [[ -z $tint || ! -t 1 ]]; then command "$cmd" "$@"; return; fi
  if [[ -n $TMUX ]]; then
    tmux select-pane -t "$TMUX_PANE" -P "bg=$tint"
  else
    printf '\e]11;%s\a\e]2;%s\a' "$tint" "${host%%.*}"
  fi
  command "$cmd" "$@"
  local rc=$?
  if [[ -n $TMUX ]]; then tmux select-pane -t "$TMUX_PANE" -P 'bg=default'; else printf '\e]111\a'; fi
  return $rc
}
ssh() { _with_tint ssh "$@"; }
mosh() { _with_tint mosh "$@"; }
