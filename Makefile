MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
ARGS :=
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

.PHONY: $(shell egrep -oh ^[a-zA-Z0-9][a-zA-Z0-9_-]+: $(MAKEFILE_LIST) | sed 's/://')

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9][a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "[REQUIRED ERROR] \`$*\` is required."; \
		exit 1; \
	fi

-include .env

#---- Basic

test-cli: ## Test on CLI
	@uv run bats tests/test.bats


#---- Release

_clean-package: ## Clean package
	@rm -rf build dist owcli.egg-info

_package: _clean-package ## Package OwlMixin
	@uv build

release: guard-version ## make release version=x.y.z

	@echo '0. Install packages from lockfile and test'
	@uv sync
	# @make test-cli

	@echo '1. Version up'
	@sed -i 's/^version = ".*"/version = "$(version)"/' pyproject.toml

	@echo '2. Staging and commit'
	git add pyproject.toml
	git commit -m ':package: Version $(version)'

	@echo '3. Tags'
	git tag v$(version) -m v$(version)

	@echo '4. Package Owcli'
	@make _package

	@echo '5. Publish'
	@uv publish

	@echo '6. Push'
	git push --tags
	git push

	@echo 'Success All!!'

