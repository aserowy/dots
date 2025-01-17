#!/usr/bin/env nu

(niri msg --json workspaces
    | from json
    | where $it.name != null and $it.active_window_id == null
    | each {|it| (niri msg action unset-workspace-name $it.name)})

let workspaces = (niri msg --json workspaces | from json)

let current_names = ($workspaces
    | where name != null
    | get name)

let current_names_string = ($current_names
    | append ["dots", "gaming", "social", "work"]
    | uniq
    | sort
    | str join "\n")

let selection = ($current_names_string | fuzzel --dmenu)

if $selection in $current_names {
    (niri msg action focus-workspace $selection)
} else {
    let current_monitor = (niri msg --json focused-output | from json | get name)
    let last_workspace_id = ($workspaces
        | where $it.output == $current_monitor
        | sort-by idx
        | last
        | get id)

    (niri msg action focus-workspace $last_workspace_id)
    (niri msg action set-workspace-name $selection)
}
