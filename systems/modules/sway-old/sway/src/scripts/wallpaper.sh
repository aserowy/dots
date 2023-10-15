#!/bin/sh

while true; do
    PID=`pidof swaybg`

    swaybg --mode fill --image "$(find $HOME/onedrive/Wallpapers -type f | shuf -n 1)" &

    sleep 5
    kill $PID > /dev/null
    
    sleep 60m
done
