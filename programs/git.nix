{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "aserowy";
    userEmail = "serowy@hotmail.com";
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
    };
  };
}
