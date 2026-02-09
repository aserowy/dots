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
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:NixOS/nixos-hardware/master";
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-kube-generators.url = "github:farcaller/nix-kube-generators";
    nixidy = {
      url = "github:arnarg/nixidy";
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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
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
      haumea,
      home,
      neocode,
      nix-kube-generators,
      nixidy,
      nixpkgs,
      noctalia,
      sops,
      yeet,
      zjstatus,
      ...
    }:
    let
      chartsBuilder =
        { pkgs }:
        let
          kubelib = nix-kube-generators.lib { inherit pkgs; };
        in
        haumea.lib.load {
          src = ./cluster/charts;
          loader = { ... }: p: kubelib.downloadHelmChart (import p);
          transformer = haumea.lib.transformers.liftDefault;
        };
    in
    {
      devShells.x86_64-linux.default = import ./.dev {
        inherit nixidy;

        charts = chartsBuilder { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
        lib = nixpkgs.lib;
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      darwinConfigurations."FR6NP4LHY7" = darwin.lib.darwinSystem {
        modules = [
          {
            nixpkgs.overlays = [
              neocode.overlays.default
              yeet.overlays.default
              (final: prev: { zjstatus = zjstatus.packages.${prev.stdenv.hostPlatform.system}.default; })
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
        "uitdeveloper" = home.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          modules = [
            {
              nixpkgs.overlays = [
                neocode.overlays.default
                yeet.overlays.default
                (final: prev: { zjstatus = zjstatus.packages.${prev.stdenv.hostPlatform.system}.default; })
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

        grans = nixpkgs.lib.nixosSystem {
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

            ./systems/grans
            {
              imports = [ ./users ];
              users = {
                setMutableUsers = true;

                root = {
                  enable = true;
                  sopsPasswordFilePath = "gran/root_password";
                };
                gran.enable = true;
              };
            }
          ];
        };

        musicstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko

            {
              nixpkgs.overlays = [
                yeet.overlays.default
              ];
            }

            ./systems/musicstation
            {
              imports = [ ./users ];
              users = {
                setMutableUsers = true;

                root = {
                  enable = true;
                  setInitialPassword = true;
                };
                music.enable = true;
              };
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
                setMutableUsers = true;

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
                (final: prev: { zjstatus = zjstatus.packages.${prev.stdenv.hostPlatform.system}.default; })
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
                extraSpecialArgs = { inherit noctalia; };

                useGlobalPkgs = true;
                useUserPackages = true;
                users.serowy = import ./home/workstation.nix;
              };
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
              users.root = {
                enable = true;
                sopsPasswordFilePath = "homelab/root_password";
              };
            }
          ];
        };

        homelab-02-l430 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops
            ./sops.nix

            ./systems/homelab-02-l430
            {
              imports = [ ./users ];
              users.root = {
                enable = true;
                sopsPasswordFilePath = "homelab/root_password";
              };
            }
          ];
        };

        homelab-03-t440s = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops
            ./sops.nix

            ./systems/homelab-03-t440s
            {
              imports = [ ./users ];
              users.root = {
                enable = true;
                sopsPasswordFilePath = "homelab/root_password";
              };
            }
          ];
        };

        homelab-04-t450 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops
            ./sops.nix

            ./systems/homelab-04-t450
            {
              imports = [ ./users ];
              users.root = {
                enable = true;
                sopsPasswordFilePath = "homelab/root_password";
              };
            }
          ];
        };

        homelab-05-t540p = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops.nixosModules.sops
            ./sops.nix

            ./systems/homelab-05-t540p
            {
              imports = [ ./users ];
              users.root = {
                enable = true;
                sopsPasswordFilePath = "homelab/root_password";
              };
            }
          ];
        };
      };

      nixidyEnvs.x86_64-linux = nixidy.lib.mkEnvs {
        charts = chartsBuilder { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        envs = {
          homelab.modules = [ ./cluster/homelab/default.nix ];
        };
      };
    };
}
