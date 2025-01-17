#!/usr/bin/env nu

let current_names = (niri msg --json workspaces
    | from json
    | where name != null
    | get name)

let defaults = (["dots", "gaming", "work"]
    | where $it not-in $current_names
    | sort
    | uniq
    | str join "\n")

let selection = ($defaults | fuzzel --dmenu)

(niri msg action set-workspace-name $selection)
