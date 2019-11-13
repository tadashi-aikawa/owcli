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

version := $(shell git rev-parse --abbrev-ref HEAD)


#---- Basic

init-dev: ## Install dependencies and create envirionment
	@poetry install

test-cli: ## Test on CLI
	@poetry run bats tests/test.bats


#---- Release

_clean-package: ## Clean package
	@rm -rf build dist jumeaux.egg-info

_package: _clean-package ## Package OwlMixin
	@poetry build -f wheel

release:## Release

	@echo '0. Install packages from lockfile and test'
	@make init-dev
	@make test-cli

	@echo '1. Version up'
	@poetry version $(version)

	@echo '2. Staging and commit'
	git add pyproject.toml
	git commit -m ':package: Version $(version)'

	@echo '3. Tags'
	git tag v$(version) -m v$(version)

	@echo '4. Package Owcli'
	@make _package

	@echo '5. Publish'
	@poetry publish

	@echo '6. Push'
	git push origin v$(version)
	git push

	@echo 'Success All!!'
	@echo 'Create a pull request and merge to master!!'
	@echo 'https://github.com/tadashi-aikawa/owcli/compare/$(version)?expand=1'

