{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  imports = [
    ../shell/headless
  ];

  programs.ssh.matchBlocks = {
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
}