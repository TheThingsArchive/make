
# Set shell
SHELL = bash

## count the input
count = wc -w

GENERAL_FILE = echo $(MAKEFILE_LIST) | xargs -n 1 echo | grep 'general\.make'
MAKE_DIR = $(GENERAL_FILE) | xargs dirname

# Init rules are the rules to invoke to initialize the repo
INIT_RULES ?= git.hooks

# init invokes the init rules
init:
	@make $(INIT_RULES)

internal.update:
  @$(log) "updating make plugins..."
  @git subtree pull --prefix .make https://github.com/TheThingsIndustries/make.git master --squash

# vim: ft=make
