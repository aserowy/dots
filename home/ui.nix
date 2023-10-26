{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  imports = [
    ./base.nix
  ];

  home = {
    homeDirectory = "/home/uitdeveloper";
    username = "uitdeveloper";
  };

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
