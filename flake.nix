{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, homeManager }: {
    homeConfigurations = {
      "serowy@desktop-nixos" = homeManager.lib.homeManagerConfiguration {
        configuration = { config, pkgs, ... }:
          let
            overlay-unstable = final: prev: {
              unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
            };
          in
          {
            nixpkgs.overlays = [ overlay-unstable ];
            nixpkgs.config = {
              allowUnfree = true;
            };

            imports = [
              ./home.nix
            ];
          };

        system = "x86_64-linux";
        homeDirectory = "/home/serowy";
        username = "serowy";
        stateVersion = "21.05";
      };
    };
  };
}
