#!/bin/bash

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_PATH"

export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"

if [ ! -e "$HOME/.steam/sdk32/steamclient.so" ]; then
	if [ ! -e "./steamclient.so" ]; then
		echo "ERROR: steamclient.so missing"
		exit 1
	fi
	mkdir -p "$HOME/.steam/sdk32"
	ln -s "$SCRIPT_PATH/steamclient.so" "$HOME/.steam/sdk32/steamclient.so"
fi

while [ true ]; do
	./hlds_linux -appid 10 -game cstrike -port 27015 -pingboost 2 -noipx -nojoy -console -num_edicts 3072 -zone 8192 -heapsize 131072 +maxplayers 32 +map de_dust +ip 0.0.0.0 +sv_lan 0 +sys_ticrate 10000 +fps_max 10000 +fps_override 1
	echo "Server crashed at '`date`' - Restarting"
	sleep 5
done
