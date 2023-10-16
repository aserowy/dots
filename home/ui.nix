{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/home/uitdeveloper";
    stateVersion = "22.05";
    username = "uitdeveloper";
  };

  programs = {
    git = {
      extraConfig = {
        credential.helper = "/mnt/c/Users/ee03927_admin/scoop/shims/git-credential-manager.exe";
      };
    };
    ssh.matchBlocks = { };
  };
}
