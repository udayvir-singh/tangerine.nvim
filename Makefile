FENNEL_BIN  = deps/bin/fennel
SOURCE_DIR  = fnl
INSTALL_DIR = ~/.local/share/nvim/site/pack/tangerine/start/tangerine.nvim

ifndef VERBOSE
.SILENT:
endif

default: help

# ------------------- #
#      BUILDING       #
# ------------------- #
.PHONY: fnl deps
build: deps fnl fnldoc vimdoc

watch-build:
	watchexec -f "fnl/**/*.fnl" -f "README.md" -i "fnl/**/README.md" \
		'make --no-print-directory clean build && 
		notify-send DONE "  ==> tangerine.nvim" ||
		notify-send "BUILD ERROR" "$$(cat /tmp/tangerine-err)"'

fnl: 
	./scripts/compile.sh "$(FENNEL_BIN)" "$(SOURCE_DIR)"

deps:
	./scripts/link.sh deps/lua lua/tangerine/fennel

fnldoc:
	./scripts/fnldocs.sh fnl/tangerine

vimdoc:
	[ -d doc ] || mkdir doc
	./scripts/docs.sh README.md ./doc/tangerine.txt
ifndef NO_HELPTAGS
	echo :: GENERATING HELPTAGS
	nvim -n --noplugin --headless -c "helptags doc" -c "q" doc/tangerine.txt
else
	echo :: DONE
endif

clean:
	rm -rf doc/tags doc/tangerine.txt
	echo :: CLEANED VIMDOC
	rm -rf $(shell find fnl -name "README.md")
	echo :: CLEANED FENNEL DOCS
	rm -rf lua/**
	echo :: CLEANED BUILD DIR

install:
	[ -d $(INSTALL_DIR) ] || mkdir -p $(INSTALL_DIR)
	ln -srf lua doc -t $(INSTALL_DIR)
	nvim --headless -c "packadd tangerine" -c "q" &>/dev/null
	echo :: FINISHED INSTALLING

uninstall:
	rm -rf $(INSTALL_DIR)
	echo :: UN-INSTALLED TANGERINE
	

# ------------------- #
#         LOC         #
# ------------------- #
ifdef LOC_HEAD
LOC_ARGS= --head " " $(LOC_HEAD)
endif

loc-fennel:
	./scripts/loc/fennel.sh $(LOC_ARGS)

loc-bash: 
	./scripts/loc/bash.sh $(LOC_ARGS)

loc-markdown: 
	./scripts/loc/markdown.sh $(LOC_ARGS)

loc-makefile: 
	./scripts/loc/makefile.sh $(LOC_ARGS)

loc-yaml: 
	./scripts/loc/yaml.sh $(LOC_ARGS)


# ------------------- #
#        INFO         #
# ------------------- #
.ONESHELL:

define HELP
| Usage: make [target] ...
| 
| Building:
|   :fnl            compiles fennel files
|   :deps           copy required deps in lua folder
|   :vimdoc         runs panvimdoc to generate vimdocs
|   :fnldoc         generates module level README
| 
|   :build          combines :fnl :deps :fnldoc :vimdoc
|   :watch-build    watches source dir, runs :build on changes
| 
|   :install        install tangerine on this system
|   :clean          deletes build and install dir
|   :help           print this help
| 
| 
| Lines of Code:
|   - Pretty prints lines of code in source dirs, possible targets are:
| 
|   :loc-fennel
|   :loc-bash
|   :loc-markdown
|   :loc-makefile
|   :loc-yaml
| 
| 
| Examples:
|   make clean build
|   make install
|   make loc-fennel
endef

help:
	if command -v bat &>/dev/null; then
		echo "$(HELP)" | sed "s:^| ::" | bat -p -l clj --theme=ansi
	else
		echo "$(HELP)" | sed "s:^| ::" | less -F
	fi

