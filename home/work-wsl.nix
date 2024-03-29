{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/home/serowy";
    username = "serowy";

    components.docker.enable = true;
  };

  programs = {
    home-manager.enable = true;

    git = {
      extraConfig = {
        credential.helper = "/mnt/c/Users/serowy/scoop/shims/git-credential-manager.exe";
      };
    };
    ssh.matchBlocks = { };
  };
}
