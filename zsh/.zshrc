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

export PATH="/opt/homebrew/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="$JAVA_HOME/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

export _ZO_DOCTOR=0.


# bun completions
[ -s "/Users/tate/.bun/_bun" ] && source "/Users/tate/.bun/_bun"

# Zoxide must be initialized last so its `cd` wrapper is not overwritten by
# later shell setup.
eval "$(zoxide init zsh)"
