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

| Use case | Why the full flow |
|---|---|
| User asked for an issue, a PR, or "GitHub flow" | Explicit |
| Bug with repro that should outlive the branch | Durable record |
| Feature that needs acceptance criteria | Reviewable contract |
| Work spanning (or likely to span) multiple PRs | Tracker + `Closes` per slice |
| Other humans will review; breaking, security, or public behavior | Collaboration |
| CI, install, or shared automation | Test plan on the PR |
| An **open** issue already covers this work | Join it; do not fork a parallel thread |

**Full flow (in order):**

1. Reuse or create the issue (section 1). Acceptance boxes are real work.
2. Branch. Implement.
3. Open the PR targeting the default branch with `Closes #N`, type label, `--assignee "@me"`.
4. Read issue + PR bodies. Do `- [ ]`. Tick `- [x]` (section 0b).
5. Review: ask first if the diff is large or > a few files; then comment review (solo) or request a collaborator.
6. `gh pr checks` green → merge. Linked issue closes via the keyword.

If **none** of the rows match, skip the issue. Still use a labeled PR, honor any existing open checklists, and do not invent `Closes`.

When unsure whether a row matches, ask once. Do not silently skip a matching use case.

## 0b. Checklists (do not skip)

Open issue and PR **bodies are part of the work**. Agents forget this. Read them twice: once before coding, once before merge.

```bash
gh issue view ISSUE_NUMBER --json title,body,comments
gh pr view PR_NUMBER --json title,body,comments
```

Treat every `- [ ]` in those bodies (and in comments) as a task:

1. Do the work the box describes.
2. Fetch the current body again (it may have changed).
3. Flip that line to `- [x]`. Do not rewrite the rest of the body.
4. Write it back.

```bash
# After editing BODY locally with the box ticked:
gh api --method PATCH "repos/${OWNER_REPO}/issues/NUMBER" -f body="${BODY}"
```

PRs are issues for this API. Prefer REST PATCH over `gh pr edit --body` (GraphQL `projectCards` can fail).

Do **not** tick a box you did not complete. Do **not** merge, close, or report done while required `- [ ]` remain. Test-plan boxes on the PR count.

## 1. Issue (only for section 0a use cases)

Do **not** open an issue for ordinary PRs, one-file chores, copy tweaks, or "so the PR has a number."

When section 0a matches, the issue is **required**. Create it (or reuse the open one) before the PR. That is the standard GitHub flow, not optional polish.

Type label — pick **exactly one** that exists in `gh label list`:

| Work | Label |
|---|---|
| Broken behavior | `bug` |
| New capability | `enhancement` |
| Maintenance, config, deps | `chore` |
| Docs-only | `documentation` |

If that label is absent, stop and ask. Never `gh label create`.

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

Capture the number from the printed URL. Those Acceptance boxes are real work — tick them when done (section 0b).

Parent/sub-issue: use only when one tracking issue splits into **independently mergeable** PRs (not a checklist inside a single PR). This repo historically used checklists, not sub-issues.

If `gh issue create --help | grep -q -- --parent`:

```bash
gh issue create --title "TITLE" --body "BODY" --label "enhancement" --assignee "@me" --parent PARENT_NUMBER
```

Else (gh < 2.94, including 2.46):

```bash
CHILD_URL=$(gh issue create --title "TITLE" --body "BODY" --label "enhancement" --assignee "@me")
CHILD_NUM=${CHILD_URL##*/}
CHILD_ID=$(gh api "repos/${OWNER_REPO}/issues/${CHILD_NUM}" --jq .id)
printf '{"sub_issue_id":%s}\n' "${CHILD_ID}" | gh api --method POST "repos/${OWNER_REPO}/issues/PARENT_NUMBER/sub_issues" --input -
```

`--input` is required: `-f sub_issue_id=` sends a string and 422s. `sub_issue_id` is the REST integer `.id`, not the issue number.

## 2. Pull request

When section 0a matched, the PR **must** include `Closes #N` and target the **default branch**. If there is no issue, omit `Closes`. Related work that should not close: `Related to #N`.

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

If an issue exists, add a `Closes #N` line to that body. Match the type label. Add `--label "automated"` only for bot/sync PRs, **in addition** to the type label.

If create cannot take a flag, patch via REST. `gh pr edit --add-assignee` can fail on GraphQL `projectCards`. REST wants a login, not `@me`:

```bash
ME=$(gh api user --jq .login)
gh api --method POST "repos/${OWNER_REPO}/issues/PR_NUMBER/assignees" -f "assignees[]=${ME}"
gh api --method POST "repos/${OWNER_REPO}/issues/PR_NUMBER/labels" -f 'labels[]=enhancement'
```

## 3. Assign

Collaborators only. Prefer `--assignee "@me"` when the authenticated user is in that list. If two or more humans have `push`, ask who owns it.

```bash
gh issue edit ISSUE_NUMBER --add-assignee "@me"
```

## 4. Review

**Ask first** when the diff is large or touches more than a few files: do not post a GitHub review until the user says yes.

Small, focused diffs: review without asking if the user already asked to ship/merge.

Before requesting or posting a review:

- [ ] Diff is one logical change
- [ ] Open issue/PR checklists are ticked or still in progress (section 0b)
- [ ] Body has Summary and Test plan; `Closes #N` only if an issue exists
- [ ] Type label + assignee set
- [ ] No secrets in the diff
- [ ] `gh pr checks` will have something real to run, or the gap is stated

**Other collaborators exist** (and are not the author):

```bash
gh api --method POST "repos/${OWNER_REPO}/pulls/PR_NUMBER/requested_reviewers" -f 'reviewers[]=LOGIN'
```

Skip `--reviewer` if CODEOWNERS already requested them. Never request the PR author. Never invent a login unless they appear in collaborators.

**Solo** (typical for `mamahoos` personal repos):

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

Do **not** `gh pr review --approve` on your own PR. GitHub rejects self-approval.

## 5. Merge

```bash
gh pr checks PR_NUMBER
gh issue view ISSUE_NUMBER --json body
gh pr view PR_NUMBER --json body
gh api "repos/${OWNER_REPO}" --jq '{merge: .allow_merge_commit, squash: .allow_squash_merge, rebase: .allow_rebase_merge}'
```

Wait until required checks pass **and** required `- [ ]` boxes on the PR (and linked issue) are `- [x]`. Match recent merge style; in `mamahoos/dot-files` that is merge commits:

```bash
gh pr merge PR_NUMBER --merge --delete-branch
```

Do not `--admin` or skip checks unless the user explicitly asks.

## Anti-patterns

- Opening an issue for every PR
- Skipping the standard flow (issue → `Closes #N` → checklists → review → merge) when a section 0a use case matches
- Inventing `priority/*`, `type/*`, `area/*` when those labels do not exist
- Putting `Closes #N` when no issue exists
- Merging with unchecked `- [ ]` still in the issue or PR body
- `--approve` on a self-authored PR
- `--reviewer` of a non-collaborator
- Posting a GitHub review on a large/multi-file diff without asking
- `gh label create` to make the taxonomy you wish you had
- Skipping this skill and guessing `gh` flags from memory
