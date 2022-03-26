#!/usr/bin/env bash

set -eou pipefail

SOURCE_DIR="${1?required arg SOURCE}"

source $(dirname $0)/utils/core.sh

# --------------------- #
#         UTILS         #
# --------------------- #
get-deps () {
	local SOURCE="${1}"

	awk '{
		if ($2 == "DEPENDS:") {
			getline
			block="True"
		}
		else if ($1 != ";") {
			block=Null
		}

		if (block) print $(NF)
	}' < "${SOURCE}" | sort

}

get-about () {
	local SOURCE="${1}"
	local ABOUT=$(
	awk '{
		if ($2 == "ABOUT:") {
			getline
			block="True"
		}
		else if ($1 != ";" || $2 == "DEPENDS:") {
			block=Null
		}

		if (block) {
			gsub("^; *", "")
			print $0
		}
	}' < "${SOURCE}")

	if [ -n "${ABOUT}" ]; then
		printf "${ABOUT}"
	else
		printf "[none]\n"
	fi
}

nvim-eval () {
	local SOURCE="${1}"
	local LUACMD="lua xpcall(
		function()  require('tangerine.api').eval.file('${SOURCE}', {float=false}) end,
		function(x) print('ERROR:', x) end
	)"

	nvim -n --noplugin --headless \
	     -c "${LUACMD}" \
	     -c q 2>&1 | tr -d '\r'
}

get-exports () {
	local SOURCE="${1}"
	local MODULE=$(basename "${SOURCE}")
	local RETURN=$(nvim-eval "${SOURCE}")

	if [[ "${RETURN}" =~ "ERROR:" ]]; then
		echo "${RETURN}" | sed 's/^/       /' >&2
		exit 1
	fi

	printf ":%s%s\n" "${MODULE%.fnl}" "${RETURN#:return}"
}

gen-markdown () {
	SOURCE="${1}"

	TITLE="$(basename "${SOURCE}")"
	ABOUT="$(get-about "${SOURCE}")"
	DEPENDS="$(get-deps "${SOURCE}")"
	EXPORTS="$(get-exports "${SOURCE}")"

	echo "# ${TITLE}"
	echo "> ${ABOUT}"

	[ -n "${DEPENDS}" ] && printf '
**DEPENDS:**
```
%s
```
' "${DEPENDS}"

	printf '
**EXPORTS**
```fennel
%s
```
\n' "${EXPORTS}"
}

gen-markdown-dir () {
	local DIR="${1}"

	echo "# $(basename ${DIR})/"

	printf "| %-40s | %-60s |\n" "MODULE" "DESCRIPTION"

	# print header line
	printf "| "
	printf -- "-%.0s" {1..40}
	printf " | "
	printf -- "-%.0s" {1..60}
	printf " |\n"

	for SOURCE in ${DIR}/*.fnl; do
		if [[ "${SOURCE}" =~ "init.fnl" ]]; then
			continue
		fi

		local NAME="$(basename "${SOURCE}")"
		local LINK="$(sed "s:$(dirname ${DIR})::" <<< "${SOURCE}")"
		local ABOUT="$(get-about "${SOURCE}" | head -1)"
		
		printf "| %15s%-25s | %-60s |\n" "[${NAME}]" "(.${LINK})" "${ABOUT}"
	done
	echo
}


# --------------------- #
#         MAIN          #
# --------------------- #
SUB_DIRS="$(find "${SOURCE_DIR}" -type d)"

:: GENERATING FENNEL DOCS
for DIR in ${SUB_DIRS}; do
	log 2 "$(sed "s:^fnl/::" <<< "${DIR}")"

	for SOURCE in "${DIR}"/*.fnl; do
		if [[ "${SOURCE}" =~ "init.fnl" ]]; then
			continue
		fi
		gen-markdown "${SOURCE}"
	done > "${DIR}/README.md"

	NESTED_DIRS="$(find "${DIR}"/* -type d)"

	for NDIR in ${NESTED_DIRS}; do
		gen-markdown-dir "${NDIR}"
	done >> "${DIR}/README.md"
done
:: DONE
