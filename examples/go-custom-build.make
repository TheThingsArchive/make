# This example shows how to build multiple go programs
# using the same rules but with a different config

include .make/*.make
include .make/go/*.make

# Program A
A_NAME = program-a
A_MAIN = ./program_a/main.go

a: NAME = $(A_NAME)
a: MAIN = $(A_MAIN)
a: go.build

a-dev: NAME = $(CTL_NAME)
a-dev: MAIN = $(CTL_MAIN)
a-dev: go.link-dev

# Program B
B_NAME = program-b
B_MAIN = ./program_b/main.go

b: NAME = $(B_NAME)
b: MAIN = $(B_MAIN)
b: go.build

b-dev: NAME = $(CTL_NAME)
b-dev: MAIN = $(CTL_MAIN)
b-dev: go.link-dev

# vim: ft=make
