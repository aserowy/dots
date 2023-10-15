{ pkgs, ... }:
{
  imports = [
    ../modules/sway
    ./base.nix
  ];

  home = {
    modules = {
      docker.enable = true;
      onedrive.enable = true;
      vscode.enable = true;
    };

    packages = with pkgs; [
      obsidian
    ];
  };
}
