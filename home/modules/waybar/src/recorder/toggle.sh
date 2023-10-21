#!/bin/sh

if pgrep wf-recorder &> /dev/null
then
    pkill -SIGINT wf-recorder
else
    area=$(slurp -o)
    wf-recorder -g "$area" -f ~/videos/$(date -Is).mp4 &> /dev/null &
fi 

sleep .25

# send signal to update monitor 
pkill -RTMIN+8 waybar
