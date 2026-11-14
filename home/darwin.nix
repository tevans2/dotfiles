# Mac only: app configs and macOS git settings. Apps themselves come from the Brewfile.
{ config, pkgs, ... }:

let
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/${path}";

  # Rhubarb Lip Sync: not in nixpkgs or Homebrew, so the official release, pinned by hash.
  # Intel binary (runs under Rosetta). It finds its res/ folder next to the real binary,
  # so `rhubarb` is a wrapper that execs it in place. Update: bump version, set hash = "", switch, copy the hash.
  rhubarbVersion = "1.14.0";
  rhubarbRelease = pkgs.fetchzip {
    url = "https://github.com/DanielSWolf/rhubarb-lip-sync/releases/download/v${rhubarbVersion}/Rhubarb-Lip-Sync-${rhubarbVersion}-macOS.zip";
    hash = "sha256-WqbU/yPx0/Qf5gRYdSKw4VSDNAeHSnALsRYUtwDnvrU=";
  };
  rhubarb = pkgs.writeShellScriptBin "rhubarb" ''exec ${rhubarbRelease}/rhubarb "$@"'';
in
{
  # Mac-only command-line tools (cross-platform ones go in packages.nix)
  home.packages = with pkgs; [
    bitwarden-cli # `bw`: vault from the terminal; deliberately not on servers
    rhubarb # lip-sync data from audio, for Blender (see above)
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
