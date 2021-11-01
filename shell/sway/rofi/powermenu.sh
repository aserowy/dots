#!/bin/sh

OPTIONS="\tsuspend\n⏻\tshutdown\n\treboot\n\tlock\n\tlogout"

if [ "$@" ]
then
	case $@ in
        *shutdown)
            systemctl poweroff
            ;;
        *reboot)
            systemctl reboot
            ;;
        *suspend)
            systemctl suspend
            ;;
        *logout)
            swaymsg exit
            ;;
	esac
else
	echo -e $OPTIONS
fi
