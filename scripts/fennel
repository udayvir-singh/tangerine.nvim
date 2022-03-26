#!/usr/bin/env bash

set -eou pipefail

FENNEL_BIN="${1?required arg FENNEL BINARY}"
SOURCE_DIR="${2?required arg SOURCE DIR}"

source $(dirname $0)/utils/core.sh

# --------------------- #
#         UTILS         #
# --------------------- #
FLAGS="--globals vim"
LOGFILE="$(mktemp)"

compile () {
	local SOURCE="${1}"
	local TARGET="${2}"

	"${FENNEL_BIN}" ${FLAGS} -c "${SOURCE}" > "${TARGET}" 2> "${LOGFILE}"
}

# --------------------- #
#         MAIN          #
# --------------------- #
:: INITILIZE COMPILING

SOURCES="$(list_files "${SOURCE_DIR}" "*.fnl")"

for SOURCE in ${SOURCES}; do
	     TITLE="${SOURCE#fnl/}"
	    TARGET="${SOURCE//fnl/lua}"
	TARGET_DIR="${TARGET%/*}"

	[ ! -d "${TARGET_DIR}" ] && mkdir -p "${TARGET_DIR}"

	if compile "${SOURCE}" "${TARGET}"; then
		log 2 "${TITLE}" 
	else
		log 1 "${TITLE}" >&2
		logcat "${LOGFILE}"
		exit 1
	fi
done

:: DONE
