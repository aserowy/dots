{
  description = "NixOS configurations";

  inputs = {
    fenix.url = "github:nix-community/fenix";
    hardware.url = "github:NixOS/nixos-hardware/master";
    home.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { fenix, hardware, home, nixpkgs, nur, ... }: {
    nixosConfigurations = {
      desktop-workstation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.overlays = [
              fenix.overlay

              (import ./home/pkgs)
            ];
          }

          ./system/workstation
          ./shell/i3
          ./users/serowy.nix

          home.nixosModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.serowy = import ./home/environments/desktop-i3.nix;
            };
          }
        ];
      };

      desktop-nuc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./system/intel_nuc
          ./shell/i3
          ./users/serowy.nix

          home.nixosModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.serowy = import ./home/environments/desktop-i3.nix;
            };
          }
        ];
      };

      homeassistant = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hardware.nixosModules.raspberry-pi-4

          ./system/homeassistant
          ./shell/headless
          ./users/serowy.nix

          home.nixosModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.serowy = import ./home/environments/desktop-headless.nix;
            };
          }
        ];
      };
    };
  };
}
