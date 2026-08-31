# Examples (real scale)

These are sketches, not ADRs. They show playing the hand, not a conference topology.

## 1. This repo (`mamahoos/dot-files`)

**Hand:** 1 operator. Bash/dotfiles, `install.sh`, GitHub Actions, GPG, `gh`. No app runtime. Scale: one human's machines. Kubernetes is a learning card, not in this hand.

**Problem:** Should install grow a "platform" (Ansible, GitOps, k3s) so every host converges like a fleet?

**Door:** two-way for extra scripts; one-way if you replace `install.sh` as the source of truth.

**Option 0:** keep `install.sh` + GitHub workflows.

**Option A:** Ansible playbooks for all hosts.

**Decision (typical):** Option 0. No fleet, no second operator, no measured host count that justifies a control plane. New-card tax for Ansible-as-source-of-truth is unpaid. Revisit if host count and shared state become evidence, not a wish.

Don't optimize architecture for imaginary scale.

## 2. Small FastAPI service you run on one VPS

**Hand:** Python, FastAPI, Docker Compose, Caddy/Traefik you already operate, GitHub Actions. PostgreSQL if the app already has it. Operators: 1. Scale evidence: `unknown` or "tens of requests/day".

**Problem:** Need durable storage for users/tasks.

**Option 0:** JSON files on disk.

**Option A:** SQLite in the Compose volume.

**Option B:** PostgreSQL in Compose.

**Option C:** managed Postgres + Kubernetes.

**Decision:** Option A (SQLite in the volume) unless `compose.yml` already has PostgreSQL — then Option B. Option C is out of the hand. Failure modes that matter: volume not backed up; single VPS down — not multi-AZ.

## 3. Rejected shape

"We'll put every personal project on a Helm/GitOps platform so we're ready for production." That is imaginary scale plus a learning card played as confident. The Decision is no, unless this repo already is that platform.
