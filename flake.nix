{
  description = "nix configurations";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:NixOS/nixos-hardware/master";
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixidy = {
      url = "github:arnarg/nixidy";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nixhelm = {
      url = "github:farcaller/nixhelm";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neocode = {
      url = "github:aserowy/neocode";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yeet = {
      url = "github:aserowy/yeet";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        rust-overlay.follows = "rust-overlay";
      };
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };

  outputs =
    {
      self,
      darwin,
      disko,
      hardware,
      home,
      neocode,
      nixidy,
      nixhelm,
      nixpkgs,
      sops,
      yeet,
      zjstatus,
      ...
    }:
    {
      devShells = {
        aarch64-darwin.default = import ./.dev {
          inherit nixidy;
          lib = nixpkgs.lib;
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        };
        x86_64-linux.default = import ./.dev {
          inherit nixidy;
          lib = nixpkgs.lib;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      };

      darwinConfigurations."FR6NP4LHY7" = darwin.lib.darwinSystem {
        modules = [
          {
            nixpkgs.overlays = [
              neocode.overlays.default
              yeet.overlays.default
              (final: prev: { zjstatus = zjstatus.packages.${prev.system}.default; })
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
                (final: prev: { zjstatus = zjstatus.packages.${prev.system}.default; })
              ];
            }

            ./home/work-ui.nix
          ];
        };
      };

      nixosConfigurations = {
        minimaliso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops.nixosModules.sops
            ./sops.nix

            (
              { pkgs, modulesPath, ... }:
              {
                imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
                environment.systemPackages = [ pkgs.neovim ];
                systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
              }
            )
            {
              imports = [ ./users ];
              users.root.enable = true;
            }
          ];
        };

        sims = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops
            ./sops.nix

            {
              nixpkgs.overlays = [
                yeet.overlays.default
              ];
            }

            ./systems/sims
            {
              imports = [ ./users ];
              users = {
                root.enable = true;
                sim.enable = true;
              };
            }
          ];
        };

        workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops
            ./sops.nix

            {
              nixpkgs.overlays = [
                neocode.overlays.default
                yeet.overlays.default
                (final: prev: { zjstatus = zjstatus.packages.${prev.system}.default; })
              ];
            }

            ./systems/workstation
            {
              imports = [ ./users ];
              users.serowy.enable = true;
            }
            home.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/workstation.nix;
              };
            }
          ];
        };

        homeassistant = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            sops.nixosModules.sops
            ./sops.nix

            hardware.nixosModules.raspberry-pi-4

            ./systems/homeassistant
            {
              imports = [ ./users ];
              users.root.enable = true;
            }
          ];
        };

        homelab-01-nuc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops
            ./sops.nix

            ./systems/homelab-01-nuc
            {
              imports = [ ./users ];
              users.root.enable = true;
            }
          ];
        };
      };

      nixidyEnvs.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        nixidy.lib.mkEnvs {
          inherit pkgs;

          charts = nixhelm.chartsDerivations.${pkgs.system};
          envs = {
            homelab.modules = [ ./cluster/homelab/default.nix ];
          };
        };
    };
}
