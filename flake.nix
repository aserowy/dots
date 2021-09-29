{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosModules = {
      "serowy@desktop-nixos" = {...}: home-manager.nixosModule {
        home-manager.useUserPackages = true;

        home-manager.users.serowy = import ./environments/wsl.nix;
      };
    };
    homeConfigurations = {
      "serowy@DESKTOP-UVAKAQL" = home-manager.lib.homeManagerConfiguration {
        configuration = { config, pkgs, ... }: {
          imports = [
            ./environments/wsl.nix
            ./environments/work.nix
          ];
        };
        homeDirectory = "/home/serowy";
        stateVersion = "21.05";
        system = "x86_64-linux";
        username = "serowy";
      };
      "serowy@DESKTOP-2F0CTGF" = home-manager.lib.homeManagerConfiguration {
        configuration = { config, pkgs, ... }: {
          imports = [
            ./environments/wsl.nix
          ];
        };
        homeDirectory = "/home/serowy";
        stateVersion = "21.05";
        system = "x86_64-linux";
        username = "serowy";
      };
    };
  };
}
