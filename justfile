# dotfiles: run on the Mac. The thinker gets the same profile through the homelab repo.

set shell := ["bash", "-euo", "pipefail", "-c"]
export NIX_CONFIG := "experimental-features = nix-command flakes"

default:
    @just --list

# Build the Mac's home without activating it
build:
    nix run home-manager/release-26.05 -- build --flake .#tate@mac

# Activate it (anything in the way is moved aside as *.pre-hm)
switch:
    nix run home-manager/release-26.05 -- switch --flake .#tate@mac -b pre-hm

# Update nixpkgs and home-manager, then switch
update:
    nix flake update && just switch

# Install everything in the Brewfile
brew:
    brew bundle --file=Brewfile

# What's installed but not in the Brewfile (dry run); add --force to uninstall it
brew-cleanup *flags:
    brew bundle cleanup --file=Brewfile {{flags}}

# Once per clone: the gitleaks pre-commit hook
setup:
    git config core.hooksPath .githooks
