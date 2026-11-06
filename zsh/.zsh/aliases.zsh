# Zsh config
alias rz="echo 'Restarting zsh'; exec zsh -l"
alias oz="nvim ~/.zshrc"

# Editor
alias nv="nvim"

# Git
alias lg="lazygit --use-config-file=$HOME/.config/lazygit/config.yml"
alias ghr="~/.config/scripts/open-gh.sh"

# Navigation
alias ls='ls -lGah'
alias lt='eza -la --tree --level=2 --icons --group-directories-first'
alias cd="z"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Better defaults
alias cat='bat --style=plain'
alias find='fd'


# AI
alias '?'='noglob ~/.config/scripts/search.sh'
alias '??'='noglob ~/.config/scripts/ask.sh'

# AWS
alias aws-login='aws sso login --sso-session nimble-aws-sso'
alias aws-who='aws sts get-caller-identity'

# Tools
alias study="~/tools/study.sh"
alias venv="source .venv/bin/activate"
alias md2pdf="$HOME/Developer/md2pdf/.venv/bin/md2pdf"
alias zathura='open -a "$HOME/Applications/Zathura.app"'
alias ql='shortcuts run "quick look" -i'

# Compilers
alias gcc='gcc-15'

# Finance
alias hl='hledger'
alias hlb='hledger balance'
alias hli='hledger incomestatement'
alias hlr='hledger register'
