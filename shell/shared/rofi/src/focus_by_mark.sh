#!/bin/sh

if [ -z "$WAYLAND_DISPLAY" ]
then
    marks=($(i3-msg -t get_marks | jq -r '.[]'))
else
    marks=($(swaymsg -t get_marks | jq -r '.[]'))
fi

OPTIONS=""

for mark in "${marks[@]}"; do
    OPTIONS="$OPTIONS$mark\n"
done


if [ "$@" ]
then
    if [ -z "$WAYLAND_DISPLAY" ]
    then
        i3-msg "[con_mark=\b$@\b]" focus >/dev/null 2>&1
    else
        swaymsg "[con_mark=\b$@\b]" focus >/dev/null 2>&1
    fi
else
	echo -e $OPTIONS
fi
