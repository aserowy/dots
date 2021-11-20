{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.openssh
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
    };
  };
}
