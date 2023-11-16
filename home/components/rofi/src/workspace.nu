#!/usr/bin/env nu

export def get_special_workspace_names [] {
    [empty previous special]
}

export def get_default_workspace_names [] {
    [dots gaming notes social work]
}

export def get_current_wm [] {
    $env.XDG_CURRENT_DESKTOP
}

export def get_current_workspace_id [wm: string] {
    match $wm {
        'Hyprland' => { (hyprctl activeworkspace -j | from json).id },
        'sway' => { 0 }
    }
}

export def get_workspaces [wm: string] {
    match $wm {
        'Hyprland' => (hyprctl workspaces -j | from json),
        'sway' => (swaymsg -t get_workspaces -r | from json)
    }
}

export def get_workspace_names [] {
    let specials = (get_special_workspace_names)

    let wm = (get_current_wm)
    let workspaces = (get_workspaces $wm
        | get name
        | filter {|nm| ($specials | all {|| $in != $nm })}
        | uniq
        | sort --ignore-case --natural)

    $workspaces
}

export def get_workspace_names_with_defaults [] {
    let predefined = (get_default_workspace_names)

    let workspaces = (get_workspace_names
        | append $predefined
        | uniq
        | sort --ignore-case --natural)

    $workspaces
}

export def create_or_focus_hypr_ws_with [verb: string, name: string] {
    let wm = (get_current_wm)
    let workspaces = (get_workspaces $wm)
    let is_existing = $workspaces
        | any {|it| $it.name == $name }

    if $is_existing {
        run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch $verb $"name:($name)"
            | ignore
    } else {
        let id = (get_hypr_workspace_id_by_name $workspaces $name)

        run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch $verb $id
            | ignore 

        (rename_hypr_ws $id $name)
    }
}

export def rename_hypr_ws [id: int, name: string] {
    run-external --redirect-stdout --redirect-stderr 'hyprctl' dispatch renameworkspace $id $name
        | ignore 

    # FIX: remove pkill after waybar sorts ws after renaming
    run-external --redirect-stdout --redirect-stderr 'pkill' '-SIGUSR2' 'waybar'
}

def get_hypr_workspace_id_by_name [workspaces: list<any>, name: string] {
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
