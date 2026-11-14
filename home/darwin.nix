# Mac only: app configs and macOS git settings. Apps themselves come from the Brewfile.
{ config, pkgs, ... }:

let
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/${path}";
in
{
  # Mac-only command-line tools (cross-platform ones go in packages.nix)
  home.packages = with pkgs; [
    bitwarden-cli # `bw`: vault from the terminal; deliberately not on servers
  ];

  xdg.configFile = {
    "aerospace".source = link "aerospace";
    "ghostty".source = link "ghostty";
    "kitty".source = link "kitty";
    "sioyek".source = link "sioyek";
  };

  programs.git.settings = {
    credential.helper = "osxkeychain";
    pager.diff = "diffnav";
  };
}
