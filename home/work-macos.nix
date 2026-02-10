{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/Users/alexander.serowy";
    username = "alexander.serowy";

    modules = {
      docker.enable = true;
      console.enable = true;
    };

    file = {
      # NOTE: ghostty is installed on system level with brew
      ".config/ghostty/config".source = ./components/ghostty/ghostty.config;

      ".zshrc".source = builtins.toFile "user-zshrc" ''
        export PATH=/run/current-system/sw/bin:/etc/profiles/per-user/alexander.serowy/bin:$PATH
        nu; exit
      '';
    };

    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    ssh.matchBlocks = { };
  };
}
