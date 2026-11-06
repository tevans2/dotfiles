# NVM
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

nvm() {
  _load_nvm
  nvm "$@"
}
node() {
  _load_nvm
  node "$@"
}
npm() {
  _load_nvm
  npm "$@"
}
npx() {
  _load_nvm
  npx "$@"
}

command_not_found_handler() {
  local cmd="$1"
  local resolved

  if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    resolved="$({
      export NVM_DIR="$HOME/.nvm"
      . "/opt/homebrew/opt/nvm/nvm.sh" >/dev/null 2>&1
      command -v -- "$cmd" 2>/dev/null || true
    })"

    if [[ -n "$resolved" ]]; then
      _load_nvm >/dev/null 2>&1
      "$cmd" "${@:2}"
      return $?
    fi
  fi

  print -u2 "zsh: command not found: $cmd"
  return 127
}

_load_nvm >/dev/null 2>&1

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Atac
export ATAC_KEY_BINDINGS="$HOME/.config/atac/atac.toml"

# Hledger
export LEDGER_FILE="$HOME/docs/finance/journal/main.journal"
