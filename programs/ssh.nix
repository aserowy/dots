{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.openssh
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
        identityFile = " ~/.ssh/github_aserowy_ed25519";
      };
    };
  };
}
