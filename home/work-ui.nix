{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/home/uitdeveloper";
    username = "uitdeveloper";

    components = {
      foot = {
        enable = true;
        setDpiAware = false;
      };
      podman.enable = true;
    };

    packages = with pkgs; [
      inter
      powerline-fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    git = {
      extraConfig = {
        credential.helper = "/mnt/c/Users/ee03927_admin/scoop/shims/git-credential-manager.exe";
      };
    };

    ssh.matchBlocks = { };
  };
}
