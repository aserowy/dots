{ config, lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/Users/alexander.serowy";
    username = "alexander.serowy";

    components = {
      docker.enable = true;
    };

    file.".config/wezterm/wezterm.lua" = {
      source = ./components/wezterm/wezterm.lua;
    };

    packages = with pkgs; [
      nerdfonts
    ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    ssh.matchBlocks = { };
  };
}
