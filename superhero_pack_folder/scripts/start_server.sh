#!/bin/bash

export STEAM_RUNTIME=0
unset STEAM_COMPAT_CLIENT_INSTALL_PATH
unset STEAM_COMPAT_DATA_PATH
#bash ./server.sh -dev -console -game cstrike +ip "192.168.0.100" +hostport "27015" +maxplayers "16"2>&1 | grep -v "WebUI"
#bash ./server.sh -dev -console -game cstrike +ip localhost +hostport "27015" +maxplayers "16"
# -appid 10 -game cstrike -port 27015 -pingboost 2 -noipx -nojoy -console -num_edicts 3072 -zone 8192 -heapsize 131072

while [ true ]; do
	bash ./server.sh -dew -appid 10 -pingboost 2 -noipx -nojoy -console -num_edicts 3072 -zone 8192 -heapsize 131072 -game cstrike +ip "192.168.0.100" +hostport "27015" +maxplayers "16"
	echo "Server crashed at '`date`' - Restarting"
	echo "Server crashed at '`date`' - Restarting" >> crash_timestamps.log
	sleep 5
done
