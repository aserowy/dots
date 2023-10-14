{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  imports = [
    ../modules/headless
  ];


  programs = {
    git = {
      extraConfig = {
        credential.helper = "/mnt/c/Users/serowy/scoop/shims/git-credential-manager.exe";
      };
    };
    ssh.matchBlocks = { };
  };
}
