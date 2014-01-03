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

log()
{
# $1 -- verbosity niceness
# $2 -- message

	if [ "$VERBOSITY" -ge "$1" ]; then
		echo "$2" >&2
	fi
}

log 4 "PID: $$"

socat "TCP4-LISTEN:$PORT,fork" "EXEC:`pwd`/serve.sh"
