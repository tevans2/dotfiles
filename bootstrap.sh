#!/usr/bin/env bash
# New Mac → working setup. Run from a clone: git clone https://github.com/tevans2/dotfiles ~/dotfiles && ~/dotfiles/bootstrap.sh
# (The first `git` on a fresh Mac offers to install Apple's command-line tools: accept, then rerun.)
# Safe to rerun: each step skips what's already done.
set -euo pipefail
cd "$(dirname "$0")"

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

step "1/4 Nix"
if [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
  curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
fi
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
export NIX_CONFIG="experimental-features = nix-command flakes"

step "2/4 home-manager: link the configs, install the command-line tools"
nix run home-manager/release-26.05 -- switch --flake .#tate@mac -b pre-hm

step "3/4 Homebrew and the apps in the Brewfile"
if [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file=Brewfile

step "4/4 Repo hooks"
git config core.hooksPath .githooks

cat <<'NEXT'

Done. By hand, once:
  - open a new terminal (zsh, prompt and tools load from ~/dotfiles)
  - sign in: Bitwarden, then Tailscale, GitHub (`gh auth login`), Doppler (`doppler login`)
  - copy the sops age key from Bitwarden to ~/.config/sops/age/keys.txt (homelab secrets)
  - Karabiner: copy config/karabiner/karabiner.json to ~/.config/karabiner/
NEXT
