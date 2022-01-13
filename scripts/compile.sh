#!/usr/bin/env bash

FENNEL="${1}"
SOURCES="${2}"

source $(dirname $0)/utils/core.sh

# --------------------- #
#         UTILS         #
# --------------------- #
FLAGS="--globals vim"
LOGFILE="$(mktemp)"

compile () {
	local SOURCE="${1}"
	local TARGET="${2}"

	${FENNEL} ${FLAGS} -c "${SOURCE}" > "${TARGET}" 2> "${LOGFILE}"
}

# --------------------- #
#         MAIN          #
# --------------------- #
:: INITILIZE COMPILING

for SOURCE in $SOURCES; do
	TARGET="$(get-target $SOURCE)"
	TARGETDIR="$(dirname $TARGET)"

	[ ! -d $TARGETDIR ] && mkdir -p $TARGETDIR

	if compile $SOURCE $TARGET; then
		log 2 $SOURCE
	else
		log 1 $SOURCE
		logcat $LOGFILE
		exit 1
	fi
done

:: DONE
