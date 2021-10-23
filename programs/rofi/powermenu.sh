#!/bin/sh

OPTIONS="⏻\tshutdown\n\treboot\n\tlock\n\tsuspend\n\tlogout"

option=`echo -e $OPTIONS | awk '{print $1}' | tr -d '\r\n\t'`
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
