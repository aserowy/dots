#!/usr/bin/env nu

let predefined = [dots gaming notes social work]

def main [workspace_name: string = ''] {

    let workspaces = (get_workspaces
        | from json 
        | get name
        | append $predefined
        | uniq
        | sort --ignore-case --natural)

    if $workspace_name == '' {
        ($workspaces | str join "\n")
    } else {
        move_to_workspace $workspace_name
    }
}

def get_workspaces [] {
    if 'WAYLAND_DISPLAY' in $env {
        (swaymsg -t get_workspaces -r)
    } else {
        (i3-msg -t get_workspaces)
    }
}

def move_to_workspace [name: string] {
    if 'WAYLAND_DISPLAY' in $env {
        run-external --redirect-stdout --redirect-stderr 'swaymsg' move container to workspace $name | ignore
    } else {
        run-external --redirect-stdout --redirect-stderr 'i3-msg' move container to workspace $name | ignore
    }
}
