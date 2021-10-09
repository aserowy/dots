{
  description = "Home Manager configurations";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-wayland, nur, ... }:
    let
      packages = with nixpkgs; {
        inherit legacyPackages;

        overlays = [
          nur.overlay
          nixpkgs-wayland.overlay

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
