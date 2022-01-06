#!/bin/sh

if [ -z "$WAYLAND_DISPLAY" ]
then
    workspaces=($(i3-msg -t get_workspaces | jq -r -c '.[] | .name'))
else
    workspaces=($(swaymsg -t get_workspaces -r | jq -r -c '.[] | .name'))
fi

OPTIONS="dots\ngaming\nwork\nsocial\n"

for workspace in "${workspaces[@]}"; do
    if [[ $OPTIONS != *$workspace* ]]
    then
        OPTIONS="$OPTIONS$workspace\n"
    fi
done

if [ "$@" ]
then
    if [ -z "$WAYLAND_DISPLAY" ]
    then
        i3-msg workspace $@ >/dev/null 2>&1
    else
        swaymsg workspace $@ >/dev/null 2>&1
    fi
else
    echo -e $OPTIONS
fi
