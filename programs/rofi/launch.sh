#!/bin/sh

if [ "$@" ]
then
    case "$@" in
        drun)
            rofi -show drun
        ;;
        mark)
            rofi -config ~/.config/rofi/list.rasi -modi mark:$HOME/.config/rofi/focus_by_mark.sh -show mark
        ;;
        power)
            rofi -config ~/.config/rofi/powermenu.rasi -modi power:~/.config/rofi/powermenu.sh -show power
        ;;
        program)
            rofi -config ~/.config/rofi/list.rasi -modi program:$HOME/.config/rofi/focus_program.sh -show program
        ;;
        workspace)
            rofi -config ~/.config/rofi/list.rasi -modi workspace:$HOME/.config/rofi/focus_workspace.sh -show workspace
        ;;
    esac
    
fi
