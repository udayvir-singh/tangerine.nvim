#!/usr/bin/env bash

set -eou pipefail

# --------------------- #
#       VARIABLES       #
# --------------------- #
      PIPE="│"
 PIPE_LEFT="├"
PIPE_RIGHT="┤"

     DASH="─"
  DASH_UP="┴"
DASH_DOWN="┬"

   UP_LEFT="┌"
  UP_RIGHT="┐"
 DOWN_LEFT="└"
DOWN_RIGHT="┘"

CROSS="┼"

PRIMARY_SIZE=30
  BLOCK_SIZE=10

# --------------------- #
#         UTILS         #
# --------------------- #
ENDL () {
	printf "\n"
}

DRAW_NTIMES () {
	printf -- "${2-}%.0s" `seq ${1-}`
}

DRAW_DASHES () {
	DRAW_NTIMES $1 $DASH
}

DRAW_SECT () {
	printf %-${1-}s " ""${2-}"
	printf "│"
}

DRAW_PRIMARY () {
	printf "$PIPE"
	DRAW_SECT $PRIMARY_SIZE "$1"
}

DRAW_BLOCK () {
	DRAW_SECT $BLOCK_SIZE "$1"
}

# --------------------- #
#         MAIN          #
# --------------------- #
DRAW_LINE () { 
	START="$1"
	END="$2"
	SEPARATOR="$3"
	NBLOCKS="$4"
	BLOCK="${SEPARATOR}""$(DRAW_DASHES $BLOCK_SIZE)"
	
	printf $START
	DRAW_DASHES $PRIMARY_SIZE # area for primary columns
	DRAW_NTIMES $NBLOCKS $BLOCK # draw blocks
	printf $END
	ENDL
}

DRAW_HEADER () { 
	PRIMARY="${1-}"
	shift 1
	NO_BLOCKS="${#@}"

	DRAW_LINE $UP_LEFT $UP_RIGHT $DASH_DOWN $NO_BLOCKS
	DRAW_PRIMARY $PRIMARY
	while [[ "${1-}" ]]; do
		BLOCK="${1-}"
		DRAW_BLOCK "$BLOCK"
		shift 1
	done; ENDL
	DRAW_LINE $PIPE_LEFT $PIPE_RIGHT $CROSS $NO_BLOCKS
}

DRAW_ROW () {
	PRIMARY="$1"
	shift 1

	DRAW_PRIMARY $PRIMARY
	while [[ "${1-}" ]]; do
		BLOCK="${1-}"
		DRAW_BLOCK "$BLOCK"
		shift 1
	done; ENDL
}

DRAW_FOOTER () {
	PRIMARY="${1-}"
	shift 1
	NO_BLOCKS="${#@}"
	
	DRAW_LINE $PIPE_LEFT $PIPE_RIGHT $CROSS $NO_BLOCKS
	DRAW_PRIMARY $PRIMARY
	while [[ "${1-}" ]]; do
		BLOCK="${1-}"
		DRAW_BLOCK "$BLOCK"
		shift 1
	done; ENDL
	DRAW_LINE $DOWN_LEFT $DOWN_RIGHT $DASH_UP $NO_BLOCKS
}


## example
_example_table () {
	DRAW_HEADER "FILE"          "Code" "Comments" "Docs" " TOTAL"
	DRAW_ROW    "tangerine.fnl" "233"  "12"       "23"   "268"
	DRAW_ROW    "tangerine.fnl" "233"  "12"       "23"   "268"
	DRAW_ROW    "tangerine.fnl" "233"  "12"       "23"   "268"
	DRAW_ROW    "tangerine.fnl" "233"  "12"       "23"   "268"
	DRAW_FOOTER "TOTAL:"        "932"  "48"       "92"   "1072"
}
