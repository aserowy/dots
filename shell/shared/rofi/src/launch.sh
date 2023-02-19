#!/bin/sh

if [ "$@" ]
then
    case "$@" in
        drun)
            rofi -config /etc/rofi/config.rasi -modi drun -show drun
        ;;
        move)
            rofi -config /etc/rofi/list.rasi -modi move:/etc/rofi/move_by_name.nu -show move
        ;;
        power)
            rofi -config /etc/rofi/powermenu.rasi -modi power:/etc/rofi/powermenu.sh -show power
        ;;
        workspace)
            rofi -config /etc/rofi/list.rasi -modi workspace:/etc/rofi/focus_by_name.nu -show workspace
        ;;
    esac
    
fi
