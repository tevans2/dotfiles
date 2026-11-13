# Command-line tools, the same versions on both machines (pinned by flake.lock).
# Mac apps and Mac-only tools live in the Brewfile instead.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # shell (config/zsh)
    atuin
    bat
    eza
    fzf
    starship
    zoxide
    zsh-autopair
    zsh-autosuggestions
    zsh-fzf-tab
    zsh-vi-mode

    # editor and terminal
    neovim
    tmux

    # everyday tools
    btop
    delta
    fd
    gh
    jq
    just
    lazygit
    ripgrep
    tree

    # secrets and repo hygiene
    age
    doppler
    gitleaks
    sops
  ];
}
