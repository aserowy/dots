{ config, pkgs, ... }:
{
  imports = [
    ./wsl.nix
  ];

  programs.ssh.matchBlocks = {
    "ssh.dev.azure.com" = {
      hostname = "ssh.dev.azure.com";
      user = "git";
      identitiesOnly = true;
      identityFile = " ~/.ssh/devops_also_rsa";
    };
    "vs-ssh.visualstudio.com" = {
      hostname = "vs-ssh.visualstudio.com";
      user = "SamsungKNOX";
      identitiesOnly = true;
      identityFile = " ~/.ssh/devops_also_rsa";
    };
  };
}
