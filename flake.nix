{
  description = "Home Manager configurations";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, home-manager, nixpkgs, nur, ... }:
    let
      packages = with nixpkgs; {
        inherit legacyPackages;

        overlays = [
          nur.overlay
          (import ./pkgs)
        ];
      };
    in
    {
      devShell.x86_64-linux = import ./.dev { pkgs = packages.legacyPackages.x86_64-linux; };

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
