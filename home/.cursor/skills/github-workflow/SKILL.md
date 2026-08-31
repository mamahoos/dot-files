---
name: github-workflow
description: Professional GitHub issue/PR workflow with gh CLI. Use when a best-practice use case needs issue → PR → Closes #N → tick checklists → merge, and when assigning, labeling, or merging. Tick linked boxes before merge; grep - [ ] is a hard gate.
disable-model-invocation: true
---

# GitHub Workflow

Git history is `git-workflow-and-versioning`. This skill is GitHub: issues, labels, assignees, reviews, merge.

Docs: [linking PRs](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue), [sub-issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues), [labels](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels).

Verification is mandatory. `gh pr merge` is not allowed while any linked body still contains `- [ ]`.

## 0. Discover (every repo, every time)

```bash
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh repo view --json nameWithOwner,defaultBranchRef,viewerPermission
gh label list
gh api "repos/${OWNER_REPO}/collaborators" --jq '.[] | {login, role_name}'
gh api "repos/${OWNER_REPO}/contents/.github/CODEOWNERS" >/dev/null 2>&1 || true
ls .github/PULL_REQUEST_TEMPLATE.md .github/ISSUE_TEMPLATE .github/ISSUE_TEMPLATE.md 2>/dev/null || true
gh issue list --state open --limit 20
gh pr list --state open --limit 20
gh issue list --state all --search "KEYWORD" --limit 10
```

If a template exists, use it. Reuse an issue that already covers the work. Do not duplicate.

## 0a. When the standard GitHub flow is mandatory

Chores may skip an issue. These use cases **must not**:

| Use case | Why |
|---|---|
| User asked for an issue, a PR, or "GitHub flow" | Explicit |
| Bug with repro that should outlive the branch | Durable record |
| Feature that needs acceptance criteria | Reviewable contract |
| Work spanning (or likely to span) multiple PRs | Tracker + `Closes` per slice |
| Other humans will review; breaking, security, or public behavior | Collaboration |
| CI, install, or shared automation | Test plan on the PR |
| An issue already covers this work | Join it; `Closes #N` |

**Order:** issue → branch → PR with `Closes #N` → tick boxes (0b) → grep gate (section 5) → review → `gh pr checks` → merge.

If **none** of the rows match, skip the issue. Still label the PR. Honor linked checklists. Do not invent `Closes`. If unsure, ask once.

## 0b. Checklists — tick BEFORE merge

Scope: this PR's body **and** every issue the PR body names with `Closes` / `Fixes` / `Resolves` #N. State (open/closed) does not matter. After `gh pr merge` is too late.

```bash
gh issue view ISSUE_NUMBER --json title,body,comments
gh pr view PR_NUMBER --json title,body,comments
```

Every `- [ ]` or `* [ ]` in those **bodies** is a task. Comments are not GitHub task lists and are not merge blockers. Do the work. Fetch the body again. Flip that line to `- [x]` / `* [x]`. PATCH (do not rewrite the rest):

```bash
gh api --method PATCH "repos/${OWNER_REPO}/issues/NUMBER" -f body="${BODY}"
```

PRs are issues for this API. Prefer REST PATCH over `gh pr edit --body`.

Do not tick work you did not do.

## 1. Issue (only for section 0a)

Do **not** open an issue for ordinary PRs, one-file chores, or "so the PR has a number." When 0a matches, create or reuse the issue **before** the PR.

Type label — exactly one that exists in `gh label list`: `bug` | `enhancement` | `chore` | `documentation`. If absent, ask. Never `gh label create`.

```bash
gh issue create \
  --title "TITLE" \
  --label "enhancement" \
  --assignee "@me" \
  --body "$(cat <<'EOF'
## Context

WHY this exists.

## Goal

WHAT done looks like.

## Acceptance

- [ ] Criterion 1
- [ ] Criterion 2
EOF
)"
```

Acceptance boxes are real work — tick via 0b before merge.

This repo uses checklists, not sub-issues. Sub-issues only when splitting into independently mergeable PRs: `gh issue create --parent` if help lists it; else POST REST `sub_issue_id` as integer `.id` (not the issue number; `-f` 422s).

## 2. Pull request

When 0a matched: target the default branch and include `Closes #N`. No issue → omit `Closes`. Related-only: `Related to #N`.

```bash
gh pr create \
  --title "type(scope): summary" \
  --assignee "@me" \
  --label "enhancement" \
  --body "$(cat <<'EOF'
## Summary
- What changed and why.

## Test plan
- [ ] How a reviewer verifies this
EOF
)"
```

If an issue exists, add `Closes #N` to that body. Match the type label. `--label "automated"` only on bot/sync PRs, in addition to type.

REST fallback (`gh pr edit --add-assignee` can fail on `projectCards`). Login, not `@me`:

```bash
ME=$(gh api user --jq .login)
gh api --method POST "repos/${OWNER_REPO}/issues/PR_NUMBER/assignees" -f "assignees[]=${ME}"
gh api --method POST "repos/${OWNER_REPO}/issues/PR_NUMBER/labels" -f 'labels[]=enhancement'
```

## 3. Assign

Collaborators only. `--assignee "@me"` if the authenticated user is in that list. Two or more humans with `push`: ask.

```bash
gh issue edit ISSUE_NUMBER --add-assignee "@me"
```

## 4. Review

**Ask first** when the diff is large or touches more than a few files.

Small diffs: review without asking if the user already asked to ship/merge.

- [ ] One logical change
- [ ] Linked checklists ticked or still in progress (0b) — merge still waits on the grep gate
- [ ] Summary + Test plan; `Closes #N` only if an issue exists
- [ ] Type label + assignee
- [ ] No secrets
- [ ] `gh pr checks` will run, or the gap is stated

Other collaborators (not the author):

```bash
gh api --method POST "repos/${OWNER_REPO}/pulls/PR_NUMBER/requested_reviewers" -f 'reviewers[]=LOGIN'
```

Skip if CODEOWNERS already requested them. Never request the PR author. Never invent a login.

Solo (`mamahoos` personal repos):

```bash
gh pr review PR_NUMBER --comment --body "$(cat <<'EOF'
## Review
- Intent:
- Correctness:
- Security:
- Verdict: merge after checks / needs changes
EOF
)"
```

Do **not** `gh pr review --approve` on your own PR.

## 5. Merge — grep gate then merge

Tick first (0b). Then, on the **PR number and every `Closes`/`Fixes`/`Resolves` #N** in the PR body:

```bash
PR_NUMBER=N
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh pr checks "${PR_NUMBER}"

NUMBERS="${PR_NUMBER} $(gh pr view "${PR_NUMBER}" --json body --jq .body | command grep -oiE '(close[sd]?|fix(e[sd])?|resolve[sd]?) #[0-9]+' | command grep -oE '[0-9]+' | sort -u | tr '\n' ' ')"
for n in ${NUMBERS}; do
  if gh api "repos/${OWNER_REPO}/issues/${n}" --jq .body | command grep -E '^[[:space:]]*- \[ \]'; then
    echo "unchecked boxes in #${n} — tick before merge" >&2
    exit 1
  fi
done

gh api "repos/${OWNER_REPO}" --jq '{merge: .allow_merge_commit, squash: .allow_squash_merge, rebase: .allow_rebase_merge}'
gh pr merge "${PR_NUMBER}" --merge --delete-branch
```

`command grep` bypasses aliases (`grep -n` here). `if grep` is required: a non-match inside `if` does not abort; a match **does** `exit 1`. Do not `gh pr merge` until that loop prints nothing.

Do not `--admin` unless the user asks.

## Anti-patterns

- Opening an issue for every PR
- Skipping the standard flow when a 0a row matches
- Inventing labels, assignees, or reviewers
- `Closes #N` with no issue
- `gh pr merge` while `- [ ]` remains on the PR or a linked issue
- Ticking boxes after the issue/PR is already merged or closed
- `--approve` on a self-authored PR
- Reviewing a large/multi-file diff without asking
- Skipping this skill and guessing `gh` flags
