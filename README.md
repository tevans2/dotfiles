# dotfiles

My configs and the home-manager profile that installs and links them, on the Mac and on Linux (thinker).

## Layout

```
config/<app>/   the config files themselves; linked live, so edits need no rebuild
home/
  common.nix    both machines: which configs are linked where, git settings
  packages.nix  command-line tools, both machines (Homebrew only for apps and Mac-only tools)
  darwin.nix    Mac only: AeroSpace, Ghostty, kitty, sioyek, ~/.librewolf, Keychain, diffnav
  linux.nix     Linux only: what nvim needs to build plugins
flake.nix       homeModules (used by the homelab repo for thinker) + homeConfigurations."tate@mac"
exports/        settings exported from apps, imported by hand (Vimium C)
archive/        configs no longer in use
```

## Daily use

- **Change a setting:** edit the file in `config/`. It's live on this machine at once; commit and push, then `git -C ~/dotfiles pull` on the other machine.
- **Add or remove a link or a package:** edit `home/*.nix`, then `just switch` on the Mac. On thinker, run `nix flake update dotfiles` in the homelab repo and `just deploy` there (or wait for the weekly flake.lock PR).
- **Update nixpkgs/home-manager on the Mac:** `just update`.

## Git

`~/.config/git/config` is generated from `home/common.nix` and read-only. `GIT_CONFIG_GLOBAL` (in `config/zsh/.zshenv`) points git at `~/.config/git/local`, a normal file that includes it, so `git config --global` and tools like gh and CodeRabbit still work.

## New Mac

1. Install Nix: `curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh`, then open a new terminal.
2. Clone: `git clone https://github.com/tevans2/dotfiles ~/dotfiles && cd ~/dotfiles`
3. `NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/release-26.05 -- switch --flake .#tate@mac -b pre-hm`
4. Homebrew apps: Brewfile coming (stage 4).

Secrets never live here: `config/zsh/.zsh/secrets.zsh` only looks keys up (Keychain / Doppler). The gitleaks pre-commit hook checks every commit (`just setup` once per clone).
