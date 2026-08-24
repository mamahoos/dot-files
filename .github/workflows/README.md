# Workflows

CI for this repo. Path-filtered where it matters; no deploy.

| Workflow | File | What it does |
| --- | --- | --- |
| **Lint** | [`lint.yml`](lint.yml) | ShellCheck + shfmt on `home/`, `install.sh`, `.github/scripts/` |
| **Secret Scan** | [`gitleaks.yml`](gitleaks.yml) | Gitleaks on every push/PR (also manual) |
| **Install** | [`install.yml`](install.yml) | Smoke + idempotent checks for `install.sh` on a fake `HOME` |
| **Agent skills** | [`agent-skills.yml`](agent-skills.yml) | Drift check vs upstreams; opens sync PRs on schedule/push |

## Scripts

Helpers live in [`../scripts/`](../scripts/):

| Script | Used by |
| --- | --- |
| `test-install-smoke.sh` | Install → `smoke` |
| `test-install-idempotent.sh` | Install → `idempotent` |
| `sync-upstreams.sh` | Agent skills |

## Local

```bash
shellcheck -S error install.sh .github/scripts/*.sh
shfmt -d -i 2 home install.sh .github/scripts
./.github/scripts/test-install-smoke.sh
./.github/scripts/test-install-idempotent.sh
./.github/scripts/sync-upstreams.sh --check
```

## Notes

- **Lint** and **check-skills-drift** are required status checks, so their workflows always run on pull requests (path filters stay on `push` to `main` only).
- **Agent skills** needs secret `SKILLS_SYNC_TOKEN` (Contents + Pull requests) for automated sync PRs.
- Dependabot config is in [`../dependabot.yml`](../dependabot.yml) (Actions + Docker).
