# Local stand-ins for CI. Recipes match .github/workflows/README.md (Local).
# `make` with no target prints help. CI still calls the scripts directly.

.DEFAULT_GOAL := help

.PHONY: help install install-shell-only install-shell-with-git lint shellcheck shfmt smoke idempotent skills-drift check pre-commit-install gitleaks

help:
	@printf '%s\n' \
	  'install                 ./install.sh' \
	  'install-shell-only      ./install.sh --shell-only (no git identity)' \
	  'install-shell-with-git  ./install.sh --shell-only --with-git' \
	  'lint                    ShellCheck + shfmt' \
	  'shellcheck              shellcheck -S error install.sh .github/scripts/*.sh' \
	  'shfmt                   shfmt -d -i 2 install.sh .github/scripts' \
	  'smoke                   ./.github/scripts/test-install-smoke.sh' \
	  'idempotent              ./.github/scripts/test-install-idempotent.sh' \
	  'skills-drift            ./.github/scripts/sync-upstreams.sh --check --pull' \
	  'pre-commit-install      pre-commit install (Gitleaks, ShellCheck, shfmt, actionlint)' \
	  'gitleaks                pre-commit run gitleaks --all-files' \
	  'check                   lint + smoke + idempotent + skills-drift'

install:
	./install.sh

install-shell-only:
	./install.sh --shell-only

install-shell-with-git:
	./install.sh --shell-only --with-git

lint: shellcheck shfmt

shellcheck:
	shellcheck -S error install.sh .github/scripts/*.sh

shfmt:
	shfmt -d -i 2 install.sh .github/scripts

smoke:
	./.github/scripts/test-install-smoke.sh

idempotent:
	./.github/scripts/test-install-idempotent.sh

skills-drift:
	./.github/scripts/sync-upstreams.sh --check --pull

check: lint smoke idempotent skills-drift

pre-commit-install:
	pre-commit install

gitleaks:
	pre-commit run gitleaks --all-files
