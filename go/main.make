# default release dir
RELEASE_DIR ?= release#

# The first entry of the go path
GO_PATH ?= $(shell echo $(GOPATH) | awk -F':' '{ print $$1 }')

# The name of you go package (eg. github.com/foo/bar)
GO_PKG ?= $(shell echo $(PWD) | sed s:$(GO_PATH)/src/::)


# Programs
GO = go
GOLINT = golint

.PHONY: go.pre

# Flags
## go
GO_FLAGS = -a
GO_ENV = CGO_ENABLED=0
LD_FLAGS = -ldflags "-w -X main.commit=$(GIT_COMMIT) -X main.date=$(BUILD_DATE) -X main.tag=$(GIT_TAG) -X main.branch=$(GIT_BRANCH) $(LICENSE_VARS)"

## golint
GOLINT_FLAGS = -set_exit_status

## test
GO_TEST_FLAGS = -cover

## coverage
GO_COVER_FILE = coverage.out
GO_COVER_DIR  = .coverage

# Filters

## select only go files
only_go = grep '\.go$$'

## select/remove vendored files
no_vendor = grep -v 'vendor'
only_vendor = grep 'vendor'

## select/remove mock files
no_mock = grep -v '_mock\.go'
only_mock = grep '_mock\.go'

## select/remove protobuf generated files
no_pb = grep -Ev '\.pb\.go$$|\.pb\.gw\.go$$'
only_pb = grep -E '\.pb\.go$$|\.pb\.gw\.go$$'

## select/remove test files
no_test = grep -v '_test\.go$$'
only_test = grep '_test\.go$$'

## filter files to packages
to_packages = sed 's:/[^/]*$$::' | sort | uniq

## make packages local (prefix with ./)
to_local = sed 's:^:\./:' | sed 's:^\./main\.go$$:.:'


# Selectors

## find all go files
GO_FILES = $(ALL_FILES) | $(only_go)

## local go packages
GO_PACKAGES = $(GO_FILES) | $(no_vendor) | $(to_packages)

## external go packages (in vendor)
EXTERNAL_PACKAGES = find ./vendor -name "*.go" | $(to_packages) | $(only_vendor)

## staged local packages
STAGED_PACKAGES = $(STAGED_FILES) | $(only_go) | $(no_vendor) | $(to_packages) | $(to_local)

## packages for testing
TEST_PACKAGES = $(GO_FILES) | $(no_vendor) | $(only_test) | $(to_packages)

# Rules

## get tools required for development
go.dev-deps:
	$(log) "fetching go tools"
	@command -v govendor > /dev/null || ($(log) Installing govendor && $(GO) get -u github.com/kardianos/govendor)
	@command -v golint > /dev/null || ($(log) Installing golint && $(GO) get -u github.com/golang/lint/golint)

## install dependencies
go.deps:
	$(log) "fetching go dependencies"
	@govendor sync -v

## install packages for faster rebuilds
go.install:
	$(log) "installing `$(EXTERNAL_PACKAGES) | $(count)` go packages"
	@$(EXTERNAL_PACKAGES) | xargs $(GO) install -v

## pre-build local files, ignoring failures (from unused packages or files for example)
## use this to improve build speed
go.pre:
	$(log) "installing go packages"
	@$(GO_FILES) | $(to_packages) | xargs $(GO) install -v || true


## clean build files
go.clean:
	$(log) "cleaning release dir" [rm -rf $(RELEASE_DIR)]
	@rm -rf $(RELEASE_DIR)

## run tests
go.test:
	$(log) testing `$(TEST_PACKAGES) | $(count)` go packages
	@$(GO) test $(GO_TEST_FLAGS) `$(TEST_PACKAGES)`

## clean cover files
go.cover.clean:
	rm -rf $(GO_COVER_DIR) $(GO_COVER_FILE)

## package coverage
$(GO_COVER_DIR)/%.out: GO_TEST_FLAGS=-cover -coverprofile="$(GO_COVER_FILE)"
$(GO_COVER_DIR)/%.out: %
	$(log) "testing $<"
	@mkdir -p `dirname "$(GO_COVER_DIR)/$<"`
	@$(GO) test -cover -coverprofile="$@" "./$<"

## project coverage
$(GO_COVER_FILE): go.cover.clean $(patsubst ./%,./$(GO_COVER_DIR)/%.out,$(shell $(TEST_PACKAGES)))
	@echo "mode: set" > $(GO_COVER_FILE)
	@cat $(patsubst ./%,./$(GO_COVER_DIR)/%.out,$(shell $(TEST_PACKAGES))) | grep -vE "mode: set" | sort >> $(GO_COVER_FILE)

# list all go files
go.list:
	@$(GO_FILES) | sort

# list all staged go files
go.list-staged: GO_FILES = $(STAGED_FILES) | $(only_go)
go.list-staged: go.list

# init initializes go
go.init:
	$(log) "initializing go"
	@govendor init

INIT_RULES += go.init

# vim: ft=make
