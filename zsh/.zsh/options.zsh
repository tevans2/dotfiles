# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Behavior
setopt AUTO_CD              # Type dir name to cd into it
setopt CORRECT              # Suggest corrections for typos
setopt GLOB_DOTS            # Include dotfiles in glob patterns

# Editor
export EDITOR="nvim"
