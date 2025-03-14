#!/bin/bash

for i in $(ls *.sma);
do
proto_plugin_name="$(basename $i '.sma')"
echo "${proto_plugin_name}"
isolated_plugin_name="${proto_plugin_name}.amxx"
echo "${isolated_plugin_name}"
plugin_name="F:/SteamFAST/steamapps/common/Half-Life/cstrike/addons/amxmodx/plugins/${isolated_plugin_name}"
echo "${plugin_name}"
F:/SteamFAST/steamapps/common/Half-Life/cstrike/addons/amxmodx/scripting/amxxpc.exe $i -o${plugin_name}
done
