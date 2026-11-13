# Consolidated PATH (-U: keep only the first copy of each entry)
typeset -gU path PATH
if [[ $OSTYPE == darwin* ]]; then
  # home-manager's tools first, then Homebrew (apps and Mac-only tools), then the Nix daemon's own
  export PATH="$HOME/.nix-profile/bin:/opt/homebrew/bin:/nix/var/nix/profiles/default/bin:$PATH"
else
  # home-manager packages, then the Nix daemon's own tools
  export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
fi
export PATH="$XDG_CONFIG_HOME/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Developer/projects/finance:$PATH"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
