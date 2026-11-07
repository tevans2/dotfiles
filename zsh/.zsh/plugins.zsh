if [[ -n "${TATE_ZSH_PLUGINS_LOADED:-}" ]]; then
  return
fi
TATE_ZSH_PLUGINS_LOADED=1

# Plugin files come from Homebrew on macOS and from the Nix profile (home-manager) on Linux.
_plugin() {
  local f
  for f in "$@"; do
    [[ -r $f ]] && { source "$f"; return 0; }
  done
  print -u2 "zsh: plugin not found: ${1:t}"
}
_nix=$HOME/.nix-profile/share

# Source a tool's `init` script from a cache, rebuilt when the tool's resolved
# binary or the arguments change (saves ~20ms per tool per shell).
#   _cached_init <name> <command> [args...]
_cached_init() {
  local name=$1 bin=${commands[$2]:A}
  [[ -n $bin ]] || return 0
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init-$name.zsh
  local key="# $bin ${*[3,-1]}" line
  [[ -r $cache ]] && read -r line < $cache
  if [[ $line != "$key" ]]; then
    mkdir -p ${cache:h}
    { print -r -- $key; "${@[2,-1]}" } > $cache.$$ && mv $cache.$$ $cache
  fi
  source $cache
}

# Run commands once zsh is idle after drawing the first prompt, so the prompt
# shows before slower plugins load (the zsh-defer trick: a zle -F handler on an
# fd that is always readable). Queued commands run in order, via eval.
typeset -ga _deferred
_defer() { _deferred+=("$*") }
_defer_run() {
  local fd=$1 cmd
  zle -F $fd
  exec {fd}<&-
  for cmd in $_deferred; do eval $cmd; done
  unset _deferred
}
if [[ -o interactive ]] && exec {_defer_fd}</dev/null; then
  zle -F $_defer_fd _defer_run 2>/dev/null || exec {_defer_fd}<&-
  unset _defer_fd
fi

# Compile startup files to zsh bytecode (.zwc, git-ignored). zsh loads a .zwc
# instead of its source whenever the .zwc is newer.
_zcompile_startup() {
  local f
  for f in ~/.zshenv ~/.zshrc ~/.zsh/*.zsh ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init-*.zsh ~/.zcompdump; do
    [[ -s $f && ( ! -s $f.zwc || $f -nt $f.zwc ) ]] && zcompile $f
  done
}

# Starship prompt
_cached_init starship starship init zsh

# Atuin (must init before vi-mode, keybinds set after)
_cached_init atuin atuin init zsh --disable-up-arrow

# Zsh vi mode
_plugin /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh \
        $_nix/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Rebind Ctrl+R to atuin after vi-mode loads (works in both insert and normal modes)
zvm_after_init_commands+=('bindkey "^r" _atuin_search_widget')

# Ctrl+L clears + redraws current command at top (instead of default clear)
bindkey '^L' snap_to_top_widget
bindkey -M emacs '^L' snap_to_top_widget
bindkey -M viins '^L' snap_to_top_widget
bindkey -M vicmd '^L' snap_to_top_widget

# Everything below loads after the first prompt (see _defer). It also runs
# after zsh-vi-mode's own init, so these bindings aren't reset by it.
export FZF_CTRL_R_COMMAND=""  # atuin owns Ctrl+R
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
_deferred_plugins() {
  local nix=$HOME/.nix-profile/share

  # fzf key bindings, minus its Ctrl+R
  _cached_init fzf fzf --zsh
  bindkey -M vicmd '/' fzf-file-widget
  bindkey -r "^r"
  bindkey -M viins "^r" _atuin_search_widget
  bindkey -M vicmd "^r" _atuin_search_widget

  # fzf-tab (after compinit and fzf, before autosuggestions)
  _plugin /opt/homebrew/share/fzf-tab/fzf-tab.zsh \
          $nix/fzf-tab/fzf-tab.zsh

  # Autosuggestions (ghost text as you type). It normally starts from precmd,
  # which has already run by now, so start it by hand.
  _plugin /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
          $nix/zsh-autosuggestions/zsh-autosuggestions.zsh
  (( $+functions[_zsh_autosuggest_start] )) && _zsh_autosuggest_start
  bindkey '^[[Z' autosuggest-accept  # Shift+Tab accepts suggestion

  # Autopair (auto-close brackets, quotes)
  _plugin /opt/homebrew/share/zsh-autopair/autopair.zsh \
          $nix/zsh/zsh-autopair/autopair.zsh
}
_defer _deferred_plugins
_defer _zcompile_startup
unset _nix
