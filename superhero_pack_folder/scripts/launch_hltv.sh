#!/bin/bash

# figure out the absolute path to the script being run a bit
# non-obvious, the ${0%/*} pulls the path out of $0, cd's into the
# specified directory, then uses $PWD to figure out where that
# directory lives - and all this in a subshell, so we don't affect
# $PWD
GAMEROOT=$(cd "${0%/*}" && echo "${PWD}")

export LD_LIBRARY_PATH=${GAMEROOT}:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH
ulimit -c unlimited
ulimit -n 2048

# and launch the game
cd "$GAMEROOT"

STATUS=42
#DEBUGGER="gdb"
while [ $STATUS -eq 42 ]; do
	${DEBUGGER} ${GAMEROOT}/hltv ${@}
	STATUS=$?
done
exit $STATUS
