{ config, pkgs, ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        alignment = "center";
        always_run_script = "true";
        corner_radius = 0;
        follow = "none";
        font = "FiraCode Nerd Font Mono 10";
        format = "<b>%s</b>\\n%b";
        frame_color = "#23272e";
        frame_width = 10;
        geometry = "400x5-20-20";
        icon_position = "left";
        markup = "full";
        max_icon_size = 32;
        mouse_left_click = "do_action,close_current";
        mouse_right_click = "close_current";
        separator_color = "frame";
        separator_height = 10;
        stack_duplicates = "true";
        startup_notification = "false";
        transparency = 0;
        word_wrap = "yes";

        dmenu = "${pkgs.rofi}/bin/rofi -dmenu";
        browser = "${pkgs.edge}/bin/microsoft-edge-beta";
      };

      urgency_low = {
        background = "#23272e";
        foreground = "#ABB2BF";
        timeout = 10;
      };
      urgency_normal = {
        background = "#23272e";
        foreground = "#ABB2BF";
        timeout = 10;
      };
      urgency_critical = {
        background = "#23272e";
        foreground = "#e06c75";
        timeout = 0;
      };
    };
  };
}

