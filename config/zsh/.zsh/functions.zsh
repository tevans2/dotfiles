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
