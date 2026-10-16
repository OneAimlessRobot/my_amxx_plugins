#!/bin/bash
#rconcs() {
#CH=$(printf "\xff\xff\xff\xffchallenge rcon\n" | nc -u -w1 "$1" "$2" | cut -d" " -f3)
#
#printf "\xff\xff\xff\xffrcon $CH \"$3\" $4\0\0" | nc -u -w1 "$1" "$2"
#}
#rconcs() {
 # CH=$(printf "challenge rcon\n" | nc -u -w1 "$1" "$2" | cut -d" " -f3)
  #printf "rcon $CH \"$3\" $4" | nc -u -w1 "$1" "$2"
#}
rconcs() {
  CH=$(printf "\xff\xff\xff\xffchallenge rcon\n" \
    | socat - UDP:$1:$2 \
    | awk '{print $3}')

  printf '\xff\xff\xff\xffrcon %s "%s" %s\0\0' "$CH" "$3" "$4" \
    | socat - UDP:$1:$2 \
    | sed -r 's/\x1B\[[0-9;?]*[ -/]*[@-~]//g' \
    | sed 's/^\xff\xff\xff\xff.//' \
    | tr -cd '\11\12\15\40-\176' \
    | sed '/^$/d'
}

rconcs "$1" "$2" "$3" "$4"