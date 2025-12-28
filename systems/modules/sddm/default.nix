{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.services.modules.sddm;
in
{
  options.services.modules.sddm = {
    enable = mkEnableOption "sddm";

    session = mkOption {
      type = types.str;
      default = "";
      description = ''
        Session that gets started after successful authentification.
      '';
    };

    theme =
      let
        configs = map (c: head (strings.splitString "." (baseNameOf c))) (
          lib.filesystem.listFilesRecursive "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme/Themes"
        );
      in
      mkOption {
        default = "astronaut";
        type = lib.types.enum configs;
      };
  };

  config = mkIf cnfg.enable {
    boot.kernelParams = [ "console=tty1" ];

    environment.systemPackages = with pkgs; [
      (sddm-astronaut.override {
        embeddedTheme = cnfg.theme;
      })
    ];

    services.displayManager = {
      defaultSession = cnfg.session;
      sddm = {
        enable = true;
        enableHidpi = true;
        wayland.enable = true;

        theme = "sddm-astronaut-theme";
        extraPackages = with pkgs; [
          sddm-astronaut
        ];
      };
    };
  };
}
