{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosModules = {
      "serowy@desktop-nixos" = with {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.serowy = import ./home/environments/desktop.nix;
          };
        };
        home-manager.nixosModule;
    };
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
            ./environments/allowunfree.nix
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
