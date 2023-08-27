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

    # let next = ($workspaces 
    #     | each while { |workspace| if $workspace.focused != true { $workspace.name }}
    #     | last)

    let next_index = 0
    loop {
        if ($workspaces | length) >= ($next_index + 1) {
            break
        }

        let workspace = ($workspaces | get $next_index)
        if $workspace.focused == true {
            break
        }

        $next_index = $next_index + 1
    }

    let next = ($workspaces | get $next_index).name

    run-external --redirect-stderr 'swaymsg' workspace $next
}
