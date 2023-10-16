{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/home/serowy";
    username = "serowy";

    modules.docker.enable = true;
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
