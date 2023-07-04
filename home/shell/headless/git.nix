{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lazygit
  ];

  programs.git = {
    enable = true;
    userName = "aserowy";
    userEmail = "serowy@hotmail.com";
    extraConfig = {
      core.editor = "nvim";
      credential.useHttpPath = "true";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
    };
    lfs = {
      enable = true;
    };
  };
}
