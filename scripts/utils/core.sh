#!/usr/bin/env bash

set -eou pipefail

# ---------------------- #
#         Logger         #
# ---------------------- #
:: () {
	echo ":: $@"
}

log () {
	local COLOR="${1}"
	local CONTENT="$(echo $@ | cut -d' ' -f2-)"

	local BOLD=0
	local HEADER="==>"
	if [ "${COLOR}" = "1" ]; then
		BOLD=1
		HEADER="xxx"
		echo "  ${HEADER} ${CONTENT}" > /tmp/tangerine-err
	fi

	echo -e "   \e[1;3${COLOR}m${HEADER}\e[0m \e[${BOLD}m${CONTENT}\e[0m" 
} 

logcat () {
	cat "${1}" | sed "s/^/       /" >&2
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
#         Files          #
# ---------------------- #
list_files () {
	local DIR="${1}"
	local EXT="${2}"

	find "${DIR}" -name "${EXT}" -printf "%d %p\n" | LC_ALL=C sort -n | cut -d " " -f 2
}

