{
  description = "NixOS configurations";

  inputs = {
    fenix.url = "github:nix-community/fenix";
    hardware.url = "github:NixOS/nixos-hardware/master";
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neocode = {
      url = "github:aserowy/neocode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { fenix, hardware, home, neocode, nixpkgs, ... }: {
    devShells = {
      aarch64-darwin.default = import ./.dev { pkgs = nixpkgs.legacyPackages.aarch64-darwin; };
      x86_64-linux.default = import ./.dev { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
    };

    homeConfigurations = {
      "alexander.serowy@CR345Q2G4C" = home.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;

        modules = [
          {
            nixpkgs.overlays = [
              neocode.overlays.default
              (import ./pkgs)
            ];
          }
          ./home/work-macos.nix
        ];
      };
      "serowy@DESKTOP-UVAKAQL" = home.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          {
            nixpkgs.overlays = [
              neocode.overlays.default
              (import ./pkgs)
            ];
          }
          ./home/work-wsl.nix
        ];
      };
      "uitdeveloper@UIN01PC013901" = home.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          {
            nixpkgs.overlays = [
              neocode.overlays.default
              (import ./pkgs)
            ];
          }
          ./home/ui.nix
        ];
      };
    };

    nixosConfigurations = {
      workstation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.overlays = [
              fenix.overlays.default
              neocode.overlays.default
              (import ./pkgs)
            ];
          }

          ./hosts/workstation
          ./systems/workstation.nix
          {
            imports = [ ./users ];

            users.serowy = {
              enable = true;
              dockerGroupMember = true;
            };
          }
          home.nixosModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.serowy = import ./home/workstation.nix;
            };
          }
        ];
      };

      homeassistant-nuc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.overlays = [
              fenix.overlays.default
              neocode.overlays.default
              (import ./pkgs)
            ];
          }

          ./hosts/homeassistant-nuc
          ./systems/homeassistant.nix
          {
            imports = [ ./users ];

            users.serowy = {
              enable = true;
            };
          }
          home.nixosModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.serowy = import ./home/homeassistant.nix;
            };
          }
        ];
      };

      homeassistant = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          {
            nixpkgs.overlays = [
              fenix.overlays.default
              neocode.overlays.default
              (import ./pkgs)
            ];
          }

          hardware.nixosModules.raspberry-pi-4

          ./hosts/homeassistant
          ./systems/homeassistant.nix
          {
            imports = [ ./users ];

            users.serowy = {
              enable = true;
            };
          }
          home.nixosModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.serowy = import ./home/homeassistant.nix;
            };
          }
        ];
      };
    };
  };
}
