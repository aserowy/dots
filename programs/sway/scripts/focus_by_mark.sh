#!/bin/bash
IFS=$'\n'

# check for env variable, if exists we are the
# forked shell, get the waiting string from the fifo
# and call fzf and sway from there.
prompt="Marks> "
if [[ -n $SMS_FIFO ]]; then
    # we are in the forked shell, read from
    # the provided FIFO and obtain the marks str
    # and pipe to fzf for selection.
    str=$(cat $SMS_FIFO)
    rm -rf $SMS_FIFO
    selection=$(printf $str | fzf --prompt="$prompt" --color)
    if [[ -z $selection ]]; then
        exit
    fi
    swaymsg "[con_mark=\b$selection\b]" focus
    exit
fi

# build the selection string we will ultimate
# pipe to fzf, take note of largest string to set
# columns and number of lines to set lines for alacritty.
columns=1
lines=0
str=""
marks=($(swaymsg -t get_marks | jq -r '.[]'))
for mark in "${marks[@]}"; do
    if [[ ${#mark} -gt $columns ]];
    then
        columns=${#mark}
    fi
    lines=$((lines+1))
    str="$str$mark\n"
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
fifo=/tmp/sts-$(date +%s)
mkfifo $fifo
SMS_FIFO=$fifo zsh -c "alacritty \
    -o window.dimensions.columns=$columns \
    -o window.dimensions.lines=$lines \
    -o font.size=16.0 \
    -o window.padding.x=20 \
    -o window.padding.y=20 \
    --title "fzf-switcher" \
    -e $HOME/.config/sway/scripts/focus_by_mark.sh"&
echo -n $str > $fifo
