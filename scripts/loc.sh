#!/usr/bin/env bash

SOURCE_DIR="${1}"

source $(dirname $0)/utils/core.sh
source $(dirname $0)/utils/table.sh

# --------------------- #
#         VARS          #
# --------------------- #
DOCS_REGEX="^ *\""
BLANK_REGEX="^$"
COMMENT_REGEX="^;"

COLUMNS="FILE Code Comments Docs Blanks SUBTOTAL"
TCODE=0; TCOMMENTS=0; TDOCS=0; TBLANKS=0; TOTAL=0

# --------------------- #
#         MAIN          #
# --------------------- #
DRAW_HEADER ${COLUMNS}

SOURCES="$(find "${SOURCE_DIR}" -name "*.fnl")"

for SOURCE in ${SOURCES}; do 
	    DOCS=$(count "$SOURCE" "$DOCS_REGEX")
	  BLANKS=$(count "$SOURCE" "$BLANK_REGEX")
	COMMENTS=$(count "$SOURCE" "$COMMENT_REGEX")
	SUBTOTAL=$(lines "$SOURCE")
	    CODE=$(( SUBTOTAL - ( DOCS + BLANKS + COMMENTS ) ))

	DRAW_ROW $(shortname $SOURCE) $CODE $COMMENTS $DOCS $BLANKS $SUBTOTAL

	let 'TDOCS+=DOCS'
	let 'TBLANKS+=BLANKS'
	let 'TCOMMENTS+=COMMENTS'
	let 'TCODE+=CODE'
	let 'TOTAL+=SUBTOTAL'
done

DRAW_FOOTER "TOTAL:" $TCODE $TCOMMENTS $TDOCS $TBLANKS $TOTAL
