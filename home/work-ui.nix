{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/home/uitdeveloper";
    username = "uitdeveloper";

    sessionVariables = {
      NODE_TLS_REJECT_UNAUTHORIZED = 0;
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
    };

    components = {
      brave = {
        enable = true;
        setDefaultBrowserSessionVariable = true;
      };
      ghostty.enable = true;
    };

    modules = {
      docker.enable = true;
      console.enable = true;
    };

    packages = with pkgs; [
      firefox
      inter
      powerline-fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    git.settings.credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";

    ssh.matchBlocks = { };
  };
}
