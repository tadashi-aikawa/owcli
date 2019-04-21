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

branch_version := $(shell git rev-parse --abbrev-ref HEAD)

#------

init: ## Install dependencies
	pipenv install -d

_clean-package: ## Clean package
	@echo Start $@
	@rm -rf build dist jumeaux.egg-info
	@echo End $@

_package: _clean-package ## Package OwlMixin
	@echo Start $@
	@pipenv run python setup.py bdist_wheel
	@echo End $@

test-cli: ## Test on CLI
	@echo Start $@
	@-bats tests/test.bats
	@echo End $@

release: ## Release (set TWINE_USERNAME and TWINE_PASSWORD to enviroment varialbles)

	@echo '0. Install packages from lockfile and test'
	@pipenv install --deploy
	@make test-cli

	@echo '1. Update versions'
	@sed -i -r 's/__version__ = ".+"/__version__ = "$(branch_version)"/g' owcli/main.py

	@echo '2. Staging and commit'
	git add owcli/main.py
	git commit -m ':package: Version $(branch_version)'

	@echo '3. Tags'
	git tag v$(branch_version) -m v$(branch_version)

	@echo '4. Push'
	git push --tags

	@echo '5. Deploy'
	@echo 'Packaging...'
	@pipenv run python setup.py bdist_wheel
	@echo 'Deploying...'
	@pipenv run twine upload dist/owcli-$(branch_version)-py3-none-any.whl

	@echo 'Success All!!'
	@echo 'Create a pull request and merge to master!!'
	@echo 'https://github.com/tadashi-aikawa/owcli/compare/$(branch_version)?expand=1'
