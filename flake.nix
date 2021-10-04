{
  description = "Home Manager configurations";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, home-manager, nixpkgs, nur, ... }: {
    /* nixosModules = {
      "serowy@desktop-nixos" = ({ config, utils, ... }: home-manager.nixosModule {
        pkgs = nixpkgs;
        lib = nixpkgs.lib;
        inherit config utils;

        home-manager = {
          useUserPackages = true;
          users.serowy = import ./environments/desktop.nix;
        };
      });
    }; */
    homeConfigurations = {
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
      "serowy@desktop-nixos" = home-manager.lib.homeManagerConfiguration {
        configuration = { config, pkgs, ... }: {
          imports = [
            ./environments/include_homemanager.nix

            ./environments/desktop.nix
          ];
        };
        homeDirectory = "/home/serowy";
        stateVersion = "21.05";
        system = "x86_64-linux";
        username = "serowy";
      };
      "serowy@DESKTOP-UVAKAQL" = home-manager.lib.homeManagerConfiguration {
        configuration = { config, pkgs, ... }: {
          imports = [
            ./environments/wsl-work.nix
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
