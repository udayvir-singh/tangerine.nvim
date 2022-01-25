#!/usr/bin/env bash

FENNEL_BIN="${1}"
SOURCE_DIR="${2}"

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

SOURCES="$(find "${SOURCE_DIR}" -name "*.fnl")"

for SOURCE in ${SOURCES}; do
	TARGET="$(get-target "${SOURCE}")"
	TARGET_DIR="$(dirname "${TARGET}")"

	[ ! -d "${TARGET_DIR}" ] && mkdir -p "${TARGET_DIR}"

	if compile "${SOURCE}" "${TARGET}"; then
		log 2 "${SOURCE}" 
	else
		log 1 "${SOURCE}" 
		logcat "${LOGFILE}"
		exit 1
	fi
done

:: DONE
