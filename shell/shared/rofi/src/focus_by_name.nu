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
        focus_workspace $workspace_name
    }
}

def get_workspaces [] {
    if (env | any { |e| $e.name == 'WAYLAND_DISPLAY'}) {
        (swaymsg -t get_workspaces -r)
    } else {
        (i3-msg -t get_workspaces)
    }
}

def focus_workspace [name: string] {
    if (env | any { |e| $e.name == 'WAYLAND_DISPLAY'}) {
        run-external --redirect-stdout --redirect-stderr 'swaymsg' workspace $name | ignore
    } else {
        run-external --redirect-stdout --redirect-stderr 'i3-msg' workspace $name | ignore
    }
}
