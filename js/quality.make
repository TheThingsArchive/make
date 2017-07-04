
.PHONY: js.quality js.quality-staged js.lint js.lint-staged

# Lint

## lint all js files
js.lint:
	$(log) "linting `$(JS_FILES) | $(count)` js files"
	@set -o pipefail; ($(JS_FILES) || exit 0) | xargs $(ESLINT) $(ESLINT_FLAGS) | sed 's:$(PWD)/::'

## lint staged js files
js.lint-staged: JS_FILES = $(JS_STAGED_FILES)
js.lint-staged: js.lint

## perform all js quality checks
js.quality: js.lint

## perform js quality checks on staged files
js.quality-staged: js.lint-staged

## test all js files
js.test:
	$(log) "testing `$(JS_TESTS) | $(count)` js files"
	@$(JEST) `$(JS_TESTS)`

# vim: ft=make
