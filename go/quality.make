
.PHONY: go.fmt go.fmt-staged go.vet go.vet-staged go.lint go.lint-staged go.quality go.quality-staged

# Fmt

## fmt all packages
go.fmt:
	$(log) "formatting `$(GO_PACKAGES) | $(count)` go packages"
	@[[ -z "`$(GO_PACKAGES) | xargs go fmt | tee -a /dev/stderr`" ]]

## fmt stages packages
go.fmt-staged: GO_PACKAGES = $(STAGED_PACKAGES)
go.fmt-staged: go.fmt

# Vet

## vet all packages
go.vet:
	$(log) "vetting `$(GO_PACKAGES) | $(count)` go packages"
	@$(GO_PACKAGES) | xargs $(GO) vet

## vet staged packages
go.vet-staged: GO_PACKAGES = $(STAGED_PACKAGES)
go.vet-staged: go.vet

# Linting
## lint all packages, exiting when errors occur
GO_LINT_FILES = $(GO_FILES) | $(no_vendor) | $(no_mock) | $(no_pb)
go.lint:
	$(log) "linting `$(GO_LINT_FILES) | $(count)` go files"
	@CODE=0; for pkg in `$(GO_LINT_FILES)`; do $(GOLINT) $(GOLINT_FLAGS) $$pkg 2>/dev/null || { CODE=1; }; done; exit $$CODE

## lint all packages, ignoring errors
go.lint-all: GOLINT_FLAGS =
go.lint-all: go.lint


# lint staged files
GO_LINT_STAGED_FILES = $(STAGED_FILES) | $(only_go) | $(no_vendor) | $(no_mock) | $(no_pb)
go.lint-staged: GO_LINT_FILES = $(GO_LINT_STAGED_FILES)
go.lint-staged: go.lint

# Coveralls

go.cover.dev-deps:
	@go get -u github.com/mattn/goveralls

coveralls: go.cover.dev-deps $(GO_COVER_FILE)
	goveralls -coverprofile=$(GO_COVER_FILE) -service=travis-ci -repotoken $$COVERALLS_TOKEN

# Quality

## run all quality on all files
go.quality: go.fmt go.vet go.lint go.check-vendors

## run all quality on staged files
go.quality-staged: go.fmt-staged go.vet-staged go.lint-staged go.check-vendors-staged

GO_VENDOR_FILE=vendor/vendor.json

VENDOR_FILE = $(GO_VENDOR_FILE)

## check if you have vendored packages in vendor
go.check-vendors: DOUBLY_VENDORED=$(shell cat $(VENDOR_FILE) | grep -n vendor | awk '{ print $$1 $$3 }' | sed 's/[",]//g')
go.check-vendors:
	@test $(VENDOR_FILE) != "/dev/null" && $(logi) "checking $(VENDOR_FILE) for bad packages" || true
	@if test $$(echo $(DOUBLY_VENDORED) | wc -w) -gt 0; then $(logi) "doubly vendored packages in $(VENDOR_FILE):" && echo $(DOUBLY_VENDORED) | xargs -n1 echo "       " | sed 's/:/  /' && exit 1; fi

go.check-vendors-staged: VENDOR_FILE=$(shell $(STAGED_FILES) | grep $(GO_VENDOR_FILE) >/dev/null && echo $(GO_VENDOR_FILE) || echo /dev/null)
go.check-vendors-staged: go.check-vendors

# vim: ft=make
