# Both machines: what is linked where, and git's settings.
# Configs are live links into ~/dotfiles/config (mkOutOfStoreSymlink): edit them in place, no rebuild.
# Only adding or removing a link, or a package, needs a switch.
{ config, lib, pkgs, ... }:

let
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/${path}";
in
{
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.file = {
    ".zshenv".source = link "zsh/.zshenv";
    ".zshrc".source = link "zsh/.zshrc";
    ".zsh".source = link "zsh/.zsh";
    ".clang-format".source = link "clang-format/.clang-format";
  };

  xdg.configFile = {
    "atuin".source = link "atuin";
    "gh-dash".source = link "gh-dash";
    "lazygit".source = link "lazygit";
    "nvim".source = link "nvim";
    "scripts".source = link "scripts";
    "sift".source = link "sift";
    "starship.toml".source = link "starship/starship.toml";
    "tmux".source = link "tmux";
  };

  # ~/.config/git/config is generated (read-only). Tools that write `git config --global`
  # (gh, CodeRabbit, …) write to ~/.gitconfig instead, which git also reads: keep it as a normal file.
  programs.git = {
    enable = true;
    settings = {
      user.name = "tevans2";
      user.email = "tateatevans2@gmail.com";
      init.defaultBranch = "main";
      core.pager = "delta";
      delta.navigate = true;
      delta.side-by-side = true;
    };
    ignores = [
      ".DS_Store" ".AppleDouble" ".LSOverride" "._*" ".Spotlight-V100" ".Trashes" # macOS
      "Thumbs.db" "Desktop.ini" # Windows
      ".directory" ".Trash-*" # Linux
      "**/.claude/settings.local.json"
    ];
  };
  home.activation.mutableGitconfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -e "$HOME/.gitconfig" ] || run touch "$HOME/.gitconfig"
  '';

  # A new machine gets ~/dotfiles cloned on its first switch (public repo; edits are pushed from a machine with keys).
  home.activation.cloneDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/dotfiles/.git" ]; then
      run ${pkgs.git}/bin/git clone https://github.com/tevans2/dotfiles.git "$HOME/dotfiles" \
        || echo "cloneDotfiles: clone failed (network?); run it by hand"
    fi
  '';
}
