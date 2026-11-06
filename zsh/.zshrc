# Completions (cached for 24h)
fpath=(~/.zsh/completions $HOME/.docker/completions $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Source config parts
for conf in ~/.zsh/{options,secrets,aliases,functions,plugins,tools}.zsh; do
  [[ -f "$conf" ]] && source "$conf"
done

if [[ $OSTYPE == darwin* ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export JAVA_HOME=$(/usr/libexec/java_home -v 21)
  export PATH="$JAVA_HOME/bin:$PATH"
fi

export PATH="$HOME/.cargo/bin:$PATH"

export _ZO_DOCTOR=0.


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Zoxide must be initialized last so its `cd` wrapper is not overwritten by
# later shell setup.
eval "$(zoxide init zsh)"
