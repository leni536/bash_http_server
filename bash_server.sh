#!/bin/bash

# A minimal working bash webserver.

# Dependencies:
# dos2unix	-- Converting line endings (possible with sed, but 
#		   unnecessarily resource intensive) 
# socat		-- For listening on port and forking serve.sh for each 
#		   connection

###### Modifiable parameters ######
PORT=8080
export VERBOSITY=5
export RATELIMIT=0
###################################

log()
{
# $1 -- verbosity niceness
# $2 -- message

	if [ "$VERBOSITY" -ge "$1" ]; then
		echo "$2" >&2
	fi
}

log 4 "PID: $$"
log 2 "Listening on port $PORT"

socat "TCP4-LISTEN:$PORT,fork" "EXEC:$PWD/serve.sh"
