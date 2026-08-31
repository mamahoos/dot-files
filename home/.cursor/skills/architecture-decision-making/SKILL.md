---
name: architecture-decision-making
description: Makes architecture decisions from the cards actually in hand (stack, operators, evidence of scale). Use when choosing a stack, boundary, storage, deploy shape, or any hard-to-reverse technical door. Use before writing an ADR. Do not use to record a decision already made (that is documentation-and-adrs). Don't optimize architecture for imaginary scale.
disable-model-invocation: true
---

# Architecture Decision Making

This skill **makes** the decision. `documentation-and-adrs` **records** it. Do not fill an ADR template until this pipeline has a Decision.

## Hand first

Inventory the cards we actually hold before naming options. See [cards.md](cards.md).

Do not play a card that is not in the hand unless you name it as a **new card** (learn + operate + ongoing cost).

## Pipeline

Problem
 ↓
Constraints
 ↓
Requirements
 ↓
Options
 ↓
Trade-offs
 ↓
Failure modes
 ↓
Operational cost
 ↓
Decision

Don't optimize architecture for imaginary scale.

## When to use

- Choosing storage, runtime, deploy shape, module boundary, or a major dependency
- A change that would be expensive to reverse (one-way door)
- The user asks for architecture, system design, or "what should we use"
- Before `documentation-and-adrs` on a significant decision

**When not to:**

- a two-line bugfix or a rename
- recording a decision already made (`documentation-and-adrs`)
- performance work without measured load (`performance-optimization`)

## Door type

| Door | Meaning | Path |
|---|---|---|
| Two-way | Cheap to reverse this month (you operate it) | Short: Hand → Problem → Options → Decision |
| One-way | Painful to undo (data, public contract, prod topology) | Full pipeline |

If unsure, treat as one-way. If the write-up would take longer than a reversible spike, take the short path and spike.

## Workflow

Copy and track:

```
- [ ] Hand inventoried (cards.md); new cards named
- [ ] Evidence of scale stated (or "unknown → assume single-operator / small")
- [ ] Door type chosen
- [ ] Pipeline completed (short or full)
- [ ] Option 0 (status quo / do nothing) considered
- [ ] Decision packet written from templates/decision.md
- [ ] `python3 home/.cursor/skills/architecture-decision-making/scripts/check_decision.py PATH` passes
- [ ] User accepted the Decision (or overrode with eyes open)
- [ ] If significant: hand off to documentation-and-adrs
```

**Scale evidence (mandatory).** State what you know: users, RPS, data size, deploy frequency, boxes, operators. If you have no numbers, write `unknown` and design for the hand, not for a blog. Imaginary "when we have millions of users" is not a requirement.

**Option 0** is always on the table: keep the current shape.

**Characteristics.** Pick at most three that this Decision must protect (maintainability, operability, security, …). Catalog: [reference.md](reference.md). Do not score twelve ISO attributes.

**Handoffs (do not duplicate):**

| After Decision involves… | Load |
|---|---|
| Public/module contract | `api-and-interface-design` |
| Trust boundary, secrets, auth | `security-and-hardening` |
| Measured SLO/load | `performance-optimization` |
| High-stakes candidate | `doubt-driven-development` |
| Replacing something in prod | `deprecation-and-migration` |
| Recording the why | `documentation-and-adrs` |

## Output

Fill [templates/decision.md](templates/decision.md). Write it as a working file (`/tmp/decision.md` or next to the change). Do not create `docs/decisions/` here — that folder belongs to `documentation-and-adrs` after the Decision is accepted. Optional project overlay: [templates/cards.md](templates/cards.md) as `.architecture/cards.md`.

```bash
python3 home/.cursor/skills/architecture-decision-making/scripts/check_decision.py PATH
python3 ~/.cursor/skills/architecture-decision-making/scripts/check_decision.py PATH
# two-way door:
python3 home/.cursor/skills/architecture-decision-making/scripts/check_decision.py --short PATH
```

First path is this repo. Second is after `./install.sh`. Do not run `scripts/check_decision.py` from an arbitrary cwd.

## Anti-patterns

- Jumping to an ADR without a Decision
- Kubernetes / DDD / CQRS / event sourcing / microservices because they look professional
- Playing a **learning** card as if it were a **confident** card (see `00-user-context`)
- Optimizing for imaginary scale
- Inventing operators, budgets, or SLOs the repo does not have
- Skipping Option 0
- A 40-page architecture for a Compose app you run alone

## Additional resources

- [cards.md](cards.md) — how to build the hand
- [reference.md](reference.md) — characteristics, failure modes, cost, standards
- [examples.md](examples.md) — decisions at this operator's real scale
- [templates/decision.md](templates/decision.md)
- [templates/cards.md](templates/cards.md)
