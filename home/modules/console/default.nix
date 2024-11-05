{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.modules.console;

  system = "x86_64-linux";
  pinned = import
    (builtins.fetchGit {
      name = "tailspin_3_0_1";
      url = "https://github.com/NixOS/nixpkgs/";
      ref = "refs/heads/nixpkgs-unstable";
      rev = "05bbf675397d5366259409139039af8077d695ce";
    })
    { inherit system; };
in
{
  options.home.modules.console.enable = mkEnableOption "console";

  config = mkIf cnfg.enable {
    home = {
      components = {
        fzf.enable = true;
        git.enable = true;
        ssh.enable = true;
        zellij.enable = true;
      };

      modules = {
        neocode.enable = true;
        nushell.enable = true;
      };

      packages = with pkgs; [
        bat
        bottom
        curl
        lazygit
        ncurses
        pinned.tailspin

        yeet
        fd

        unixtools.watch
      ];
    };
  };
}
