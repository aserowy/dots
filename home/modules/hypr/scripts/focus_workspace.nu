#!/usr/bin/env nu

def main [direction: string] {
    let specials = [special]

    let active_workspace = (hyprctl activeworkspace -j
        | from json)

    let workspaces = (hyprctl workspaces -j
        | from json
        | where monitor == $active_workspace.monitor
        | select name id
        | filter {|wrkspc| ($specials | all {|| $in != $wrkspc.name })}
        | if $direction == 'prev' {
            sort-by name --natural } else {
            sort-by name --natural --reverse })

    # id gets nulled to enable next on first ws: otherwise the script stops
    # directly and returns an empty next value
    let workspaces = ($workspaces
        | prepend { name: ($workspaces | last | get name) id: 0 })

    let next = ($workspaces
        | take until { |workspace| $workspace.id == $active_workspace.id }
        | last)

    (hyprctl dispatch workspace $"name:($next.name)" | ignore)
}
