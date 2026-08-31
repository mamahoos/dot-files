# Reference: architecture decision making

Loaded from `SKILL.md` when you need catalogs. Do not treat this as a second pipeline.

## Pick at most three characteristics

From ISO/IEC 25010-style quality, only what this Decision must protect:

| Characteristic | Realistic question for the operators in the hand |
|---|---|
| Maintainability | Can you change it in a year without a rewrite? |
| Operability | Can you deploy, backup, and debug it at 02:00 alone? |
| Security | What is the trust boundary and where do secrets live? |
| Reliability | What happens when the one box or the one dependency dies? |
| Performance | Do you have a measured bottleneck, or a feeling? |
| Portability | Does it only work on the author's machine? |
| Observability | How do you know it is broken before a user tells you? |

If everything is "must", nothing is. Rank, pick ≤3, drop the rest for this Decision.

## Failure modes (this operator, not a platform team)

Walk the ones that can actually happen. Skip "region failover" unless you already run two regions.

- Disk fills; log volume; backup never tested
- Single host down; Compose project will not start
- Token/expiry: `gh`, GPG, TLS, registry
- Secret in git; leaked `.env`
- Dependency vanished or broke on a minor bump
- CI runner offline; Actions minutes gone
- One-person bus factor (you)
- Data migration half-applied
- Time: student + job → unfinished "proper" rewrite

For each mode you keep: detection, impact, mitigation that uses cards in hand.

## Operational cost

Who is on-call? Default: you. Price every option in:

- hours to ship the first working path
- hours/month to keep it alive (updates, backups, certs)
- cognitive load (new card vs boring card)
- blast radius if wrong (data, public API, prod topology)

An option that needs a team you do not have costs infinite.

## Standards (use, do not reenact)

| Source | What to take | What to skip |
|---|---|---|
| ISO/IEC/IEEE 42010 | Stakeholders + concerns. Here: you, future-you, maybe one collaborator. | Architecture Description Documents, viewpoint libraries |
| ISO/IEC 25010 | Characteristic names as a menu | Scoring every attribute |
| Nygard ADRs | Downstream record after Decision | Using the ADR template *as* the decision process |
| Richards & Ford | Trade-off analysis; architecture characteristics | Enterprise diagrams for a personal repo |
| Fairbanks (risk-first) | Decide against real risks | Risk theater |
| Fowler / YAGNI / Gall's law | Working simple systems evolve; do not start complex | "We'll need it later" as a requirement |
| Two-way vs one-way doors | Short path vs full path | Analysis paralysis on reversible choices |
| C4 | Optional sketch of options if a picture would change the Decision | Mandatory diagrams |

## Architecture that serves the problem

Align with user-context: Clean Architecture / DDD / explicit boundaries **when they pay rent**. Do not introduce DDD, CQRS, event sourcing, or microservices because they look professional. Small system → simple modular. Growing system → evolvable, not a rewrite.
