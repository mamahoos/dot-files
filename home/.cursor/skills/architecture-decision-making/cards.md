# The hand (cards we actually hold)

A Decision that plays cards we do not hold is fiction. Build the hand from evidence, then name any **new card** as extra cost.

## Where to read

1. `.architecture/cards.md` in the current repo, if it exists (copy from [templates/cards.md](templates/cards.md)).
2. Else derive, in this order:
   - repo artifacts: `compose.yml` / `Dockerfile` / `pyproject.toml` / `go.mod` / `.github/workflows`
   - `graphify query` / existing modules
   - user-level `00-user-context` (confident vs learning vs conceptual)
   - `gh` collaborators and hosting you can see (not hypothetical teams)

If sources conflict, stop and name the conflict. Do not silently pick the fancier stack.

## Suites

Fill every suite. Empty is allowed; invented is not.

| Suite | What to record |
|---|---|
| Operators | How many humans run this in prod. Default for mamahoos personal repos: **1**. |
| Time | Student + job. Prefer boring, reversible, operable this week. |
| Languages | What the repo already compiles/runs. Confident default: Python, Bash. |
| Runtime | What already deploys. Confident default: Linux, Docker, Compose. |
| Edge | Traefik / Nginx only if present or you already operate them on this host. |
| Data | PostgreSQL / Redis only if the project already has them or Option 0 needs them. |
| CI | GitHub Actions, self-hosted runners — if the repo has workflows. |
| Observability | Prometheus / Grafana / Graylog — only if already in the path. |
| Identity | GPG, `gh`, SSH — as used in this repo. |
| Scale evidence | Numbers you can point at. No numbers → `unknown` → single-operator / small. |

## Confident vs learning vs conceptual

`00-user-context` lists both daily tools and a learning path (`Linux → … → Kubernetes → …`).

- **Confident:** you already operate it. Legal to play by default.
- **Learning:** you are building skill. Playing it is a **new card** even if the name appears in the profile.
- **Conceptual:** you have read about it. Not in the hand.

Kubernetes, Helm, GitOps/ArgoCD, Terraform, DDD, CQRS, event sourcing, microservices are **not** default plays. They become cards only when the repo already uses them, or when you explicitly accept the new-card tax.

## New-card tax

To add a card not in the hand, write all four:

1. Why no existing card works
2. What you must learn before prod
3. Who operates it at 02:00 (usually you)
4. How you reverse it if it is wrong

If you cannot fill (3) and (4), do not add the card.

## Scale (no imaginary)

State evidence or `unknown`. Legal evidence: current users, request rate, disk, backup size, deploy cadence, number of machines, on-call rotations.

Illegal: "when we scale", "enterprise ready", "FAANG-style", copying a conference talk's topology onto a Compose app.

Don't optimize architecture for imaginary scale.
