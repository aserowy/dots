#!/bin/sh
# TODO: test this ;D

OPTIONS=""

windows=($(swaymsg -t get_tree| jq -r 'recurse(.nodes[]?) | recurse(.floating_nodes[]?) | select(.type=="con"), select(.type=="floating_con") | select((.app_id != null) or .name != null) | {id, app_id, name} | .id, .app_id, .name'))
for ((i=0; i<"${#windows[@]}"; i=i+3)); do
    id="${windows[i]}"
    app_id="${windows[i+1]}"
    name="${windows[i+2]}"

    window="$id:"
    if [[ $app_id != "null" ]]; 
    then
        window="$window $app_id"
    fi
    if [[ $name != "null" ]];
    then
        window="$window $name"
    fi
    OPTIONS="$OPTIONS$window\n" 
done

if [ "$@" ]
then
    id=$(echo $@ | cut -d ":" -f1)
    if [[ -z $id ]]; then
        exit
    fi

    swaymsg [con_id="$id"] focus >/dev/null 2>&1
else
	echo -e $OPTIONS
fi

