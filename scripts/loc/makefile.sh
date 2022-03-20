#!/usr/bin/env bash

$(dirname $0)/__init__.sh \
	--title MAKE \
	--comment "^ *#.+" \
	--dir . \
	--ext Makefile ${@}
