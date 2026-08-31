# Local stand-ins for CI. Recipes match .github/workflows/README.md (Local).
# `make` with no target prints help. CI still calls the scripts directly.

.DEFAULT_GOAL := help

.PHONY: help install install-shell-only lint shellcheck shfmt smoke idempotent skills-drift check

help:
	@printf '%s\n' \
	  'install              ./install.sh' \
	  'install-shell-only   ./install.sh --shell-only' \
	  'lint                 ShellCheck + shfmt' \
	  'shellcheck           shellcheck -S error install.sh .github/scripts/*.sh' \
	  'shfmt                shfmt -d -i 2 home install.sh .github/scripts' \
	  'smoke                ./.github/scripts/test-install-smoke.sh' \
	  'idempotent           ./.github/scripts/test-install-idempotent.sh' \
	  'skills-drift         ./.github/scripts/sync-upstreams.sh --check' \
	  'check                lint + smoke + idempotent + skills-drift'

install:
	./install.sh

install-shell-only:
	./install.sh --shell-only

lint: shellcheck shfmt

shellcheck:
	shellcheck -S error install.sh .github/scripts/*.sh

shfmt:
	shfmt -d -i 2 home install.sh .github/scripts

smoke:
	./.github/scripts/test-install-smoke.sh

idempotent:
	./.github/scripts/test-install-idempotent.sh

skills-drift:
	./.github/scripts/sync-upstreams.sh --check

check: lint smoke idempotent skills-drift
