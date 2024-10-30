{ config, lib, pkgs, ... }:
with lib;

let
  cnfg = config.home.components.zellij;
in
{
  options.home.components.zellij.enable = mkEnableOption "zellij";

  config = mkIf cnfg.enable {
    home = {
      file.".config/zellij/config.kdl".source = ./config.kdl;

      file.".config/zellij/layouts/compact.kdl".text = ''
        layout {
            default_tab_template {
                children
                pane size=1 borderless=true {
                    plugin location="file://${pkgs.zjstatus}/bin/zjstatus.wasm" {
                        format_left   "{mode}#[bg=#282c34] {tabs}"
                        format_center ""
                        format_right  "#[bg=#282c34,fg=#10b1fe]█#[bg=#10b1fe,fg=#282c34,bold] #[bg=#41444d,fg=#b9c0cb,bold] {session} #[bg=#41444d,fg=#b9c0cb,bold]"
                        format_space  ""
                        format_hide_on_overlength "true"
                        format_precedence "crl"

                        border_enabled  "false"
                        border_char     "─"
                        border_format   "#[fg=#6C7086]{char}"
                        border_position "top"

                        mode_normal        "#[bg=#3fc56b,fg=#41444d,bold] NORMAL#[bg=#41444d,fg=#3fc56b]█"
                        mode_locked        "#[bg=#41444d,fg=#41444d,bold] LOCKED#[bg=#41444d,fg=#41444d]█"
                        mode_resize        "#[bg=#fc2f52,fg=#41444d,bold] RESIZE#[bg=#41444d,fg=#fc2f52]█"
                        mode_pane          "#[bg=#10b1fe,fg=#41444d,bold]  PANE #[bg=#41444d,fg=#10b1fe]█"
                        mode_tab           "#[bg=#7a82da,fg=#41444d,bold]  TAB  #[bg=#41444d,fg=#7a82da]█"
                        mode_scroll        "#[bg=#f9c859,fg=#41444d,bold] SCROLL#[bg=#41444d,fg=#f9c859]█"
                        mode_enter_search  "#[bg=#10b1fe,fg=#41444d,bold] SEARCH#[bg=#41444d,fg=#10b1fe]█"
                        mode_search        "#[bg=#10b1fe,fg=#41444d,bold] SEARCH#[bg=#41444d,fg=#10b1fe]█"
                        mode_rename_tab    "#[bg=#7a82da,fg=#41444d,bold] RENAME#[bg=#41444d,fg=#7a82da]█"
                        mode_rename_pane   "#[bg=#10b1fe,fg=#41444d,bold] RENAME#[bg=#41444d,fg=#10b1fe]█"
                        mode_session       "#[bg=#ff78f8,fg=#41444d,bold]  SESS #[bg=#41444d,fg=#ff78f8]█"
                        mode_move          "#[bg=#ffffff,fg=#41444d,bold]  MOVE #[bg=#41444d,fg=#ffffff]█"
                        mode_prompt        "#[bg=#10b1fe,fg=#41444d,bold] PROMPT#[bg=#41444d,fg=#10b1fe]█"
                        mode_tmux          "#[bg=#ff936a,fg=#41444d,bold]  TMUX #[bg=#41444d,fg=#ff936a]█"

                        // formatting for inactive tabs
                        tab_normal              "#[bg=#41444d,fg=#10b1fe]█#[bg=#10b1fe,fg=#41444d,bold]{index} #[bg=#41444d,fg=#b9c0cb,bold] {name}{floating_indicator}#[bg=#41444d,fg=#41444d,bold]█"
                        tab_normal_fullscreen   "#[bg=#41444d,fg=#10b1fe]█#[bg=#10b1fe,fg=#41444d,bold]{index} #[bg=#41444d,fg=#b9c0cb,bold] {name}{fullscreen_indicator}#[bg=#41444d,fg=#41444d,bold]█"
                        tab_normal_sync         "#[bg=#41444d,fg=#10b1fe]█#[bg=#10b1fe,fg=#41444d,bold]{index} #[bg=#41444d,fg=#b9c0cb,bold] {name}{sync_indicator}#[bg=#41444d,fg=#41444d,bold]█"

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
        zellij
      ];
    };
  };
}
