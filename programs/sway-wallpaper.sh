#!/bin/sh

while true
do
      swaymsg output "*" bg "$(find ~/onedrive/Wallpapers -type f | shuf -n 1)" fill > /dev/null

      sleep 60m
done
