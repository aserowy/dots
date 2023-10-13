{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerdfonts
  ];

  imports = [
    ../shared/obsidian.nix
    ../shared/vscode.nix
  ];
}
