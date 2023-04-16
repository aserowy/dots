#!/usr/bin/env nu

def main [action: string, program: string] {
    if $action == 'link' {
        if $program == 'wezterm' {
            link_wezterm
        }
    } else if $action == 'unlink' {
        if $program == 'wezterm' {
            unlink_wezterm
        }
    }
}

def link_wezterm [] {
    mv --force ~/.config/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua_unlinked
    run-external --redirect-stderr "ln" "-s" $"($env.PWD)/home/shell/headless/wezterm.lua" "~/.config/wezterm/wezterm.lua"
}

def unlink_wezterm [] {
    rm ~/.config/wezterm/wezterm.lua
    run-external --redirect-stderr "ln" "-s" "~/.config/wezterm/wezterm.lua" $"($env.PWD)/home/shell/headless/wezterm.lua" 
}

