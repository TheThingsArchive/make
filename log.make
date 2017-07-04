# This makefile has tools for logging useful information
# about build steps

LOG_NAME ?= $(shell basename $$(pwd))

# log colors
log_red = \033[31m
log_green = \033[32m
log_yellow = \033[33m
log_blue = \033[34m
log_magenta = \033[35m
log_cyan = \033[36m
log_bold = \033[1m

log_clear = \033[0m

# default log colors
log_color ?= $(log_bold)$(log_blue)
log_error ?= $(log_bold)$(log_red)
log_warn ?= $(log_bold)$(log_yellow)

log = echo -e "$(log_color)$(LOG_NAME)$(log_clear) "
err = echo -e "$(log_error)$(LOG_NAME)$(log_clear) "
warn = echo -e "$(log_warn)$(LOG_NAME)$(log_clear) "

# vim: ft=make
