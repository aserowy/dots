#!/usr/bin/env nu

use workspace.nu *

def main [workspace_name: string = ''] {
    let wm = (get_current_wm)

    if $workspace_name == '' {
        let workspaces = (get_workspaces $wm 
            | get name
            | str join " ")

        let valid_defaults = (get_default_workspace_names
            | filter {|dflt| not ($workspaces | str contains $dflt)}
            | sort --ignore-case --natural
            | str join "\n")

        $valid_defaults
    } else {
        rename_workspace $wm (get_current_workspace_id $wm) $workspace_name
    }
}

def rename_workspace [wm: string, id: int, name: string] {
    match $wm {
        'Hyprland' => { (rename_hypr_ws $id $name) },
        'sway' => { run-external --redirect-stdout --redirect-stderr 'sawy' rename workspace to $name | ignore }
    }
}
