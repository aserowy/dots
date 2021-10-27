#!/bin/sh

WORKSPACE=""

output=$(swaymsg -t get_outputs -r | jq -r -c 'map(select(.focused == true)) | .[] | .name')
current=$(swaymsg -t get_outputs -r | jq -r -c 'map(select(.focused == true)) | .[] | .current_workspace')

current_index=0
workspaces=($(swaymsg -t get_workspaces -r | jq -r -c 'map(select(.output ==  "'${output}'")) | sort_by(.name) | .[] | .name'))
for workspace in "${workspaces[@]}"; do
    if [ "$workspace" == "$current" ]; then
        break 
    fi
    current_index=$(($current_index+1))
done

workspaces_length=${#workspaces[@]}
if [ $current_index -gt $workspaces_length ]; then
    return 1
fi

navigate() {
    next=$(($2+$3))

    if [ $next -lt 0 ]; then
        return $(($1-1))
    elif [ $next -ge $1 ]; then
        return 0
    else
        return $next
    fi
}

case "$@" in
    prev)
        navigate $workspaces_length $current_index -1
        WORKSPACE=${workspaces[$?]}
    ;;
    next)
        navigate $workspaces_length $current_index 1
        WORKSPACE=${workspaces[$?]}
    ;;
esac

echo $WORKSPACE

if [ "$WORKSPACE" != "" ]; then
    swaymsg workspace $WORKSPACE >/dev/null 2>&1
fi
