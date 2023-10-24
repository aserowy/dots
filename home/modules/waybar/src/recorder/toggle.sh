#!/bin/sh

if pgrep wf-recorder &> /dev/null
then
    pkill -SIGINT wf-recorder

    while [ pgrep wf-recorder &> /dev/null ]
    do
        sleep .1
    done
else
    area=$(slurp -o)
    wf-recorder -g "$area" -f ~/videos/$(date -Is).mp4 &> /dev/null &

    while [ ! pgrep wf-recorder &> /dev/null ]
    do
        sleep .1
    done
fi 
