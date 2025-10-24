#! /bin/bash
num_of_divs=5

is_even=0

plugin_arr=()
splice_data=()
div_data=()

source_ext="sma"
bytecode_ext="amxx"

current_folder=$(cat .curr_dir_file)

output_folder=$current_folder"/plugins/"
scripting_folder=$current_folder"/scripting/"

search_command=$(ls *.${source_ext})

compiler_name="amxxpc"
compiler_path="${scripting_folder}${compiler_name}"



function get_non_ext_source_name (){

    basename "$1" .${source_ext}
	
}
function get_isolated_plugin_name (){

	echo "${1}.${bytecode_ext}"

}
function get_output_plugin_name (){
	
	echo "${output_folder}$(get_isolated_plugin_name "$1")"
}


function compile_plugin(){
	
	plugin_name="$1"
    output_plugin_name=$(get_output_plugin_name "$plugin_name")

    # Fixed command (added -o for output file)
    "${compiler_path}" "$plugin_name.${source_ext}" -o"$output_plugin_name" -v
}

# for i in search_command;
# do
# proto_plugin_name="$(basename $i '.sma')"
# echo "${proto_plugin_name}"
# isolated_plugin_name="${proto_plugin_name}.amxx"
# echo "${isolated_plugin_name}"
# plugin_name="F:/SteamFAST/steamapps/common/Half-Life/cstrike/addons/amxmodx/plugins/${isolated_plugin_name}"
# echo "${plugin_name}"
# F:/SteamFAST/steamapps/common/Half-Life/cstrike/addons/amxmodx/scripting/amxxpc.exe $i -o${plugin_name}
# done

function print_all_plugins(){
	counter=0
	for i in *.${source_ext};
	do
		proto_plugin_name=$(get_non_ext_source_name $i)
		echo "${proto_plugin_name}"
		isolated_plugin_name=$(get_isolated_plugin_name $proto_plugin_name)
		echo "${isolated_plugin_name}"
		plugin_name=$(get_output_plugin_name $proto_plugin_name)
		echo "Plugin number $((counter+1)): ${plugin_name}"
        ((counter++))
	done
}

function fill_plugin_arr(){

	plugin_arr=(*.${source_ext})
}


function splitting_blade(){
	num_of_plugins=${#plugin_arr[@]}
	
	plugins_per_whole_part=$(( num_of_plugins / num_of_divs ))

	plugins_per_last_part=$(( num_of_plugins % plugins_per_whole_part  ))
	
	splice_data[0]=$num_of_plugins
	splice_data[1]=$plugins_per_whole_part
	splice_data[2]=$plugins_per_last_part
}

function get_even(){
	
	if(( $((splice_data[2])) > 0 ))
	then
		is_even=$((0))
	else
		is_even=$((1))
	fi
	
}
function make_div_data(){
	
    for ((i=0; i<num_of_divs; i++)); do
        div_data[$i]=$(( i * splice_data[1] + 1 ))
    done
	
	
    # If there's a remainder (uneven division), adjust the last division
    if (( splice_data[2] > 0 )); then
        div_data[$num_of_divs]=$(( num_of_plugins - splice_data[2] + 1 ))
    fi
}

function print_divs(){
for ((i=1; i<=num_of_divs; i++));
	do

		   echo "Division $i starts at plugin index ${div_data[$i]}"

			
	done
}


function compile_plugins_in_range(){
	
	init=$1
	end=$2
	echo "Compiling plugins from index $init to $((end-1))"

	for ((i=init; i<=end; i++)); do
        compile_plugin "$(get_non_ext_source_name "${plugin_arr[i]}")"
	done

	
}
fill_plugin_arr
splitting_blade
echo "Plugins total: $((splice_data[0]))"
echo "Plugins per whole part: $((splice_data[1]))"
echo "Plugins per last part: $((splice_data[2]))"
make_div_data
print_divs

for ((i=1; i<=num_of_divs; i++)); do
	((compile_plugins_in_range "${div_data[$((i-1))]}" "${div_data[i]}") > "output$i.txt")&
done
wait
