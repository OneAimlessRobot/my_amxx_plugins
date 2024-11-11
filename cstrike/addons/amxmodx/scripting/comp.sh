#!/bin/bash

if [ $# -eq 1 ];
then
echo $1
echo "../plugins/$1"

sudo ./amxxpc $1.sma -d3 -o"$1"
mv -f $1.amxx ../plugins
else
echo "Not enough arguments!"
fi

