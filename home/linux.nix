# Linux only (thinker): what nvim needs to build plugins, which the Mac gets from Xcode's tools.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc # treesitter compiles parsers
    gnumake
    nodejs # mason installs language servers
    unzip
  ];
}
