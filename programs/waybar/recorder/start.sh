#!/bin/sh

# TODO: script to toggle recording

wf-recorder -o $(swaymsg -r -t get_outputs  | jq -r '.[] | select(.focused == true).name') -f $HOME/videos/$(date -Is).mp4 &> /dev/null &
notify-send ' screen cap started'
sleep .1

# send signal to update monitor 
pkill -RTMIN+8 waybar
