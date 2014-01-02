#!/bin/bash

# A minimal working bash webserver.

# Dependencies:
# mktemp	-- Creating temporary directory for named pipes
# dos2unix	-- Converting line endings (possible with sed, but 
#		   unnecessarily resource intensive) 

###### Modifiable parameters ######
PORT=8080
VERBOSITY=5
###################################


listen()
{
	COUNT="0"
	until mkdir "$TEMPDIR/.lockdir$COUNT" 2> /dev/null ; do
		let COUNT+=1
	done
	mkfifo "$TEMPDIR/.lockdir$COUNT/fifo"
	local FIFO="$TEMPDIR/.lockdir$COUNT/fifo"
	serve < "$FIFO" | nc -lvp "$PORT" -q 0 > "$FIFO" 2> >(wait_for_connect)
	rm -rf "$TEMPDIR/.lockdir$COUNT"
}

log()
{
# $1 -- verbosity niceness
# $2 -- message

	if [ "$VERBOSITY" -ge "$1" ]; then
		echo "$2" >&2
	fi
}

clean_up()
{
	rm -rf "$TEMPDIR"
	log 1 "Removed temporary directory: $TEMPDIR"
	exit 0
}

TEMPDIR=`mktemp -d`
PID="$$"
log 4 "PID: $$"
trap clean_up SIGHUP SIGINT SIGTERM
# trap "return 0" SIGUSR1
log 1 "New temporary directory: $TEMPDIR"



socat "TCP4-LISTEN:$PORT,fork" "EXEC:`pwd`/serve.sh"
# while true; do
# 	log 3 "Listening on port $PORT"
# 	listen &
# 	wait_for_port
# done

clean_up
