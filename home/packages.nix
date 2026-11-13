# The command-line tools the configs expect, on both machines.
# Linux: installed now. Mac: still from Homebrew until stage 3 moves them here.
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

    # tools the configs call
    delta
    doppler
    lazygit
  ];
}
