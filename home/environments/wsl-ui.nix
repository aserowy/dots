{ ... }:
{
  # FIX: https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  programs.home-manager.enable = true;

  imports = [
    ../shell/headless
  ];

  programs = {
    git = {
      extraConfig = {
        credential.helper = "/mnt/c/Users/ee03927_admin/scoop/shims/git-credential-manager.exe";
      };
    };
    ssh.matchBlocks = { };
  };
}
