#!/usr/bin/env nu

def main [action: string = ''] {
    if $action == '' {
        let action_output = (niri msg action --help
            | lines
            | skip until {|l| ($l | str starts-with 'Actions')}
            | skip 1
            | take until {|l| ($l | is-empty)})

        let actions = ($action_output
            | enumerate
            | where { |i| $i.index mod 2 == 0 }
            | get item)

        let descriptions = ($action_output
            | enumerate
            | where { |i| $i.index mod 2 == 1 }
            | get item)

        let action_table = ($actions
            | zip $descriptions
            | each { |pair|
                let action = ($pair.0 | str trim)
                let description = ($pair.1 | str trim)

                { action: $action description: $description }
            })

        ($action_table | get action | str join "\n")
    } else {
        (niri msg action $action)
    }
}
