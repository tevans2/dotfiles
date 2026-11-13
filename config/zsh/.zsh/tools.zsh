# NVM: loaded on first use of `nvm` (loading it costs ~0.7s).
# The default Node's bin goes on PATH now, so node and global npm tools work
# straight away: the version alias/default names, else the newest installed.
export NVM_DIR="$HOME/.nvm"
() {
  local v; [[ -r $NVM_DIR/alias/default ]] && v=$(<$NVM_DIR/alias/default)  # nvm exists on the Mac only
  local dirs=($NVM_DIR/versions/node/${v:-x}(N/) $NVM_DIR/versions/node/v*(N/nOn))
  (( $#dirs )) && export PATH="${dirs[1]}/bin:$PATH"
}
_load_nvm() {
  unset -f nvm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

nvm() {
  _load_nvm
  nvm "$@"
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

# Atac
export ATAC_KEY_BINDINGS="$HOME/.config/atac/atac.toml"

# Hledger
export LEDGER_FILE="$HOME/Developer/projects/finance/journal/main.journal"
