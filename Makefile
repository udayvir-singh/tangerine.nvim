FENNEL      := ./deps/bin/1-0-0
FNL_DEPS    := $(shell find deps -name '*.lua')
FNL_FILES   := $(shell find fnl  -name '*.fnl')
INSTALL_DIR := ~/.local/share/nvim/site/pack/tangerine/start/tangerine.nvim

default: help

# ------------------- #
#      COMPILING      #
# ------------------- #
.PHONY: fnl deps

fnl: 
	@.scripts/compile.sh "$(FENNEL)" "$(FNL_FILES)"

deps:
	@.scripts/copy-deps.sh "$(FNL_DEPS)" lua/tangerine/fennel

install: deps fnl
	@[[ -d $(INSTALL_DIR) ]] || mkdir -p $(INSTALL_DIR)
	@ln -srf lua $(INSTALL_DIR)/lua
	@echo ":: FINISHED INSTALLING"


# ------------------- #
#        EXTRA        #
# ------------------- #
clean:
	@rm -rf lua/**
	@echo ":: CLEANED BUILD DIR"
	@rm -rf $(INSTALL_DIR)
	@echo ":: CLEANED INSTALL DIR"

loc:
	@.scripts/loc.sh "$(FNL_FILES)"

help:
	@echo 'GNU Make Targets'
	@echo '  :fnl       compiles fennel files.'
	@echo '  :deps      copy required deps in lua folder.'
	@echo '  :install   makes and install tangerine on this system.'
	@echo '  :clean     deletes build and install dir.'
	@echo '  :loc       pretty print lines of code in fennel files.'
	@echo '  :help      print this help.'
	@echo
	@echo 'Examples:'
	@echo '  make clean install'
	@echo '  make loc  [do it]'
