#!/usr/bin/env bash

DEPS="${1}"
TARGETDIR="${2}"

source $(dirname $0)/utils/core.sh

# --------------------- #
#         MAIN          #
# --------------------- #
[ ! -d $TARGETDIR ] && mkdir -p $TARGETDIR

:: LINKING DEPS
for DEP in $DEPS; do
	ln -srf $DEP $TARGETDIR
	log 2 $DEP
done
:: DONE
