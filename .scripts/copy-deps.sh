#!/usr/bin/env bash

DEPS="${1}"
TARGETDIR="${2}"

source $(dirname $0)/utils.sh

# --------------------- #
#         MAIN          #
# --------------------- #
[ ! -d $TARGETDIR ] && mkdir -p $TARGETDIR

:: COPYING DEPS
for DEP in $DEPS; do
	cp -f $DEP $TARGETDIR
	log 2 $DEP
done
:: DONE
