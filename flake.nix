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
          inherit self nixidy;
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        };
        x86_64-linux.default = import ./.dev {
          inherit self nixidy;
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
        workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
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

        homeassistant = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            {
              nixpkgs.overlays = [
                neocode.overlays.default
                yeet.overlays.default
                (final: prev: { zjstatus = zjstatus.packages.${prev.system}.default; })
              ];
            }

            hardware.nixosModules.raspberry-pi-4

            ./systems/homeassistant
            {
              imports = [ ./users ];
              users.serowy.enable = true;
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

        homelab-01-nuc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops

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

      packages.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        {
          generators = {
            cilium = nixidy.packages.${pkgs.system}.generators.fromCRD {
              name = "cilium";
              src = pkgs.fetchFromGitHub {
                owner = "cilium";
                repo = "cilium";
                rev = "v1.16.0";
                hash = "sha256-LJrNGHF52hdKCuVwjvGifqsH+8hxkf/A3LZNpCHeR7E=";
              };
              crds = [
                "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumnetworkpolicies.yaml"
                "pkg/k8s/apis/cilium.io/client/crds/v2/ciliumclusterwidenetworkpolicies.yaml"
              ];
            };
          };
        };
    };
}
