#!/bin/bash

export STEAM_RUNTIME=0
unset STEAM_COMPAT_CLIENT_INSTALL_PATH
unset STEAM_COMPAT_DATA_PATH

while [ true ]; do

	taskset -c 1 bash ./launch_hltv.sh  +connect 127.0.0.1:27015 -port "27010" +exec "cstrike/hltv_dispatcher.cfg"
	echo "HLTV Dispatcher Server crashed at '`date`' - Restarting"
	echo "HLTV Dispatcher Server crashed at '`date`' - Restarting" >> crash_timestamps_hltv_dispatcher.log
	sleep 5
done
