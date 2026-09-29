---
description: Opens or updates the pull request for a verified ticket branch following the repo's PR conventions, replies to review comments on rework, sets the ticket Ready for Review and performs the hand-off to the reviewer as configured (poll or cowork-trigger). Use as the last step of a coder run.
---

# Pull request and hand-off

## Conventions

Take the PR template from `.github/PULL_REQUEST_TEMPLATE.md` when the repo has one and fill it; otherwise use the body below. In both cases the body must contain `Closes <ticket ref>` and end with the marker line `agent-workflow: v1`; the reviewer only touches PRs with that marker.

Title: `<ticket-id>: <ticket title>`.

```markdown
Closes <ticket ref>

## What
<3 to 6 lines: the change from the user's point of view>

## Acceptance criteria
- [x] <criterion> (verified by <test | command>)

## Test evidence
<the evidence table from verify-acceptance>

## Guidance applied
<repo files and best-practice skills followed, by name; rules you consciously deviated from and why>

## Notes for reviewer
<trade-offs, things you were unsure about, follow-ups deliberately left out>

agent-workflow: v1
```

## New PR

1. `git push -u origin <branch>`.
2. Open the PR against `DEFAULT_BRANCH` (`gh pr create` for GitHub; the tracker's PR integration otherwise). Not a draft.
3. If the repo has CI, wait for the first run to start so the reviewer can see it; do not wait for it to finish.
4. `transition` the ticket to Ready for Review, `comment` "[agentic-coding/coder] PR opened: <url>".

## Rework

1. Push the new commits to the same branch. Never force-push.
2. Reply to every review comment: what you changed and the commit, or why you did not change it. Resolve the threads you addressed; leave the others open.
3. Update the PR body's acceptance criteria and evidence sections if they changed.
4. `transition` the ticket to Ready for Review, `comment` "[agentic-coding/coder] Rework pushed, round <n>: <url>".

## Hand-off

Read `HANDOFF` from configuration:

- `poll`: nothing more to do. The reviewer's next scheduled run finds the ticket in Ready for Review.
- `cowork-trigger`: fire the scheduled task named `REVIEWER_TASK` with the text `REVIEW <ticket-id> <pr-url>`. If firing fails, comment that on the ticket; the poll fallback still applies.

Then end the run with the five-line summary.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Draft PR "to be safe" | Reviewer skips drafts, ticket stalls | Open it ready; verification already happened |
| Squashing rework commits into the original | Reviewer cannot see what changed since last round | Append commits |
| Replying "done" without the commit | Reviewer has to diff manually | Name the commit per comment |
| Omitting the marker | PR is invisible to the reviewer | Always end the body with `agent-workflow: v1` |

## Checklist

- [ ] Title and body follow the repo template or the default, marker present
- [ ] Branch pushed without force
- [ ] Every review comment answered on rework
- [ ] Ticket set Ready for Review with the PR link
- [ ] Hand-off performed per `HANDOFF`
