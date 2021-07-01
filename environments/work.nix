{ config, pkgs, ... }:
{
  programs.ssh.matchBlocks = {
    "vs-ssh.visualstudio.com" = {
      hostname = "vs-ssh.visualstudio.com";
      user = "SamsungKNOX";
      identitiesOnly = true;
      identityFile = " ~/.ssh/devops_also_rsa";
    };
  };
}
