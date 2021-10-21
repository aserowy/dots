#!/bin/bash
IFS=$'\n'

# check for env variable, if exists we are the
# forked shell, get the waiting string from the fifo
# and call fzf and sway from there.
prompt="Windows> "
if [[ -n $fifo ]]; then
    str=$(cat $fifo)
    rm -rf $fifo

    selection=$(printf $str | fzf --prompt="$prompt" --color)

    id=$(echo $selection | cut -d ":" -f1)
    if [[ -z $id ]]; then
        exit
    fi

    swaymsg [con_id="$id"] focus
    exit
fi

windows=($(swaymsg -t get_tree| jq -r 'recurse(.nodes[]?) | recurse(.floating_nodes[]?) | select(.type=="con"), select(.type=="floating_con") | select((.app_id != null) or .name != null) | {id, app_id, name} | .id, .app_id, .name'))

# build the selection string we will ultimate
# pipe to fzf, take note of largest string to set
# columns and number of lines to set lines for alacritty.
str=""
columns=0
lines=0
for ((i=0; i<"${#windows[@]}"; i=i+3,lines++)); do
    id="${windows[i]}"
    app_id="${windows[i+1]}"
    name="${windows[i+2]}"

    building_string="$id:"
    if [[ $app_id != "null" ]]; 
    then
        building_string="$building_string $app_id"
    fi
    if [[ $name != "null" ]];
    then
        building_string="$building_string : $name"
    fi
    if [[ ${#building_string} -gt $columns ]];
    then
        str_largest="$building_string"
        columns=${#building_string}
    fi
    str="$str$building_string\n" 
done

# add some padding to the terminal for 
# lines and columns, for columns make sure
# we take the prompt into the padding consideration
lines=$((lines+3))
columns=$((columns+"${#prompt}"+5))
if [[ columns -gt 100 ]];
then
    columns=100
fi

fifo=/tmp/sts-$(date +%s)
mkfifo $fifo
fifo=$fifo zsh -c "alacritty \
    -o window.dimensions.columns=$columns \
    -o window.dimensions.lines=$lines \
    -o font.size=16.0 \
    -o window.padding.x=20 \
    -o window.padding.y=20 \
    --title "fzf-switcher" \
    -e /home/louis/git/dotfiles/config/sway/scripts/sts"&
echo -n $str > $fifo
