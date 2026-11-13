# API keys. Never stored in this repo (it's public).
# Source of truth: Doppler project `dotfiles`, config `prd`.
#   macOS: none loaded at startup; use `doppler run --project dotfiles --config prd -- <cmd>`.
#   Linux: read from ~/.config/secrets.env, written by `secrets-sync`.

if [[ $OSTYPE != darwin* && -r ~/.config/secrets.env ]]; then
  set -a; source ~/.config/secrets.env; set +a
fi

# Linux: refresh ~/.config/secrets.env from Doppler (readable by this user only)
secrets-sync() {
  if [[ $OSTYPE == darwin* ]]; then
    echo "macOS reads keys from the Keychain; nothing to sync" >&2
    return 1
  fi
  local tmp
  tmp=$(mktemp ~/.config/secrets.env.XXXXXX) || return 1
  chmod 600 "$tmp"
  if doppler secrets download --project dotfiles --config prd --no-file --format env > "$tmp"; then
    mv "$tmp" ~/.config/secrets.env && echo "secrets.env updated; open a new shell"
  else
    rm -f "$tmp"
    return 1
  fi
}
