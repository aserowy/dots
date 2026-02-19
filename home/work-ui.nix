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
      brave = {
        enable = true;
        setDefaultBrowserSessionVariable = true;
      };
      ghostty.enable = true;
    };

    modules = {
      docker.enable = true;
      console.enable = true;

      nushell.appendedConfig = ''
        $env.SSH_AUTH_SOCK = "/run/user/1000/rbw/ssh-agent-socket"
      '';
    };

    packages = with pkgs; [
      rbw

      inter
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      powerline-fonts
    ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    git.settings.credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";

    ssh.matchBlocks = { };
  };
}
