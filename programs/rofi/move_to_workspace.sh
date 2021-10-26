#!/bin/sh

OPTIONS=""

workspaces=($(swaymsg -t get_workspaces -r | jq -r -c '.[] | .name'))
for workspace in "${workspaces[@]}"; do
    OPTIONS="$OPTIONS$workspace\n"
done

if [ "$@" ]
then
    swaymsg move container to workspace $@ >/dev/null 2>&1
else
	echo -e $OPTIONS
fi
