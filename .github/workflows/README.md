# Workflows

CI for this repo. Path-filtered where it matters; no deploy.

| Workflow | File | What it does |
| --- | --- | --- |
| **Lint** | [`lint.yml`](lint.yml) | ShellCheck on `home/` (except Cursor skills) + shfmt on `install.sh`, `.github/scripts/` |
| **Secret Scan** | [`gitleaks.yml`](gitleaks.yml) | Gitleaks on every push/PR (also manual) |
| **Install** | [`install.yml`](install.yml) | Smoke + idempotent checks for `install.sh` on a fake `HOME` |
| **Agent skills** | [`agent-skills.yml`](agent-skills.yml) | Required drift check vs upstreams (PR + path-filtered push) |
| **Agent skills sync** | [`agent-skills-sync.yml`](agent-skills-sync.yml) | Opens per-source sync PRs on schedule / `workflow_dispatch` |
| **Delete merged sync branch** | [`delete-merged-sync-branch.yml`](delete-merged-sync-branch.yml) | Deletes merged `chore/sync-*` `automated` head branches |

## Scripts

Helpers live in [`../scripts/`](../scripts/):

| Script | Used by |
| --- | --- |
| `test-install-smoke.sh` | Install → `smoke` |
| `test-install-idempotent.sh` | Install → `idempotent` |
| `sync-upstreams.sh` | Agent skills, Agent skills sync |
| `open-skills-sync-prs.sh` | Agent skills sync |

## Local

```bash
shellcheck -S error install.sh .github/scripts/*.sh
shfmt -d -i 2 install.sh .github/scripts
./.github/scripts/test-install-smoke.sh
./.github/scripts/test-install-idempotent.sh
./.github/scripts/sync-upstreams.sh --check
pre-commit install                  # once: Gitleaks on commit (see /.pre-commit-config.yaml)
pre-commit run gitleaks --all-files
```

## Notes

- **Lint**, **Gitleaks**, and **check-skills-drift** are required status checks. Their `pull_request` triggers are `opened` / `synchronize` / `reopened` only — `closed` is omitted so a skipped or cancelled run cannot turn a successful merge red.
- **Agent skills** is check-only. Sync jobs must not share that workflow: a skipped job still counts in the commit X/Y total (5/7 instead of 5/5).
- **Agent skills sync** needs secret `SKILLS_SYNC_TOKEN` (Contents + Pull requests) for automated sync PRs. After you merge a `chore/sync-*` PR labeled `automated`, [`delete-merged-sync-branch.yml`](delete-merged-sync-branch.yml) deletes the head branch (`pull_request_target`, not the disappearing `refs/pull/N/merge` ref).
- Dependabot config is in [`../dependabot.yml`](../dependabot.yml) (Actions + pre-commit hook `rev` pins).
