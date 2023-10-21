#!/bin/sh

if pgrep wf-recorder &> /dev/null
then
    pkill -SIGINT wf-recorder
    sleep .1
else
    wf-recorder -g "$(slurp -o)" -f ~/videos/$(date -Is).mp4 &> /dev/null &
    sleep .1
fi 

# send signal to update monitor 
pkill -RTMIN+8 waybar
