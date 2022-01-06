#!/usr/bin/env bash

# ---------------------- #
#         Logger         #
# ---------------------- #
:: () {
	echo ":: $@"
}

log () {
	COLOR="${1}"
	CONTENT="$(echo $@ | cut -d' ' -f2-)"

	echo -e "  \e[1;3${COLOR}m ==>\e[0m $CONTENT"
} 

logcat () {
	cat "${1}" | sed "s/^/       /"
}

# ---------------------- #
#         Parser         #
# ---------------------- #
get-target () {
	echo "${1}" | sed "s/fnl/lua/g"
}

shortname () {
	echo ${1} | sed "s:fnl/::"
}

# ---------------------- #
#         Counter        #
# ---------------------- #
count () {
	FILE="${1}"
	REGEX="${2}"

	grep -c "$REGEX" < "$FILE"
}

lines () {
	wc -l < ${1}
}

