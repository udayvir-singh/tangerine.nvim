#!/usr/bin/env bash

set -eou pipefail

SOURCE="${1?required arg SOURCE}"
TARGET="${2?required arg TARGET}"

source $(dirname $0)/utils/core.sh

# --------------------- #
#       PANVIMDOC       #
# --------------------- #
SRCDIR="./panvimdoc"
REMOTE="https://github.com/kdheepak/panvimdoc/raw/main/scripts"
 FILES="include-files.lua inspect.lua panvimdoc.lua"

DOWNLOAD=0
for FILE in ${FILES}; do
	[ ! -r "${SRCDIR}/${FILE}" ] && DOWNLOAD=1
done

if [ ${DOWNLOAD} -eq 1 ]; then
	mkdir "${SRCDIR}" 2>/dev/null

	:: DOWNLOADING PANVIMDOC
	for FILE in ${FILES}; do
		if curl -sLJ "${REMOTE}/${FILE}" -o "${SRCDIR}/${FILE}"; then
			log 2 "${SRCDIR}/${FILE}"
		else
			log 1 "${SRCDIR}/${FILE}"
			exit 1
		fi
	done
	:: DONE
fi

# --------------------- #
#         MAIN          #
# --------------------- #
LOGFILE="$(mktemp)"

panvimdoc () {
	< "${SOURCE}" \
	awk '{ 
		# parse ignore
		if ($0 ~ "ignore-line") { 
			getline
			getline
		}
		if ($0 ~ "ignore-start") {
			ignore="Yes" 
		}
		if (ignore && $0 ~ "ignore-end") {
			ignore=Null; getline 
		}

		# parse doc-tags
		if ($2 ~ "doc=.+") {
			doc=$2
			getline 
			$(NF + 1)="{"doc"}"
		}

		# parse optional args
		if ($0 ~ "{.+?}") {
			gsub("?}", "*}", $0)
		}

		# parse header blocks
		if ($1 == "#####" && $(NF) ~ ":$" ) {
			$(NF + 1)="~"
		}

		# strip html blocks
		if (! code && $1 ~ "^```") {
			code="Yes"
		}
		else if (code && $1 ~ "^```") {
			code=Null
		}

		if (! code) gsub("<[^>]+>", "", $0)

		if (! ignore) print $0 
	}' |
	pandoc \
		-M 'project:tangerine' -M 'description:Sweet fennel integeration for neovim' \
		-t           "${SRCDIR}/panvimdoc.lua" \
		--lua-filter "${SRCDIR}/include-files.lua" \
		--lua-filter "${SRCDIR}/inspect.lua" \
		-o "${TARGET}" 2> "${LOGFILE}"
}

:: RUNNING PANVIMDOC
if panvimdoc; then
	log 2 "${TARGET#./}"
else
	log 1 ERROR >&2
	logcat "${LOGFILE}"
	exit 1
fi

