{
  description = "Tate's dotfiles: configs (config/) and the home-manager profile that installs and links them (home/)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin"; # the Mac's packages (pre-built on cache.nixos.org)
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    # For NixOS hosts (the homelab repo imports these; its own nixpkgs is used there)
    homeModules = {
      common = ./home/common.nix;
      packages = ./home/packages.nix;
      darwin = ./home/darwin.nix;
      linux = ./home/linux.nix;
    };

    # The Mac: `just switch` (or the first time: see README)
    homeConfigurations."tate@mac" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [
        ./home/common.nix
        ./home/packages.nix
        ./home/darwin.nix
        {
          home.username = "tate";
          home.homeDirectory = "/Users/tate";
        }
      ];
    };
  };
}
