#! /bin/bash

source_ext="sma"
bytecode_ext="amxx"


output_folder="/mnt/FASTstorage/GamesFAST/Half-Life/cstrike/addons/amxmodx/plugins/"
scripting_folder="/mnt/FASTstorage/GamesFAST/Half-Life/cstrike/addons/amxmodx/scripting/"

compiler_name="amxxpc"
compiler_path="${scripting_folder}${compiler_name}"

function get_isolated_plugin_name (){

	echo "${1}.${bytecode_ext}"

}
function get_output_plugin_name (){
	
	echo "${output_folder}$(get_isolated_plugin_name "$1")"
}

plugin_name="$1"
output_plugin_name=$(get_output_plugin_name "$plugin_name")

"${compiler_path}" "$plugin_name.${source_ext}" -o"$output_plugin_name" -v
