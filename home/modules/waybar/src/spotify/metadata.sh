#!/bin/sh

status=$(playerctl -p spotify status)

if [[ -z $status ]] 
then
   # spotify is dead, we should die to.
   exit
fi

artist=$(playerctl -p spotify metadata xesam:artist)
title=$(playerctl -p spotify metadata xesam:title)
album=$(playerctl -p spotify metadata xesam:album)

if [[ $status == "Playing" ]]
then
   echo "{\"class\": \"playing\", \"text\": \"$artist - $title\", \"tooltip\": \"$artist - $title - $album\"}"
   exit
fi

if [[ $status == "Paused" ]]
then
   echo "{\"class\": \"paused\", \"text\": \"$artist - $title\", \"tooltip\": \"$artist - $title - $album\"}"
   exit
fi

