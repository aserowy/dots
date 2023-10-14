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
                (import ./pkgs)

                (neocode-overlay { system = "aarch64-darwin"; })
              ];
            }
            {
              home.homeDirectory = "/Users/alexander.serowy";
              home.stateVersion = "22.05";
              home.username = "alexander.serowy";
            }
            ./home/profiles/macos-work.nix
          ];
        };
        "serowy@DESKTOP-UVAKAQL" = home.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          modules = [
            {
              nixpkgs.overlays = [
                (import ./pkgs)

                (neocode-overlay { system = "x86_64-linux"; })
              ];
            }
            {
              home.homeDirectory = "/home/serowy";
              home.stateVersion = "22.05";
              home.username = "serowy";
            }
            ./home/profiles/wsl-work.nix
          ];
        };
        "uitdeveloper@UIN01PC013901" = home.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          modules = [
            {
              nixpkgs.overlays = [
                (import ./pkgs)

                (neocode-overlay { system = "x86_64-linux"; })
              ];
            }
            {
              home.homeDirectory = "/home/uitdeveloper";
              home.stateVersion = "22.05";
              home.username = "uitdeveloper";
            }
            ./home/profiles/wsl-ui.nix
          ];
        };
      };

      # TODO: system -> modules, hosts; home -> modules, profiles
      nixosConfigurations = {
        desktop-workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [
                fenix.overlays.default
                (import ./pkgs)

                (neocode-overlay { system = "x86_64-linux"; })
              ];
            }

            ./systems/hosts/workstation
            ./systems/modules/sway

            {
              imports = [ ./users ];

              config.users.serowy = {
                enable = true;
                dockerGroupMember = true;
              };
            }

            home.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/profiles/sway.nix;
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
                (import ./pkgs)

                (neocode-overlay { system = "x86_64-linux"; })
              ];
            }

            ./systems/hosts/intel_nuc
            ./systems/modules/headless
            {
              imports = [ ./users ];

              config.users.serowy = {
                enable = true;
              };
            }
            home.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/profiles/headless.nix;
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
                (import ./pkgs)

                (neocode-overlay { system = "aarch64-linux"; syncBuild = true; })
              ];
            }

            hardware.nixosModules.raspberry-pi-4

            ./systems/hosts/homeassistant
            ./systems/modules/headless
            {
              imports = [ ./users ];

              config.users.serowy = {
                enable = true;
              };
            }
            home.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/profiles/headless.nix;
              };
            }
          ];
        };
      };
    };
}
