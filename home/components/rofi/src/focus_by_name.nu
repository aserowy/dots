#!/usr/bin/env nu

use workspace.nu *

def main [workspace_name: string = ''] {
    if $workspace_name == '' {
        (get_workspace_names_with_defaults | str join "\n")
    } else {
        focus_workspace $workspace_name
    }
}

def focus_workspace [name: string] {
    let wm = (get_current_wm)

    match $wm {
        'Hyprland' => {
            let workspaces = (get_workspaces $wm)

            let is_existing = $workspaces
                | any {|it| $it.name == $name }

            if $is_existing {
                run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch workspace $"name:($name)" 
                    | ignore
            } else {
                let id = (get_workspace_id_by_name $workspaces $name)

                run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch workspace $"($id)"
                    | ignore 

                run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch renameworkspace $id $name
                    | ignore 

                # FIX: remove pkill after waybar sorts ws after renaming
                run-external --redirect-stdout --redirect-stderr 'pkill' '-SIGUSR2' 'waybar'
            }
        },
        'sway' => { run-external --redirect-stdout --redirect-stderr 'swaymsg' workspace $name | ignore }
    }
}

def get_workspace_id_by_name [workspaces: list<any>, name: string] {
    mut min = 1;
    mut max = 2147483647;

    let sorted = ($workspaces
        | select id name
        | where id > 0
        | append {id: 0, name: $name}
        | sort-by name --ignore-case --natural)
    
    mut switch = true;
    for ws in $sorted {
        if $ws.id == 0 {
            $switch = false
        } else if $switch {
            if $min < $ws.id {
                $min = $ws.id
            }
        } else {
            if $max > $ws.id {
                $max = $ws.id
            }
        }
    }

    return (($min + $max) / 2 | into int)
}
