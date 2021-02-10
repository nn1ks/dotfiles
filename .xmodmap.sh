#!/bin/sh

set -x

while read line; do
    xmodmap -e "$line"
done < ~/.Xmodmap
