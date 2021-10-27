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
      "192.168.178.53" = {
        hostname = "192.168.178.53";
        user = "serowy";
        identitiesOnly = true;
        identityFile = " ~/.ssh/desktop-nix_serowy_ed25519";
      };
    };
  };
}
