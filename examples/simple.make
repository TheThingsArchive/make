
# name of the executable
NAME = main

# location of executable
RELEASE_DIR = release

include .make/*.make
include .make/go/*.make
include .make/go/protos/*.make
include .make/js/*.make
include .make/js/webpack/*.make

build: go.build js.build
dev: go.install go.link-dev js.dev
link: go.link
deps: go.deps js.deps
dev-deps: go.dev-deps js.dev-deps
test: go.test js.test
quality: go.quality js.quality
quality-staged: go.quality-staged js.quality-staged
clean: go.clean js.clean

# vim: ft=make
