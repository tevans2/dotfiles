# Mac only: app configs and macOS git settings. Apps themselves come from the Brewfile.
{ config, ... }:

let
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/${path}";
in
{
  xdg.configFile = {
    "aerospace".source = link "aerospace";
    "ghostty".source = link "ghostty";
    "kitty".source = link "kitty";
    "sioyek".source = link "sioyek";
  };
  # LibreWolf's global overrides; profile files are linked by config/librewolf/link-profile.sh
  home.file.".librewolf".source = link "librewolf/.librewolf";

  programs.git.settings = {
    credential.helper = "osxkeychain";
    pager.diff = "diffnav";
  };
}
