{
  description = "nix configurations";

  inputs = {
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    yeet = {
      url = "github:aserowy/yeet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, hardware, home, neocode, nixpkgs, yeet, ... }: {
    devShells = {
      aarch64-darwin.default = import ./.dev { pkgs = nixpkgs.legacyPackages.aarch64-darwin; };
      x86_64-linux.default = import ./.dev { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
    };

    darwinConfigurations."FR6NP4LHY7" = darwin.lib.darwinSystem {
      modules = [
        {
          nixpkgs.overlays = [
            neocode.overlays.default
            yeet.overlays.default
          ];
        }

        home.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."alexander.serowy" = import ./home/work-macos.nix;
          };
        }

        (import ./systems/fr6np4lhy7 self.rev or self.dirtyRev or null)
      ];
    };

    homeConfigurations = {
      "uitdeveloper@UIN01PC013901" = home.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          {
            nixpkgs.overlays = [
              neocode.overlays.default
              yeet.overlays.default
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
              neocode.overlays.default
              yeet.overlays.default
            ];
          }

          ./systems/workstation
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
              neocode.overlays.default
              yeet.overlays.default
            ];
          }

          ./systems/homeassistant-nuc
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
              neocode.overlays.default
              yeet.overlays.default
            ];
          }

          hardware.nixosModules.raspberry-pi-4

          ./systems/homeassistant
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
