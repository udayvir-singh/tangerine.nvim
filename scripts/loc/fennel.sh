#!/usr/bin/env bash

$(dirname $0)/__init__.sh \
	--title FENNEL \
	--docs '^ *"[^"]+" *$' \
	--comment "^ *;.+" \
	--dir fnl \
	--ext '*.fnl' ${@}
