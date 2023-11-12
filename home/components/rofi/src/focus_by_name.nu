#!/usr/bin/env nu

use workspace.nu *

def main [workspace_name: string = ''] {
    let wm = (get_current_wm)

    if $workspace_name == '' {
        (get_workspace_names_with_defaults | str join "\n")
    } else {
        focus_workspace $wm $workspace_name
    }
}

def focus_workspace [wm: string, name: string] {
    match $wm {
        'Hyprland' => { run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch workspace $"name:($name)" | ignore },
        'sway' => { run-external --redirect-stdout --redirect-stderr 'swaymsg' workspace $name | ignore }
    }
}

#         let is_existing = (get_workspace_names | any {|it| $it == $workspace_name })
#
#         focus_workspace $wm $workspace_name $is_existing
#     }
# }
#
# def focus_workspace [wm: string, name: string, is_existing: bool] {
#     match $wm {
#         'Hyprland' => { 
#             let id = $name
#                 | str substring --utf-8-bytes 0..9 | str upcase
#                 | encode utf8
#                 | to text
#                 | str trim -c '['
#                 | str trim -c ']'
#                 | split row ', '
#                 | each {|it| ($it | into int | $in - 47 | into string | fill -a right -c '0' -w 2)}
#                 | str join
#                 | fill -a left -c '0' -w 18
#                 | into int
#
#             run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch workspace $"($id)"
#                 # | ignore
#
#             if $is_existing {
#                 run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch renameworkspace $id $name
#                     # | ignore 
#             }
#         },
#         'sway' => { run-external --redirect-stdout --redirect-stderr 'swaymsg' workspace $name | ignore }
#     }
# }
