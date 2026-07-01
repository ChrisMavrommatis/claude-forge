# Addon — ADO (Azure DevOps)

Connects the brief to Azure DevOps for PRs, work items, builds, iterations, releases.

## Profile shape

Top-level `ado` block in `profile.json`:

```json
{
  "ado": {
    "org": "example",
    "projects": [
      { "name": "ShopCo", "repos": ["ShopCo"] },
      { "name": "LoyaltyApp", "repos": ["LoyaltyApp"] }
    ]
  }
}
```

- `org` — single ADO organisation. Multi-org not supported (one org per profile).
- `projects[].name` — display name used in brief output (also the join key when the same project also appears in another addon).
- `projects[].repos[]` — ADO repo names used for PR / commit / build queries.

## Connection

The addon requires an Azure DevOps MCP server registered in the Claude session — Microsoft's official ADO MCP, a vendor-flavored variant, or any other server exposing the same tool names. The catalog refers to tools by their bare names (`wit_my_work_items`, `repo_list_pull_requests_by_repo_or_project`, etc.); Claude Code resolves these through whichever ADO MCP is installed. If no ADO MCP is registered, the addon is offline — see Failure mode below.

Throughout this catalog the MCP namespace prefix is implied — only the bare tool name appears. The orchestrator picks whichever ADO MCP exposes the catalog's tool names.

## Catalog

The full set of read-only calls this addon exposes. See [Defaults](#defaults) below for which entries come on automatically. The orchestrator may issue any catalog entry on demand; anything not in the default set requires explicit opt-in via the barista.

**Cost grammar.** The summary table carries only the **size** (XS / S / M / L / XL) for at-a-glance triage. The full cost — `<size> · ~Xms · <scaling note>` — lives in each entry's detail block:
- **Size** — t-shirt class for the at-a-glance feel.
- **~Xms** — per-call wall-time estimate. Total brief cost is summed across active calls; must stay under `profile.preferences.budget_ms`.
- **Scaling note** — how the call grows with config (`per repo`, `per project`, `parallel`, etc.).

Placeholders:
- `${currentUser}` — `profile.identity.ado.email` (fallback `profile.identity.git.email`)
- `${project}`, `${repo}` — iterated from `profile.ado.projects[]`
- `${state.last_run}` — from `state.json`
- `${iterationId}` — resolved via ADO.11 from `profile.ado.projects[].iterations[]`
- `${current_branch}` — resolved via git addon GIT.3 when available

### Summary

| ID     | What it does                                                              | When it matters                                                              | Default | Size |
| ------ | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ------- | ---- |
| ADO.1  | PRs assigned to you for review, that you haven't voted on                 | Someone is blocked waiting for your approval                                 | ✅      | XS   |
| ADO.2  | Your own PRs that have new unresolved comments                            | A reviewer replied; it's your turn to act                                    | ✅      | M    |
| ADO.3  | Work items assigned to you, in active states                              | Your to-do list across all projects                                          | ✅      | XS   |
| ADO.4  | Latest build on `main` and your current branch — only renders when red    | "I broke main" / "my branch is failing CI"                                   | ✅      | S    |
| ADO.5  | Recent commits on `main` via the ADO API                                  | Only useful for repos you don't have cloned locally                          | ⛔      | S    |
| ADO.6  | Work items closed since your last brief                                   | "What shipped while I was out"                                               | ⛔      | S    |
| ADO.7  | Items you own in the current iteration (sprint)                           | Sprint focus list — what you committed to this round                         | ⛔      | S    |
| ADO.8  | All items in the current iteration (full team)                            | Sprint-health view — who's swamped, what's drifting                          | ⛔      | S    |
| ADO.9  | In-progress items with no activity in 5+ days                             | "Stale tickets — kick them or close them"                                    | ⛔      | S    |
| ADO.10 | Items with cross-team dependency links                                    | "Blocked by other teams" surface                                             | ⛔      | S    |
| ADO.11 | Current + next iteration metadata                                         | Infrastructure — required to resolve `iterationId` for ADO.7/ADO.8           | ⛔      | XS   |
| ADO.12 | ADO connectivity / auth healthcheck                                       | Required — failure must be visible                                           | ✅      | XS   |
| ADO.13 | Vote state + reviewer list for a specific PR                              | `me-gala` expansion for ADO.1/ADO.2 — "you've got 1/3 approvals"             | ⛔      | M    |
| ADO.14 | PR thread comments that @-mention you                                     | "Someone tagged me in a PR discussion I'm not on"                            | ⛔      | L    |
| ADO.15 | Open items with DueDate in the next 7 days                                | "What's due this week" — only useful if your team sets due dates             | ⛔      | S    |
| ADO.16 | Recent build/release runs across the project                              | "What deployed lately"                                                       | ⛔      | L    |
| ADO.17 | Open security alerts (advsec — dependency, code-scan, secrets)            | Security posture — only useful when Advanced Security is enabled             | ⛔      | S    |
| ADO.18 | Wiki pages changed in window                                              | Drift signal (note: underlying tool can't filter by date today)              | ⛔      | L    |
| ADO.19 | Red builds on any active branch across the project (team weather)         | A lead's view — "is anything broken anywhere, not just my branch"           | ⛔      | L    |
| ADO.20 | PRs open > 7 days with no assigned reviewer (team weather)                 | "PRs going stale with nobody looking" — team throughput signal              | ⛔      | L    |

### Details

#### ADO.1 — PRs awaiting my review

**Cost:** XS · ~200ms · per repo (parallel across `profile.ado.projects[].repos[]`).

Open PRs where `${currentUser}` is on the reviewer list and has not yet voted.

```
repo_list_pull_requests_by_repo_or_project(
  project=${project},
  repositoryId=${repo},
  user_is_reviewer=${currentUser},
  status=Active
)
```

Empty render: *"No reviews waiting."*

#### ADO.2 — My PRs with new comments

**Cost:** M · ~600ms · two-phase: list (~400ms) + per-PR thread fetch (~150ms × ~5 PRs typical).

My open PRs that have unresolved comment threads.

```
repo_list_pull_requests_by_repo_or_project(
  project=${project},
  repositoryId=${repo},
  created_by_user=${currentUser},
  status=Active
)
# then per PR returned:
repo_list_pull_request_threads(project=${project}, repositoryId=${repo}, pullRequestId=<id>)
```

Empty render: *"Your PRs are clear."*

#### ADO.3 — Work items assigned to me

**Cost:** XS · ~200ms · per project (parallel).

Work items assigned to `${currentUser}` in active states (Active / In Progress / To Do / New). One call per project — the tool prompts/hangs without an explicit `project`.

```
wit_my_work_items(project=${project}, type="assignedtome")
# returns IDs only — if titles are needed, follow with
# wit_get_work_items_batch_by_ids(ids=[...], project=${project})
```

Empty render: *"Nothing in your queue."*

#### ADO.4 — Red builds on main / current branch

**Cost:** S · ~250ms × 2 branches · per repo (parallel); only renders when red.

Latest build status on `main` and on the user's current branch. Hidden when green. Tool note: `pipelines_get_build_status` requires a known `buildId` and can't answer "latest on branch" — `pipelines_get_builds` filtered by `branchName` is the right shape. The orchestrator may need a prior `repo_get_repo_by_name_or_id` to translate the repo name to a GUID if `repositoryId` is not accepted by name on this server.

```
pipelines_get_builds(
  project=${project},
  repositoryId=${repo},
  repositoryType="TfsGit",
  branchName="refs/heads/main",
  top=1,
  queryOrder="QueueTimeDescending"
)
pipelines_get_builds(
  project=${project},
  repositoryId=${repo},
  repositoryType="TfsGit",
  branchName="refs/heads/${current_branch}",
  top=1,
  queryOrder="QueueTimeDescending"
)
# orchestrator reads `result` from the most recent build; red ⇒ render
```

Empty render: hidden (all green).

#### ADO.5 — Recent commits on main (ADO API)

**Cost:** S · ~400ms · per repo (parallel). Useful only for repos without a local clone (otherwise redundant with git GIT.2).

Commits authored on `main` in the brief window.

```
repo_search_commits(
  project=${project},
  repository=${repo},
  version="main",
  fromDate=${state.last_run}
)
# fromDate prefers ISO 8601 (YYYY-MM-DDTHH:MM:SSZ); YYYY-MM-DD also accepted.
```

Empty render: *"No new commits on main since you left."*


#### ADO.6 — Items closed since I left

**Cost:** S · ~500ms · per project (WIQL).

Work items closed within the brief window — "what shipped without me".

```
wit_query_by_wiql(query="
  SELECT [System.Id], [System.Title]
  FROM workitems
  WHERE [System.TeamProject] = '${project}'
    AND [System.State] = 'Closed'
    AND [Microsoft.VSTS.Common.ClosedDate] >= '${state.last_run}'
")
```

Empty render: *"Nothing shipped since you left."*

#### ADO.7 — Items in current iteration (mine)

**Cost:** S · ~400ms · per iteration in `profile.ado.projects[].iterations[]`.

Items the user owns in the current iteration. Tool has no `assignedTo` parameter — orchestrator filters client-side from the returned `fields["System.AssignedTo"].uniqueName`.

```
wit_get_work_items_for_iteration(
  project=${project},
  team=<team>,
  iterationId=${iterationId}
)
# orchestrator filters: fields["System.AssignedTo"].uniqueName == ${currentUser}
```

Empty render: *"Sprint clear — nothing assigned to you this round."*

#### ADO.8 — Items in current iteration (full team)

**Cost:** L · ~1.5s · per iteration. Response is large (tens of KB per populated iteration) — token cost can be substantial.

All items in the current iteration. Team view for sprint health.

```
wit_get_work_items_for_iteration(project=${project}, team=<team>, iterationId=${iterationId})
# The tool returns full work-item shells — no `top` or `fields` knob.
# For populated iterations the response can exceed 80KB. Consider replacing with a WIQL projection
# (SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo]
#  FROM workitems WHERE [System.IterationId] = ${iterationId})
# if cost matters more than full fidelity.
```

Empty render: *"Iteration is empty."*

#### ADO.9 — Stalled items

**Cost:** S · ~500ms · per project (WIQL).

In-progress items with no activity in 5+ days.

```
wit_query_by_wiql(query="
  SELECT [System.Id], [System.Title], [System.AssignedTo]
  FROM workitems
  WHERE [System.TeamProject] = '${project}'
    AND [System.State] = 'In Progress'
    AND [System.ChangedDate] < @today - 5
")
```

Empty render: *"No stalled items."*

#### ADO.10 — Items with cross-team dependencies

**Cost:** S · ~500ms · per project (WIQL, link-relation filter).

Items with cross-team dependency links (`depends on` / `is blocked by`).

```
wit_query_by_wiql(query="
  SELECT [System.Id], [System.Title]
  FROM workitemLinks
  WHERE ([Source].[System.TeamProject] = '${project}')
    AND ([System.Links.LinkType] = 'System.LinkTypes.Dependency-Forward'
         OR [System.Links.LinkType] = 'System.LinkTypes.Dependency-Reverse')
  MODE (MustContain)
")
# Link reference names depend on the org's process template — these are the
# canonical Agile/Scrum names. Tune per profile if the template differs.
```

Empty render: *"No cross-team blockers."*

#### ADO.11 — Iteration list (current + next)

**Cost:** XS · ~200ms · once per team.

Current and next iteration metadata — required to resolve `${iterationId}` for ADO.7 / ADO.8. `team` is required — without it the tool prompts interactively. If `attributes.startDate` / `attributes.finishDate` are null on the iteration, current/next semantics can't be derived — treat as "no scheduled iteration" and skip ADO.7/ADO.8.

```
work_list_team_iterations(project=${project}, team=<team>, timeframe="current")
# "next" is not a valid timeframe on this server. To compute the next iteration,
# omit `timeframe` and pick the iteration whose attributes.startDate is closest
# after today:
work_list_team_iterations(project=${project}, team=<team>)
# orchestrator picks the one with min(startDate) where startDate > today.
```

Empty render: *"No active iteration."*

#### ADO.12 — ADO connectivity healthcheck

**Cost:** XS · ~150ms · one call at brief start (always-on infra).

Lightweight ping to confirm the ADO MCP is reachable. Drives the visible "ADO offline" header when it fails.

```
core_list_projects(top=1)
```

Failure render: header note `⚠ ADO offline — couldn't reach ${profile.ado.org}.`

#### ADO.13 — PR vote state + reviewers

**Cost:** M · ~200ms × N_PRs returned by ADO.1 or ADO.2.

Vote state + reviewer list for a known PR. Useful as `me-gala` expansion on ADO.1 / ADO.2 entries.

```
repo_get_pull_request_by_id(project=${project}, repositoryId=${repo}, pullRequestId=<id>)
# Response includes `reviewers[]` with vote codes:
#   10 = approved, 5 = approved-with-suggestions, 0 = no-vote,
#   -5 = waiting, -10 = rejected.
# Note: "required reviewer" status is NOT in this response — it lives in branch
# policy data and requires a separate call (out of scope for this entry).
```

Empty render: n/a (always returns the PR).

#### ADO.14 — @-mentions in PR threads

**Cost:** L · ~1.5s · scans every thread comment across active PRs.

PR comments that @-mention `${currentUser}` (not just comments on the user's own PRs). Chains off ADO.2 phase-2 (`repo_list_pull_request_threads`) — three sequential calls per PR (list PRs → list threads → per-thread comments).

```
# Depends on ADO.2's phase-2 output (PR ids + thread ids).
# Per active PR + per thread:
repo_list_pull_request_thread_comments(
  project=${project},
  repositoryId=${repo},
  pullRequestId=<id>,
  threadId=<id>
)
# orchestrator filters comment content for @${currentUser}
```

Empty render: *"No PR mentions."*

#### ADO.15 — Items due this week

**Cost:** S · ~500ms · per project (WIQL).

Open items with `DueDate` within the next 7 days.

```
wit_query_by_wiql(query="
  SELECT [System.Id], [System.Title], [Microsoft.VSTS.Scheduling.DueDate]
  FROM workitems
  WHERE [System.TeamProject] = '${project}'
    AND [Microsoft.VSTS.Scheduling.DueDate] <= @today + 7
    AND [System.State] <> 'Closed'
")
```

Empty render: *"Nothing due this week."*

#### ADO.16 — Recent release pipeline runs

**Cost:** L · ~1s · paginated per project; release pipelines often produce many runs.

Recent build/release runs across the project — feeds "Recent shipped" if your fork has it.

```
pipelines_get_builds(
  project=${project},
  minTime=${state.last_run},
  queryOrder="QueueTimeDescending",
  top=10
)
# Orchestrator filters by `definition.name` matching a release pattern,
# or by a `release_pipeline_ids[]` list maintained in the profile.
# `pipelines_list_runs` exists but is per-pipeline only and has no top/fromDate —
# this entry needs the cross-project build feed.
```

Empty render: *"No recent releases."*

#### ADO.17 — Security alerts (advsec)

**Cost:** S · ~400ms · per repo.

Open security alerts on a repo (dependency, code-scan, secret).

```
advsec_get_alerts(
  project=${project},
  repository=${repo},
  states=["Active"],
  confidenceLevels=["High", "Other"]
)
# Tool errors hard ("VS2150009: Advanced Security is not enabled...") when the
# feature is off on the repo — orchestrator treats that error as "no alerts"
# rather than a brief-killing failure.
```

Empty render: *"No open security alerts."*

#### ADO.18 — Wiki page changes (drift signal)

**Cost:** L · ~1s list + ~300ms × N_pages, plus a prior wiki-discovery call. Drift filter NOT implementable on this MCP today (see note below).

Wiki pages in the project — candidate input for drift detection once that's defined. **Note:** `wiki_list_pages` returns `{path, id}` only — no `lastUpdatedDate` — so the "per page changed in window" filter is unimplementable on this MCP as-is. A workable drift signal would be `repo_search_commits` against the wiki's underlying git repo with `fromDate=${state.last_run}`, then map commit paths back to wiki pages. Out of scope for v1.

```
# Prerequisite — resolve wikiIdentifier:
wiki_list_wikis(project=${project})
# Then list pages:
wiki_list_pages(project=${project}, wikiIdentifier=<wikiId>)
# Then fetch each page (or each changed page once drift is wired):
wiki_get_page(project=${project}, wikiIdentifier=<wikiId>, path=<path>)
```

Empty render: *"No wiki changes."*

#### ADO.19 — Red builds on any active branch (team weather)

**Cost:** L · fan-out: 1 definition list + ~1 call per pipeline · per project. Team-weather tier — opt-in and budget-warned. Build objects are large (~6KB each); scope per definition and keep `top` small to bound payload.

Latest build per active branch across the project, surfacing any that are red — not just `main` and the user's current branch (ADO.4 already covers those two). Turns the personal brief into a lead's morning sweep: "is anything broken anywhere?"

```
# One unscoped top=N call is dominated by the busiest pipeline and silently
# misses other repos/branches — so scope per pipeline definition instead.
pipelines_get_build_definitions(project=${project})     # list pipeline definition ids
# then, per definition:
pipelines_get_builds(
  project=${project},
  definitions=${definitionId},
  queryOrder="QueueTimeDescending",
  top=10
)
# Orchestrator: per definition, group by `sourceBranch` (e.g. "refs/heads/main"),
# keep the most recent build per branch, and render branches whose latest `result`
# is red. `result` is a NUMERIC enum (2=Succeeded, 4=PartiallySucceeded, 8=Failed,
# 32=Canceled) — red = 8; don't confuse it with the separate numeric `status` field.
# Cap the rendered list at ~5; beyond that, an overflow line ("…and N more red branches").
```

Empty render: *"No red builds across the project."*

#### ADO.20 — Aged PRs with no reviewer (team weather)

**Cost:** L · list ~600ms per repo + one detail call per aged PR (fan-out) · Team-weather tier — opt-in and budget-warned. Only PRs older than 7 days need the detail call, which bounds the fan-out.

Active PRs opened more than 7 days ago that have no reviewer assigned — PRs going stale with nobody looking. A team-throughput signal for a lead, not a personal to-do.

```
# Step 1 — list active PRs and keep the aged ones. The list response carries
# creationDate / createdBy / title but NOT reviewers[], so reviewer filtering
# cannot happen here.
repo_list_pull_requests_by_repo_or_project(
  project=${project},
  repositoryId=${repo},
  status=Active
)
# keep PRs whose creationDate is older than 7 days.
# Step 2 — per aged candidate, fetch reviewers (only present on the detail call):
repo_get_pull_request_by_id(
  project=${project},
  repositoryId=${repo},
  pullRequestId=${prId}
)
# keep PRs where reviewers[] is empty, or contains only the author (compare each
# reviewer's id / uniqueName against createdBy.id / uniqueName). Sort oldest-first.
```

Empty render: *"No stale unreviewed PRs."*

## Defaults

When this addon is enabled, these catalog calls come on automatically. Toggle individual calls via `/cafe barista calls`.

| ID     | Call                                     | Why default                                                  |
| ------ | ---------------------------------------- | ------------------------------------------------------------ |
| ADO.1  | PRs awaiting my review                   | Someone's blocked on me — unblock first.                     |
| ADO.2  | My PRs with new comments                 | A stale review blocks the merge. Moderate cost, worth it.    |
| ADO.3  | Work items assigned to me                | What I'm supposed to be doing today.                         |
| ADO.4  | Red builds on main / current branch      | Unblock self before anything else.                           |
| ADO.12 | ADO connectivity healthcheck             | Failure must be visible. Always on.                          |

**Enabled in a fresh profile:** yes — a barista interview seeds an `ado` block by default.

**Notable opt-ins:** ADO.5 (recent commits on main via ADO — redundant with git GIT.2 for cloned repos), ADO.6 (items closed since I left), ADO.13 (PR approval count), ADO.14 (PR @-mentions — heavy), ADO.17 (security alerts), ADO.18 (wiki drift).

**Team-weather tier (opt-in, budget-warned):** ADO.19 (red builds on any active branch) and ADO.20 (aged PRs with no reviewer) turn the personal brief into a lead's morning sweep across the whole project. Both are higher-cost, so they stay opt-in and the barista warns at add-time if enabling them pushes the predicted brief over `budget_ms` — same gate as the other heavy calls. Enable via `barista calls`.

## Failure mode

If the MCP namespace is absent or the org is unreachable, render git-only sections and add a one-line note in the brief header:

```text
⚠ ADO offline — couldn't reach `example`. Inbox and queue may be incomplete.
```

Never silent. See SKILL.md "Visible failure modes" rule.

## Barista onboarding

The barista's ADO questions:

1. *"Your ADO organisation?"* — suggests `example` if it can read git remotes.
2. *"Which ADO projects are you on?"* — suggests from ADO membership; user picks.
3. *"Which repos under each project do you commit to?"* — suggests from git remotes seen on disk.
