#!/usr/bin/env bash

FNL_FILES="${1}"

source $(dirname $0)/table.sh
source $(dirname $0)/utils.sh

# --------------------- #
#         VARS          #
# --------------------- #
DOCS_REGEX="^ *\""
BLANK_REGEX="^$"
COMMENT_REGEX="^;"

TDOCS=0; TBLANKS=0; TCOMMENTS=0; TCODE=0; TOTAL=0
COLUMNS="FILE Code Comments Docs Blanks SUBTOTAL"


# --------------------- #
#         MAIN          #
# --------------------- #
DRAW_HEADER $COLUMNS

for SOURCE in $FNL_FILES; do 
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
