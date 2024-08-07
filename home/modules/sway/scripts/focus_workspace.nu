#!/usr/bin/env nu

def main [direction: string] {

    let output = (swaymsg -t get_outputs
        | from json
        | where focused == true
        | get name
        | first)

    let workspaces = (swaymsg -t get_workspaces -r
        | from json
        | where output == $output
        | select name focused
        | if $direction == 'prev' {
            sort-by name --natural } else {
            sort-by name --natural --reverse })

    let workspaces = ($workspaces
        | prepend { name: ($workspaces | last | get name) focused: false })

    let next = ($workspaces
        | take until { |workspace| $workspace.focused == true }
        | last)

    (swaymsg workspace $next.name)
}
