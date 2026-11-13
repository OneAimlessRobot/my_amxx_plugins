#!/bin/bash

sleep_time=0.5

directory=$(pwd)

tmp_session_file=".tmp_session_names_file"

num_of_procs=$(wc -l < "${tmp_session_file}")

echo "${num_of_procs}"



for the_session in $(cat "${tmp_session_file}")
do
	echo "Trying to kill session of name = $the_session ..."
	tmux kill-session -t "${the_session}"
	sleep "${sleep_time}"

done

cat /dev/null > "${tmp_session_file}"
