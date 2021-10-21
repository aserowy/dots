#!/bin/bash
IFS=$'\n'

# check for env variable, if exists we are the
# forked shell, get the waiting string from the fifo
# and call fzf and sway from there.
prompt="Workspace> "
if [[ -n $SWS_FIFO ]]; then
    str=$(cat $SWS_FIFO)
    # rm the fifo, we are done with it
    rm -rf $SWS_FIFO

    selection=$(printf $str | fzf --prompt="$prompt" --color)
    if [[ -z $selection ]]; then
        exit
    fi

    swaymsg workspace $selection

    exit
fi

# build the selection string we will ultimate
# pipe to fzf, take note of largest string to set
# columns and number of lines to set lines for alacritty.
columns=0
lines=0
str=""
workspaces=($(swaymsg -t get_workspaces -r | jq -r -c '.[] | .name'))
for workspace in "${workspaces[@]}"; do
    if [[ ${#workspace} -gt $columns ]];
    then
        columns=${#workspace}
    fi
    lines=$((lines+1))
    str="$str$workspace\n"
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

# create fifo and launch a terminal with the title "fzf-switcher"
# run the script in the new terminal which will see the env vars
# and execute the first if block in this script.
fifo=/tmp/sws-$(date +%s)
mkfifo $fifo
SWS_FIFO=$fifo zsh -c "alacritty \
    -o window.dimensions.columns=$columns \
    -o window.dimensions.lines=$lines \
    -o font.size=16.0 \
    -o window.padding.x=20 \
    -o window.padding.y=20 \
    --title "fzf-switcher" \
    -e /home/louis/git/dotfiles/config/sway/scripts/sws"&
echo -n $str > $fifo
