#!/bin/sh

# we are a clock for the other
# spotify elements.
# 
# waybar will run this on an interval
# and external processes can trigger this 
# with pkill -RTMIN+4 waybar
sleep .1
pkill -RTMIN+5 waybar
