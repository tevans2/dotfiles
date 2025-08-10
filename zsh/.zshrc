# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Completions
autoload -U compinit; compinit

# Zsh config
alias rz="echo 'Reloading .zshrc'; source ~/.zshrc"

# Tools
alias study="~/tools/study.sh"

# nvim alias
alias nv="nvim"
#
# nvim alias
alias lg="lazygit"


# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"


# Ensure fzf widgets are loaded
autoload -Uz fzf-file-widget fzf-history-widget

# Bind '/' to fzf-file-widget (like Ctrl-T)
bindkey -M vicmd '/' fzf-file-widget

# Bind '?' to fzf-history-widget (like Ctrl-R)
bindkey -M vicmd '?' fzf-history-widget

# Use fd instead of fzf

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path ()
{
  fd --hidden --exclude .git . "$1"
}


_fzf_compgen_dir ()
{
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/fzf-git.sh/fzf-git.sh

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun ()
{
  local command=$1
  shift

  case "$command" in
    cd)     fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$' {}"   "$@" ;;
    ssh) fzf --preview 'dig {}'   "$@" ;;
    *) fzf --preview "--preview 'bat -n --color=always --line-range :500 {}'" "$@" ;;
  esac
}


# eza - better ls

alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"

# the fuck

eval $(thefuck --alias)
eval $(thefuck --alias fk)

# zoxide better cd

eval "$(zoxide init zsh)"

alias cd="z"
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Use terminal vim bindings

source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Ensure fzf widgets are loaded
autoload -Uz fzf-file-widget fzf-history-widget

# Bind '/' to fzf-file-widget (like Ctrl-T)
bindkey -M vicmd '/' fzf-file-widget

# Bind '?' to fzf-history-widget (like Ctrl-R)
bindkey -M vicmd '?' fzf-history-widget


export PATH="/opt/homebrew/bin:/Users/tate/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 24.0.1)
export PATH=$JAVA_HOME/bin/:$PATH

export CLASSPATH=$CLASSPATH:~/algs4/algs4.jar

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Zeit
export ZEIT_DB=~/.config/zeit.db
source ~/.zeit_completion.zsh

# Add C compiler alias
alias ccc='function _ccc() { fname="$1"; cc -Wall -ansi -pedantic "$fname" -o "${fname%.c}"; }; _ccc'

export PATH="$HOME/.local/bin:$PATH"
