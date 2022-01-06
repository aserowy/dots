#!/bin/sh

if [ "$@" ]
then
    case "$@" in
        drun)
            rofi -config /etc/rofi/config.rasi -show drun
        ;;
        mark)
            rofi -config /etc/rofi/list.rasi -modi mark:/etc/rofi/focus_by_mark.sh -show mark
        ;;
        move)
            rofi -config /etc/rofi/list.rasi -modi move:/etc/rofi/move_to_workspace.sh -show move
        ;;
        power)
            rofi -config /etc/rofi/powermenu.rasi -modi power:/etc/rofi/powermenu.sh -show power
        ;;
        workspace)
            rofi -config /etc/rofi/list.rasi -modi workspace:/etc/rofi/focus_workspace.sh -show workspace
        ;;
    esac
    
fi
