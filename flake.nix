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

    chrome-pwa.url = "github:aserowy/nixos-chrome-pwa";
    neocode = {
      url = "github:aserowy/neocode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { fenix, hardware, home, nixpkgs, chrome-pwa, neocode, ... }:
    let
      neocode-overlay = { system, syncBuild ? false }: (final: prev: {
        neocode = neocode.defaultPackage.${system}.override {
          syncBuild = syncBuild;
        };
      });
    in
    {
      devShells.x86_64-linux.default = import ./.dev { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

      homeConfigurations = {
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
            ./home/environments/wsl-work.nix
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
            ./home/environments/wsl-ui.nix
          ];
        };
      };

      nixosConfigurations = {
        desktop-workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            chrome-pwa.nixosModule
            {
              nixpkgs.overlays = [
                fenix.overlays.default
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
                users.serowy = import ./home/environments/sway.nix;
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

            ./system/intel_nuc
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
