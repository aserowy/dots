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

  outputs = { fenix, hardware, home, nixpkgs, neocode, ... }:
    let
      neocode-overlay = { system, syncBuild ? false }: (final: prev: {
        neocode = neocode.defaultPackage.${system}.override {
          syncBuild = syncBuild;
        };
      });
    in
    {
      devShell.x86_64-linux = import ./.dev { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

      homeConfigurations = {
        "serowy@DESKTOP-UVAKAQL" = home.lib.homeManagerConfiguration {
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = [
              (import ./pkgs)

              (neocode-overlay { system = "x86_64-linux"; })
            ];
            imports = [
              ./home/environments/wsl-work.nix
            ];
          };
          homeDirectory = "/home/serowy";
          stateVersion = "21.05";
          system = "x86_64-linux";
          username = "serowy";
        };
      };

      nixosConfigurations = {
        desktop-workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [
                fenix.overlay
                (import ./pkgs)

                (neocode-overlay { system = "x86_64-linux"; })
              ];
            }

            ./system/workstation
            ./shell/sway
            ./users/serowy_with_docker.nix

            home.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/environments/i3.nix;
              };
            }
          ];
        };

        desktop-nuc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [
                fenix.overlay
                (import ./pkgs)

                (neocode-overlay { system = "x86_64-linux"; })
              ];
            }

            ./system/intel_nuc
            ./shell/i3
            ./users/serowy.nix

            home.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/environments/i3.nix;
              };
            }
          ];
        };

        homeassistant = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            {
              nixpkgs.overlays = [
                fenix.overlay
                (import ./pkgs)

                (neocode-overlay { system = "aarch64-linux"; syncBuild = true; })
              ];
            }

            hardware.nixosModules.raspberry-pi-4

            ./system/homeassistant
            ./shell/headless
            ./users/serowy.nix

            home.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/environments/headless.nix;
              };
            }
          ];
        };
      };
    };
}
