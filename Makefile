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
build: deps fnl vimdoc

fnl: 
	./scripts/compile.sh "$(FENNEL_BIN)" "$(SOURCE_DIR)"

deps:
	./scripts/link.sh deps/lua lua/tangerine/fennel

vimdoc:
	./scripts/docs.sh README.md ./doc/tangerine.txt
	echo :: GENERATING HELPTAGS
	nvim --noplugin --headless -c "helptags doc" -c "q" doc/tangerine.txt

install:
	[[ -d $(INSTALL_DIR) ]] || mkdir -p $(INSTALL_DIR)
	ln -srf lua $(INSTALL_DIR)/lua
	ln -srf doc $(INSTALL_DIR)/doc
	echo :: FINISHED INSTALLING

clean:
	rm -rf doc/tags
	echo :: CLEANED HELPTAGS
	rm -rf lua/**
	echo :: CLEANED BUILD DIR
	rm -rf $(INSTALL_DIR)
	echo :: CLEANED INSTALL DIR

# ------------------- #
#        EXTRA        #
# ------------------- #
loc:
	./scripts/loc.sh "$(SOURCE_DIR)"

help:
	echo 'Usage: make [target] ...'
	echo 
	echo 'Targets:'
	echo '  :fnl            compiles fennel files'
	echo '  :deps           copy required deps in lua folder'
	echo '  :vimdoc         runs panvimdoc to generate vimdocs'
	echo '  :build          combines :fnl :deps :vimdoc'
	echo '  :install        install tangerine on this system'
	echo '  :clean          deletes build and install dir'
	echo '  :loc            pretty print lines of code in fennel files'
	echo '  :help           print this help.'
	echo
	echo 'Examples:'
	echo '  make clean install'
	echo '  make vimdoc'
	echo '  make loc  [do it]'
