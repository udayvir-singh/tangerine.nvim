#!/usr/bin/env bash

SOURCE_DIR="${1}"
TARGET_DIR="${2}"

source $(dirname $0)/utils/core.sh

# --------------------- #
#         MAIN          #
# --------------------- #
[ ! -d "${TARGET_DIR}" ] && mkdir -p "${TARGET_DIR}"

LOGFILE="$(mktemp)"

:: LINKING DEPS
for SOURCE in "${SOURCE_DIR}"/*; do
	if ln -srf "${SOURCE}" "${TARGET_DIR}" 2> "${LOGFILE}"; then
		log 2 "${SOURCE}"
	else
		log 1 "${SOURCE}"
		logcat "${LOGFILE}"
		exit 1
	fi
done
:: DONE
