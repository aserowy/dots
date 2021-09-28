{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      "serowy@desktop-nixos" = home-manager.lib.homeManagerConfiguration {
        configuration = import ./environments/wsl.nix;
        system = "x86_64-linux";
        homeDirectory = "/home/serowy";
        username = "serowy";
        stateVersion = "21.05";
      };
    };
  };
}
