#!/bin/bash

if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
	echo "Usage:
	$0 <dir containing images>"
	exit 1
fi

export SWWW_TRANSITION='fade'

INTERVAL=3600

while true; do
	find "$1" \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
			swww img "$img"
			sleep $INTERVAL
		done
done
