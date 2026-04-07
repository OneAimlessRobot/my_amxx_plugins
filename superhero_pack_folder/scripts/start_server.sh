#!/bin/bash

export STEAM_RUNTIME=0
unset STEAM_COMPAT_CLIENT_INSTALL_PATH
unset STEAM_COMPAT_DATA_PATH
#bash ./server.sh -nosteam -game cstrike +ip "192.168.0.100" +hostport "27015" +maxplayers "16" +exec "server.cfg" 2>&1 | grep -v "WebUI"
bash ./server.sh -console -nosteam -game cstrike +ip "192.168.0.100" +hostport "27015" +maxplayers "16" +exec "server.cfg"

stty sane

