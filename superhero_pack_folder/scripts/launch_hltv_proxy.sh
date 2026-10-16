#!/bin/bash

export STEAM_RUNTIME=0
unset STEAM_COMPAT_CLIENT_INSTALL_PATH
unset STEAM_COMPAT_DATA_PATH

while [ true ]; do

	taskset -c 2 bash ./launch_hltv.sh  +connect 127.0.0.1:27010 -port "27007" +exec "cstrike/hltv_proxy.cfg"
	echo "HLTV Proxy Server crashed at '`date`' - Restarting"
	echo "HLTV Proxy Server crashed at '`date`' - Restarting" >> crash_timestamps_hltv_proxy.log
	sleep 5
done
