#! /bin/bash

source_ext="sma"
bytecode_ext="amxx"

current_folder=$(cat .curr_dir_file)

output_folder=$current_folder"/plugins/"
scripting_folder=$current_folder"/scripting/"

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
