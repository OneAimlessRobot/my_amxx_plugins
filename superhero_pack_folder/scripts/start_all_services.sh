#!/bin/bash



directory=$(pwd)

tmp_session_names_file=".tmp_session_names_file"

term_exec_string=""

term_exec_string_case_wayland="wayst -e bash -c"

term_exec_string_case_X11="xterm -e bash -c"



if [ -z "${DISPLAY}"  ];
then
	term_exec_string="${term_exec_string_case_wayland}"
else
	term_exec_string="${term_exec_string_case_X11}"
fi

rm "${tmp_session_names_file}"

if [ -f "${tmp_session_names_file}"  ]
then
	chmod a+rwx "${tmp_session_names_file}"
fi

#first arg is session name
#second member is sleep time before next session
#third member is sleep time before next window cmd in session
#fourth member is whether or not we should write
#this session
#to the session names file

session_name_half_life_array=("half_life"
								"0.5"
								"3.5"
								"1"
								"pushd /mnt/REBORN/half_life_stuff/Half-Life ; bash launch*game*sh"
								"pushd /mnt/REBORN/half_life_stuff/Half-Life"
								"pushd /mnt/REBORN/half_life_stuff/Half-Life"
								"pushd /mnt/REBORN/half_life_stuff/Half-Life"
								"pushd /mnt/REBORN/half_life_stuff/Half-Life"
								"pushd /mnt/REBORN/half_life_stuff/Half-Life ; bash launch*disp*sh"
								"pushd /mnt/REBORN/half_life_stuff/Half-Life ; bash launch*prox*sh")

array_of_all_tmux_sessions=(
					session_name_half_life_array)

#array_of_all_tmux_sessions=(
#					session_name_ups_timer_daemon
#					session_name_http_server_array
#					session_name_remote_shell
#					session_name_emotionstreamer_array
#					session_name_mysql_array
#					session_name_lutris_array
#					session_name_agario_array
#					session_name_trackmania_array
#					session_name_ppsspp_relay_server)


print_cmd_arr(){
	local arr=("$@")
	for((i=0; i<${#arr[@]}; i++));
	do
		echo "Cmd numero $i = ${arr[$i]}"
	done
}

start_another_session_func_inner(){
	
	local arr=("$@")
	print_cmd_arr "${arr[@]}"
	echo "session ${arr[0]} starting!"
	tmux new-session -d -s "${arr[0]}"
	start_session_tabs_func "${arr[@]}"
	tmux attach -t "${arr[0]}"

}
start_session_tabs_func(){
	local arr=("$@")
	local slot_where_windows_start=4
	echo "here: |${#arr[@]}|"
	echo ${arr[@]}
	echo $slot_where_windows_start
	for((i=$slot_where_windows_start; i<${#arr[@]}; i++));
	do
		j=$(($i - $slot_where_windows_start + 1))
		echo "tmux new-window -t \"${arr[0]}\":\"$j\" \"bash -lc '${arr[$i]}; exec bash'\""
		tmux new-window -t "${arr[0]}":"$j" "bash -lc '${arr[$i]}; exec bash'"
		sleep $(echo "${arr[2]}" | bc)
	done


}
export sleep_time
export sleep_time_mult_attach_cmd_proc
export -f start_session_tabs_func
export -f print_cmd_arr
export -f start_another_session_func_inner



start_all(){
	pushd "${directory}"
	echo "${#array_of_all_tmux_sessions[@]}"

	for group in "${array_of_all_tmux_sessions[@]}"; do
		declare -n lst=$group
		echo "Sessao de nome $group tem ${#lst[@]} elementos"
		if [ ${lst[3]} -gt 0 ]
		then
			echo "${lst[0]}" >> "${tmp_session_names_file}"
			echo "writing session name \"${lst[0]}\""
			echo "Into session names file!"
		fi
		${term_exec_string}  'start_another_session_func_inner "$@"' "placeholder" "${lst[@]}"&
		sleep $(echo "${lst[1]}" | bc)
	done
}

start_all

