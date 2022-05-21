FENNEL_BIN  = deps/bin/fennel
SOURCE_DIR  = fnl
INSTALL_DIR = ~/.local/share/nvim/site/pack/tangerine/start/tangerine.nvim

ifndef VERBOSE
.SILENT:
endif

.ONESHELL:
SHELL = /bin/bash

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

deps:
	./scripts/link deps/lua lua/tangerine/fennel || exit

fnl:
	./scripts/fennel "$(FENNEL_BIN)" "$(SOURCE_DIR)" || exit
	echo "# ABOUT
	Contains compiled output from [fennel](../fnl) dir.
		
	DON'T make direct changes to lua files since they will be deleted by build runner." > lua/README.md

fnldoc:
	./scripts/fnldoc fnl/tangerine || exit

vimdoc:
	[ -d doc ] || mkdir doc
	./scripts/docs README.md ./doc/tangerine.txt || exit
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
	echo :: FINISHED INSTALLING

uninstall:
	rm -rf $(INSTALL_DIR)
	echo :: UN-INSTALLED TANGERINE


# ------------------- #
#       TESTING       #
# ------------------- #
.PHONY: test

runner:
	echo :: COMPILING TEST RUNNER
	$(FENNEL_BIN) --globals vim -c "test/runner/init.fnl" > "lua/tangerine/test.lua" || exit
	echo :: DONE

test:
	if [ ! -r "lua/tangerine/test.lua" ]; then
		echo -e "\e[1;31mERROR:\e[0;31m test library not found\e[0m"
		echo -e "  * try running \"\e[0mmake runner\e[0m\"\n"
		exit 1
	fi
	
	read -p \
	"[1;33mWARN[0m this will delete your neovim config
	
	:: CONTINUE [y/N] " REPLY
	
	if [[ "$${REPLY,,}" =~ ^y(o+!*|es)?$$ ]]; then
		./scripts/test ./test
	fi


# ------------------- #
#         GIT         #
# ------------------- #
GIT := $(shell if command -v git &>/dev/null; then echo git; else echo true; fi)

LUA_FILES := $(shell $(GIT) ls-files lua)
DOC_FILES := $(shell $(GIT) ls-files "fnl/*/README.md")

--pull:
	git restore doc lua $(DOC_FILES)
	echo :: RUNNING GIT PULL
	echo -e  "   \e[1;32m$$\e[0m git pull"
	(git pull --rebase 2>&1 || sleep 4) | sed 's:^:   :'

git-pull: git-unskip --pull clean build git-skip

git-skip:
	git update-index --skip-worktree $(LUA_FILES) $(DOC_FILES)
	git update-index --skip-worktree doc/tangerine.txt

git-unskip:
	git update-index --no-skip-worktree $(LUA_FILES) $(DOC_FILES)
	git update-index --no-skip-worktree doc/tangerine.txt


# ------------------- #
#         LOC         #
# ------------------- #
ifdef LOC_HEAD
LOC_ARGS= --head " " $(LOC_HEAD)
endif

loc-fennel:
	./scripts/loc/fennel $(LOC_ARGS)

loc-test:
	./scripts/loc/fennel --dir test --title TEST $(LOC_ARGS)

loc-bash:
	./scripts/loc/bash $(LOC_ARGS)

loc-markdown:
	./scripts/loc/markdown $(LOC_ARGS)

loc-makefile:
	./scripts/loc/makefile $(LOC_ARGS)

loc-yaml:
	./scripts/loc/yaml $(LOC_ARGS)


# ------------------- #
#        INFO         #
# ------------------- #
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
| Testing:
|   :runner         compiles test runner library
|   :test           runs unit tests, pray before executing
|
|
| Git helpers:
|   - Hooks for git meant to be used in development,
|   - run :git-skip before running :build to prevent output files in git index
|
|   :git-skip       make git ignore build dirs
|   :git-unskip     reverts git-skip, run :build before executing
|   :git-pull       clean build dirs before fetching to avoid conflicts
|
|
| Lines of Code:
|   - Pretty prints lines of code in source dirs, possible targets are:
|
|   :loc-fennel
|   :loc-test
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
