{ pkgs, ... }:
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

    file = {
      ".config/wezterm/wezterm.lua".source = ./components/wezterm/wezterm.lua;

      ".zshrc".source = builtins.toFile "user-zshrc" ''
        export PATH=/run/current-system/sw/bin:/etc/profiles/per-user/alexander.serowy/bin:$PATH

        nu
      '';
    };

    packages = with pkgs;
      [
        nerdfonts
      ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    ssh.matchBlocks = { };
  };
}
