#!/bin/bash

RATELIMIT="0"
VERBOSITY="5"

serve_HEAD_GET()
{
	local path=`echo "$1" | sed -e 's/^\([^\?]*\)\?/\1/'`

	if [[ ! "$path" =~ ^/([-A-Za-z0-9_][-A-Za-z0-9_\.]*/)*([-A-Za-z0-9_][-A-Za-z0-9_\.]*)?$ ]]
       	then
		log 2 "404: Path is not in desired format"
		log 3 "> $path"
		echo -e "HTTP/1.1 404 Not Found\r\n\r"
		test "$2" == "GET" && cat .notfound.html
		return 1
	fi
	path=".$path"
	while [ -d "$path" ]; do
		path="`echo "$path" | sed 's/\/?$//'`index.html"
	done
	if [ -f "$path" -a -r "$path" ]; then
		echo -e "HTTP/1.1 200 OK\r"
		log 4 "200: OK"
		log 4 "> $path"
		cat .header | unix2dos 
		echo -e "Date: `date -uR | sed -e 's/\+0000/GMT/'`"
		echo -e "Content-Type:`file -i "$path" | \
		       	sed -e 's/^[^:]*://'`\r"
		echo -e "Content-Length: `wc -c < "$path"`\r"
		echo -e "\r"
		if [ "$RATELIMIT" != "0" ]; then
			test "$2" == "GET" && cat -- "$path" | pv -q -L "$RATELIMIT"
		else
			test "$2" == "GET" && cat -- "$path"
		fi
	else
		log 2 "404: File not found or not readable"
		log 3 "> $path"
	       	echo -e "HTTP/1.1 404 Not Found\r\n\r"
		test "$2" == "GET" && cat .notfound.html
		return 2
	fi
}

log()
{
# $1 -- verbosity niceness
# $2 -- message

	if [ "$VERBOSITY" -ge "$1" ]; then
		echo "$2" >&2
	fi
}

if read line; then
	line=`echo $line | dos2unix`
	set not $line; shift
	method="$1"
	path="$2"
	protocol="$3"
	if [ "$protocol" != "HTTP/1.1" ]; then
		echo -e "HTTP/1.1 400 Bad Request\r\n\r" 
		log 2 "400: Bad protocol"
		log 3 "> $line"
		return 2
	fi
	case "$method" in
		"GET" ) serve_HEAD_GET "$path" GET ;;
		"HEAD") serve_HEAD_GET "$path" HEAD ;;
		*) echo -e "HTTP/1.1 405 Method Not Allowed\r"
		   echo -e "Allow: GET, HEAD\r\n\r"
		   log 2 "405: Bad method"
		   log 3 "> $line"
		   return 3;;
	esac
else
	echo -e "HTTP/1.1 400 Bad Request\r\n\r" 
	log 2 "400: Empty request"
	return 1
fi
