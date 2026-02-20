{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cnfg = config.home.components.zellij;
in
{
  options.home.components.zellij.enable = mkEnableOption "zellij";

  config = mkIf cnfg.enable {
    home = {
      file.".config/zellij/config.kdl".source = ./config.kdl;

      file.".config/zellij/layouts/zjstatus.kdl".text = ''
        layout {
            default_tab_template {
                children
                pane size=1 borderless=true {
                    plugin location="file://${pkgs.zjstatus}/bin/zjstatus.wasm" {
                        format_left   "{mode}#[bg=#282c34,fg=#b9c0cb,bold] {session} {tabs}"
                        format_center ""
                        format_right  ""
                        format_space  ""
                        format_hide_on_overlength "true"
                        format_precedence "crl"

                        border_enabled  "false"

                        mode_normal        "#[bg=#3fc56b,fg=#282c34,bold] #[bg=#282c34,fg=#3fc56b]█"
                        mode_resize        "#[bg=#4483aa,fg=#282c34,bold] #[bg=#282c34,fg=#4483aa]█"
                        mode_scroll        "#[bg=#f9c859,fg=#282c34,bold] #[bg=#282c34,fg=#f9c859]█"
                        mode_rename_tab    "#[bg=#7a82da,fg=#282c34,bold] #[bg=#282c34,fg=#7a82da]█"
                        mode_rename_pane   "#[bg=#7a82da,fg=#282c34,bold] #[bg=#282c34,fg=#7a82da]█"
                        mode_enter_search  "#[bg=#ff936a,fg=#282c34,bold] #[bg=#282c34,fg=#ff936a]█"
                        mode_search        "#[bg=#ff936a,fg=#282c34,bold] #[bg=#282c34,fg=#ff936a]█"
                        mode_session       "#[bg=#ff78f8,fg=#282c34,bold] #[bg=#282c34,fg=#ff78f8]█"
                        mode_tmux          "#[bg=#10b1fe,fg=#282c34,bold] #[bg=#282c34,fg=#10b1fe]█"

                        // formatting for inactive tabs
                        tab_normal              "#[bg=#282c34,fg=#10b1fe]█#[bg=#10b1fe,fg=#282c34,bold]{index} #[bg=#282c34,fg=#b9c0cb,bold] {name}{floating_indicator}#[bg=#282c34,fg=#282c34,bold]█"
                        tab_normal_fullscreen   "#[bg=#282c34,fg=#10b1fe]█#[bg=#10b1fe,fg=#282c34,bold]{index} #[bg=#282c34,fg=#b9c0cb,bold] {name}{fullscreen_indicator}#[bg=#282c34,fg=#282c34,bold]█"
                        tab_normal_sync         "#[bg=#282c34,fg=#10b1fe]█#[bg=#10b1fe,fg=#282c34,bold]{index} #[bg=#282c34,fg=#b9c0cb,bold] {name}{sync_indicator}#[bg=#282c34,fg=#282c34,bold]█"

                        // formatting for the current active tab
                        tab_active              "#[bg=#41444d,fg=#ff936a]█#[bg=#ff936a,fg=#41444d,bold]{index} #[bg=#41444d,fg=#b9c0cb,bold] {name}{floating_indicator}#[bg=#41444d,fg=#41444d,bold]█"
                        tab_active_fullscreen   "#[bg=#41444d,fg=#ff936a]█#[bg=#ff936a,fg=#41444d,bold]{index} #[bg=#41444d,fg=#b9c0cb,bold] {name}{fullscreen_indicator}#[bg=#41444d,fg=#41444d,bold]█"
                        tab_active_sync         "#[bg=#41444d,fg=#ff936a]█#[bg=#ff936a,fg=#41444d,bold]{index} #[bg=#41444d,fg=#b9c0cb,bold] {name}{sync_indicator}#[bg=#41444d,fg=#41444d,bold]█"

                        // separator between the tabs
                        tab_separator           "#[bg=#282c34] "

                        // indicators
                        tab_sync_indicator       " "
                        tab_fullscreen_indicator " 󰊓"
                        tab_floating_indicator   " 󰹙"

                        command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                        command_git_branch_format      "#[fg=blue] {stdout} "
                        command_git_branch_interval    "10"
                        command_git_branch_rendermode  "static"

                        datetime        "#[fg=#6C7086,bold] {format} "
                        datetime_format "%A, %d %b %Y %H:%M"
                        datetime_timezone "Europe/London"
                    }
                }
            }
        }
      '';

      packages = with pkgs; [
        chafa
        zellij
      ];
    };
  };
}
