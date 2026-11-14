# dotfiles

My configs and the home-manager profile that installs and links them, on the Mac and on Linux (thinker).

## Layout

```
config/<app>/   the config files themselves; linked live, so edits need no rebuild
home/
  common.nix    both machines: which configs are linked where, git settings
  packages.nix  command-line tools, both machines (Homebrew only for apps and Mac-only tools)
  darwin.nix    Mac only: AeroSpace, Ghostty, kitty, sioyek configs; Mac-only CLI tools (bw); Keychain, diffnav
  linux.nix     Linux only: what nvim needs to build plugins
flake.nix       homeModules (used by the homelab repo for thinker) + homeConfigurations."tate@mac"
Brewfile        Mac apps and Mac-only tools (Homebrew)
bootstrap.sh    new Mac → working setup
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

```sh
git clone https://github.com/tevans2/dotfiles ~/dotfiles && ~/dotfiles/bootstrap.sh
```

It installs Nix, runs home-manager (links + command-line tools), installs Homebrew and the Brewfile, and lists the sign-ins to do by hand.

## Apps (Homebrew)

`Brewfile` lists what should be installed. `just brew` installs anything missing (no upgrades), `just upgrade` updates everything; `just brew-cleanup` shows what's installed but not listed (`--force` removes it). Add an app by adding a line, not just `brew install`, or the next cleanup removes it.

Secrets never live here: `config/zsh/.zsh/secrets.zsh` only looks keys up (Keychain / Doppler). The gitleaks pre-commit hook checks every commit (`just setup` once per clone).
