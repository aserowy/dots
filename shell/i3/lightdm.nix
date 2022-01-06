{ config, pkgs, ... }:
{
  services.xserver.displayManager.lightdm.greeters.mini = {
    enable = true;
    user = "serowy";
    extraConfig = ''
      [greeter]
      show-password-label = false

      [greeter-theme]
      text-color = "#abb2bf"
      error-color = "#e06c75"

      background-image = ""
      background-color = "#23272e"
      border-width = 0px

      window-color = "#23272e"
      border-color = "#23272e"
      border-width = 10px

      layout-space = 15
      password-background-color = "#23272e"
      password-border-width = 0px

      password-color = "#98c379"
    '';
  };
}
