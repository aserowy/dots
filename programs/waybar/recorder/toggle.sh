#!/bin/sh

if pgrep wf-recorder &> /dev/null
then
    pkill -SIGINT wf-recorder && notify-send ' screen cap ended'
    sleep .1
else
    wf-recorder -o $(swaymsg -r -t get_outputs  | jq -r '.[] | select(.focused == true).name') -f $HOME/videos/$(date -Is).mp4 &> /dev/null &
    notify-send ' screen cap started'
    sleep .1
fi 

# send signal to update monitor 
pkill -RTMIN+8 waybar
