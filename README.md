# Make

This is a collection of rules that can be reused accross projects to prevent
every project from reinventing the wheel.

## Adding this repository as a subtree in your project

```
git subtree add --prefix .make https://github.com/TheThingsIndustries/make.git master --squash
```

_to update, replace `add` with `pull`._

## Including files in your `Makefile`

```makefile
include .make/*.make

include .make/js/*.make          # when using js
include .make/js/webpack/*.make  # when using webpack
include .make/go/*.make          # when using go
include .make/go/protos/*.make   # when using protobufs
```

## Using rules in your `Makefile`

```makefile
build: go.build js.build
dev: go.dev js.dev
quality: go.quality js.quality headers.check
quality-staged: go.quality-staged js.quality-staged headers.fix-staged
deps: go.deps js.deps
test: go.test js.test
```

## Configuring the pre-commit hook:

```
PRE_COMMIT = quality-staged
```

## Initializing the repo:

```
make init
```

Look at the example `examples/simple.make` in this repo to see a typical set up.

## Customizing rules

Most rules depend on customizable variables so they're easy to reuse (even
multiple times in the same Makefile).

The best thing is to read the relevant file and figure out what to override.
The `examples/` folder also contains some examples.
