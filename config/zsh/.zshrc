# Completions: a full check and dump rebuild once a day, the cached dump otherwise
fpath=(~/.zsh/completions $HOME/.docker/completions $HOME/.bun $fpath)  # ~/.bun/_bun: bun completions
autoload -Uz compinit
() {
  setopt local_options extended_glob  # (#q) glob qualifiers need it
  if [[ ! -s ~/.zcompdump || -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit && touch ~/.zcompdump  # compinit only rewrites the dump when it changed
  else
    compinit -C
  fi
}

# Source config parts
for conf in ~/.zsh/{options,secrets,aliases,functions,plugins,tools}.zsh; do
  [[ -f "$conf" ]] && source "$conf"
done

if [[ $OSTYPE == darwin* ]]; then
  # Homebrew's stable path for JDK 21 (what `/usr/libexec/java_home -v 21` finds, without the 20ms)
  _jdk=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
  [[ -d $_jdk ]] || _jdk=$(/usr/libexec/java_home -v 21 2>/dev/null)
  [[ -n $_jdk ]] && export JAVA_HOME=$_jdk PATH="$_jdk/bin:$PATH"
  unset _jdk
fi

export PATH="$HOME/.cargo/bin:$PATH"

export _ZO_DOCTOR=0.

# Zoxide must be initialized last so its `cd` wrapper is not overwritten by
# later shell setup.
_cached_init zoxide zoxide init zsh
