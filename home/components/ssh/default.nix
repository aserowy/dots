{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.ssh;
in
{
  options.home.components.ssh.enable = mkEnableOption "ssh";

  config = mkIf cnfg.enable {
    home.packages = with pkgs; [
      openssh
    ];

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "desktop-workstation" = {
          hostname = "desktop-workstation";
          user = "serowy";
          identitiesOnly = true;
          identityFile = " ~/.ssh/internal_serowy_ed25519";
        };
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identitiesOnly = true;
          identityFile = " ~/.ssh/github_aserowy_ed25519";
        };
        "homeassistant" = {
          hostname = "homeassistant";
          user = "serowy";
          identitiesOnly = true;
          identityFile = " ~/.ssh/internal_serowy_ed25519";
        };
        "homelab-01-nuc" = {
          hostname = "homelab-01-nuc";
          user = "serowy";
          identitiesOnly = true;
          identityFile = " ~/.ssh/internal_serowy_ed25519";
        };

        "ssh.dev.azure.com" = {
          hostname = "ssh.dev.azure.com";
          user = "git";
          identitiesOnly = true;
          identityFile = " ~/.ssh/devops_also_rsa";
          extraOptions = {
            HostKeyAlgorithms = "+ssh-rsa";
            PubkeyAcceptedKeyTypes = "ssh-rsa";
          };
        };
        "vs-ssh.visualstudio.com" = {
          hostname = "vs-ssh.visualstudio.com";
          user = "SamsungKNOX";
          identitiesOnly = true;
          identityFile = " ~/.ssh/devops_also_rsa";
          extraOptions = {
            HostKeyAlgorithms = "+ssh-rsa";
            PubkeyAcceptedKeyTypes = "ssh-rsa";
          };
        };
      };
    };
  };
}
