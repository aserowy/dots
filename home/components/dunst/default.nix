{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.dunst;
in
{
  options.home.components.dunst = {
    enable = mkEnableOption "dunst";

    enableSwayIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the dunst daemon gets started while running sway.
      '';
    };

    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, the dunst daemon gets started while running hyprland.
      '';
    };
  };

  config =
    let
      categories = [
        "actions"
        "animations"
        "apps"
        "categories"
        "devices"
        "emblems"
        "emotes"
        "filesystem"
        "intl"
        "legacy"
        "mimetypes"
        "places"
        "status"
        "stock"
      ];

      mkPath = { category }: "${pkgs.paper-icon-theme}/share/icons/Paper/32x32/${category}";

      icon_paths = lib.concatMapStringsSep ":" mkPath (lib.cartesianProductOfSets {
        category = categories;
      });
    in
    mkIf cnfg.enable {
      home = {
        packages = with pkgs; [
          dunst
        ];

        # TODO: change to module launcher: add opts for browser and launcher
        file.".config/dunst/dunstrc".text = ''
          [global]
          alignment="center"
          always_run_script="true"
          browser="${pkgs.microsoft-edge-beta}/microsoft-edge-beta"
          corner_radius=6
          dmenu="${pkgs.rofi}/bin/rofi -dmenu"
          follow="none"
          font="FiraCode Nerd Font Mono 10"
          format="<b>%s</b>\n%b"
          frame_color="#23272e"
          frame_width=10
          icon_path="${icon_paths}"
          icon_position="left"
          markup="full"
          max_icon_size=32
          mouse_left_click="do_action,close_current"
          mouse_right_click="close_current"
          origin="bottom-right"
          offset="20x20"
          separator_color="frame"
          separator_height=10
          stack_duplicates="true"
          startup_notification="false"
          transparency=0
          width=400
          word_wrap="yes"

          [urgency_critical]
          background="#23272e"
          foreground="#e06c75"
          timeout=0

          [urgency_low]
          background="#23272e"
          foreground="#abb2bf"
          timeout=10

          [urgency_normal]
          background="#23272e"
          foreground="#abb2bf"
          timeout=10
        '';
      };

      home.modules.sway.additionalConfig = mkIf cnfg.enableSwayIntegration ''
        # Start dunst daemon to enable notifications
        exec dunst -conf ~/.config/dunst/dunstrc
      '';

      home.modules.hyprland.additionalConfig = mkIf cnfg.enableHyprlandIntegration ''
        # Start dunst daemon to enable notifications
        exec-once = dunst -conf ~/.config/dunst/dunstrc
      '';
    };
}
