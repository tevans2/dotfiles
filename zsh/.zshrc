# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n] confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Completions
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit

# Zsh config
alias rz="echo 'Reloading .zshrc'; source ~/.zshrc"
alias oz="nvim ~/.zshrc"

# Venv
alias venv="source .venv/bin/activate"

# Tools
alias study="~/tools/study.sh"

# API Keys (stored in macOS Keychain)
export OPENAI_API_KEY=$(security find-generic-password -a "$USER" -s "OPENAI_API_KEY" -w 2>/dev/null)

# AI Q&A (fallback: pi -> claude -> codex -> openai -> fail)
alias '?'='noglob ~/.config/scripts/search.sh'
alias '??'='noglob ~/.config/scripts/ask.sh'

# nvim alias
alias nv="nvim"

# nvim alias
alias lg="lazygit --use-config-file=$HOME/.config/lazygit/config.yml"

# zathura app wrapper alias
alias zathura='open -a "$HOME/Applications/Zathura.app"'

# Quick look alias
alias ql='shortcuts run "quick look" -i'

# Script alias
alias ghr="~/.config/scripts/open-gh.sh"

# ls alias
alias ls='ls -lGah'

# md2pdf
alias md2pdf="~/Developer/md2pdf/.venv/bin/md2pdf"

alias gcc='gcc-15'


# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Bind '/' to fzf-file-widget (like Ctrl-T)
bindkey -M vicmd '/' fzf-file-widget

# Bind '?' to fzf-history-widget (like Ctrl-R)
bindkey -M vicmd '?' fzf-history-widget

# zoxide better cd
eval "$(zoxide init zsh)"
c() {
  if [ $# -eq 0 ]; then
    cd ~
    return
  fi
  local dir
  dir="$(zoxide query -l -- "$*" | fzf)" || return
  cd "$dir"
}

alias cd="z"
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Use terminal vim bindings

source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh


export PATH="/opt/homebrew/bin:/Users/tate/bin:/Users/tate/docs/finance:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Add C compiler alias
alias ccc='function _ccc() { fname="$1"; cc -Wall -ansi -pedantic "$fname" -o "${fname%.c}"; }; _ccc'

export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/tate/.bun/_bun" ] && source "/Users/tate/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/tate/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Added by Windsurf
export PATH="/Users/tate/.codeium/windsurf/bin:$PATH"

# Added by Antigravity
export PATH="/Users/tate/.antigravity/antigravity/bin:$PATH"


# atac
export ATAC_KEY_BINDINGS="$HOME/.config/atac/atac.toml"

export EDITOR="nvim"



# hledger configuration
export LEDGER_FILE="$HOME/docs/finance/journal/main.journal"

# Optional: Convenient alias for finance commands
alias hl='hledger'
alias hlb='hledger balance'
alias hli='hledger incomestatement'
alias hlr='hledger register'


