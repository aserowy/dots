{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.podman;

  dockerCompat = pkgs.runCommandNoCC "docker-podman-compat" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.podman}/bin/podman $out/bin/docker
  '';
in
{
  options.home.components.podman = {
    enable = mkEnableOption "podman";
  };

  config = mkIf cnfg.enable {
    home = {
      file = {
        ".config/containers/registry.conf".source = builtins.toFile "podman-registry-conf" ''
          [registries.search]
          registries = ['docker.io']

          [registries.block]
          registries = []
        '';

        ".config/containers/default-policy.json".source = builtins.toFile "podman-default-policy" ''
          {
              "default": [
                  {
                      "type": "insecureAcceptAnything"
                  }
              ],
              "transports":
                  {
                      "docker-daemon":
                          {
                              "": [{"type":"insecureAcceptAnything"}]
                          }
                  }
          }
        '';
      };

      packages = with pkgs; [
        dockerCompat
        podman
        runc
        conmon
        skopeo
        slirp4netns
        fuse-overlayfs
      ];
    };
  };
}
