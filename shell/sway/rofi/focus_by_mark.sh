#!/bin/sh

OPTIONS=""

marks=($(swaymsg -t get_marks | jq -r '.[]'))
for mark in "${marks[@]}"; do
    OPTIONS="$OPTIONS$mark\n"
done


if [ "$@" ]
then
    swaymsg "[con_mark=\b$@\b]" focus >/dev/null 2>&1
else
	echo -e $OPTIONS
fi
