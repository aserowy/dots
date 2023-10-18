#!/usr/bin/env nu

def main [direction: string] {
    let active_workspace = (hyprctl activewindow -j
        | from json
        | get workspace.id)

    let output = (hyprctl workspaces -j
        | from json
        | where id == $active_workspace
        | get monitor
        | first)

    let workspaces = (hyprctl workspaces -j
        | from json
        | where monitor == $output
        | select name id
        | if $direction == 'prev' {
            sort-by name --natural } else {
            sort-by name --natural --reverse })

    # id gets nulled to enable next on first ws: otherwise the script stops
    # directly and returns an empty next value
    let workspaces = ($workspaces
        | prepend { name: ($workspaces | last | get name) id: 0 })

    let next = ($workspaces 
        | take until { |workspace| $workspace.id == $active_workspace }
        | last)

    run-external --redirect-stderr 'hyprctl' dispatch workspace $"name:($next.name)"
}
