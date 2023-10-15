{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  imports = [
    ./base.nix
  ];

  home.modules.docker.enable = true;

  programs = {
    git = {
      extraConfig = {
        credential.helper = "/mnt/c/Users/serowy/scoop/shims/git-credential-manager.exe";
      };
    };
    ssh.matchBlocks = { };
  };
}
