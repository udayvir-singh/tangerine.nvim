#!/usr/bin/env bash

$(dirname $0)/__init__.sh \
	--title BASH \
	--comment "^ *#.+" \
	--dir scripts \
	--ext "*.sh" ${@}
