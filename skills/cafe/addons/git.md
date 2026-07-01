# Addon — Git (local)

Connects the brief to local git repositories for commits, branch state, divergence, and (future) drift detection. Read-only — issues only inspection commands; never mutates working tree, ref state, or remote.

## Profile shape

Top-level `git` block in `profile.json`:

```json
{
  "git": {
    "repos": [
      { "name": "ShopCo", "path": "C:/work/shopco", "default_branch": "main" },
      { "name": "LoyaltyApp", "path": "/home/pavlos/code/loyalty", "default_branch": "main" }
    ]
  }
}
```

- `name` — display name in brief output (also the join key with the ADO addon's project name).
- `path` — absolute path to the local clone.
- `default_branch` — branch the addon compares HEAD against; typically `main` or `master`.

Operations run per-repo, in parallel across `git.repos[]`. The barista suggests entries by scanning common dev folders.

## Connection

The addon shells out to the local `git` CLI. No network calls — every operation runs against the local `.git/` directory. No `fetch`, `pull`, or `push`. No state-mutating commands (`commit`, `checkout`, `reset`, etc.) — see [SKILL.md](../SKILL.md) "Read-only" rule.

Throughout this catalog `git -C ${repo.path}` is implicit — each command runs in the configured repo's working tree.

**Cross-shell:** PowerShell and bash both work. The addon avoids Unix-only pipes (`grep`, `wc`, `awk`, `xargs`) inside the commands — output parsing happens in the orchestrator, not the shell.

## Catalog

The full set of read-only git operations this addon exposes. See [Defaults](#defaults) below for which entries come on automatically. The orchestrator may issue any catalog entry on demand.

**Cost grammar.** The summary table carries only the **size** (XS / S / M / L / XL) for at-a-glance triage. The full cost — `<size> · ~Xms · <scaling note>` — lives in each entry's detail block:
- **Size** — t-shirt class for the at-a-glance feel.
- **~Xms** — per-call wall-time estimate. Total brief cost is summed across active calls; must stay under `profile.preferences.budget_ms`.
- **Scaling note** — how the call grows with config (`per repo`, `per project`, `parallel`, etc.).

Placeholders:
- `${user.email}` — `profile.identity.git.email`
- `${state.last_run}` — from `state.json`
- `${repo.path}`, `${repo.default_branch}` — per `git.repos[]` entry

### Summary

| ID     | What it does                                                          | When it matters                                                              | Default | Size |
| ------ | --------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ------- | ---- |
| GIT.1  | Commits you authored on `main` since last brief                       | "What I shipped while I was away" recap                                      | ✅      | XS   |
| GIT.2  | Commits by anyone else on `main` since last brief                     | "What landed while I was out"                                                | ✅      | XS   |
| GIT.3  | Current branch name                                                   | Infrastructure — drives ADO.4's red-build check                              | ✅      | XS   |
| GIT.4  | Behind/ahead count vs `main` — only renders when behind > 0           | "main moved while I was away, I need to rebase"                              | ✅      | XS   |
| GIT.5  | Count of uncommitted files in working tree                            | "I left work mid-stream, files are dirty" reminder                           | ✅      | XS   |
| GIT.6  | Local branches with no commits in last 30 days                        | Branch hygiene — old branches to delete                                      | ⛔      | S    |
| GIT.7  | Commits on `main` since current branch's merge-base                   | "Your PR needs a rebase" — overlaps with GIT.4                               | ⛔      | S    |
| GIT.8  | Nearest git tag + commits since that tag                              | Release-cadence signal (useless on repos with no tags)                       | ⛔      | S    |
| GIT.9  | All commits on `main` in window (no author filter)                    | Vague team-velocity signal — overlaps with GIT.2                             | ⛔      | XS   |
| GIT.10 | Three most recent tags + commits since each                           | Release cadence (useless without tags)                                       | ⛔      | S    |
| GIT.11 | Drift detection (referenced files moved/renamed)                      | Backlog — undefined, no spec yet                                             | —       | —    |

### Details

#### GIT.1 — My commits since last brief

**Cost:** XS · ~50ms · per repo (parallel).

Commits authored by `${user.email}` on `${repo.default_branch}` since the last brief run.

```
git log ${repo.default_branch} --author=${user.email} --since="${state.last_run}" --no-merges --pretty=format:"%h|%s"
```

Empty render: *"No commits authored by you since you left."*

#### GIT.2 — New commits on main since I left (excl. mine)

**Cost:** XS · ~50ms · per repo (parallel).

Commits on `${repo.default_branch}` since `${state.last_run}` by anyone except `${user.email}` — "what landed while you were away".

Note: `git log` has no native author-negation filter (`--not` is a revision-range operator and doesn't invert `--author`). Fetch all commits with author email in the format string, then drop matches in the orchestrator.

```
git log ${repo.default_branch} --since="${state.last_run}" --no-merges --pretty=format:"%h|%ae|%an|%s"
# orchestrator filters: skip commits where %ae == ${user.email}
```

Empty render: *"No new commits on ${repo.default_branch}."*

#### GIT.3 — Current branch name

**Cost:** XS · ~30ms · per repo (parallel).

Name of the currently checked-out branch. Drives `${current_branch}` for ADO ADO.4 (red-build check).

```
git branch --show-current
```

Empty result: detached HEAD (orchestrator surfaces a warning under the repo's section).

#### GIT.4 — Rebase signal vs main

**Cost:** XS · ~50ms · per repo (parallel).

Behind / ahead counts from `${repo.default_branch}` to current HEAD. The orchestrator uses **the behind count only** for rendering — that's the actionable signal ("`main` moved while you were away, you'll need a rebase"). The ahead count is dropped at render time.

```
git rev-list --left-right --count ${repo.default_branch}...HEAD
```

Output format: `<behind>\t<ahead>`. **Render gate**: hidden when `behind == 0`, regardless of ahead. When `behind > 0`, the brief surfaces this under 🌊 Drift as a rebase prompt — see [`templates/brief.md`](../templates/brief.md) → Drift section.

#### GIT.5 — Uncommitted file count

**Cost:** XS · ~50ms · per repo (parallel).

Working-tree changes (modified, deleted, untracked). Orchestrator counts lines.

```
git status --porcelain
```

Renders as a one-line reminder under the repo's 📰 Since you left section (or the header when single-repo) — see [`templates/brief.md`](../templates/brief.md) → Uncommitted work. Empty render: hidden when 0.

`me-gala` fullbody: list up to the first three changed paths after the count (the porcelain output already carries them). Beyond three, append `+N more`.

#### GIT.6 — Stale local branches (>30 days)

**Cost:** S · ~150ms · per repo. Returns all branches; orchestrator filters by date.

Local branches with no commits in the last 30 days, excluding `${repo.default_branch}`.

```
git for-each-ref --sort=committerdate --format="%(refname:short)|%(committerdate:iso8601)" refs/heads
```

Empty render: hidden when none qualify.

#### GIT.7 — Rebase needed (commits on main since branch point)

**Cost:** S · ~150ms · per repo (two sequential calls: merge-base then count).

How many commits are on `${repo.default_branch}` since the current branch diverged. Hints "your PR may need a rebase".

```
git merge-base HEAD ${repo.default_branch}
# then with the resulting SHA:
git rev-list --count <merge_base>..${repo.default_branch}
```

Empty render: hidden when 0.

#### GIT.8 — Distance from latest tag

**Cost:** S · ~200ms · per repo (two sequential calls).

Nearest reachable tag from HEAD, plus commit count since that tag. Useful as `me-gala` expansion for release-flavored work.

`--always` is omitted deliberately — when no tags exist, `git describe --tags --abbrev=0` exits with `fatal: No names found, cannot describe anything`, which the orchestrator catches and renders empty. With `--always`, git would silently fall back to a SHA, and the rev-list count would then be meaningless.

```
git describe --tags --abbrev=0
# then with the resulting tag (skip the rev-list call if the describe failed):
git rev-list --count <tag>..HEAD
```

Empty render: *"No tags found."*

#### GIT.9 — Recent commits from team (no author filter)

**Cost:** XS · ~50ms · per repo. Opt-in.

All commits on `${repo.default_branch}` in the brief window, no author filter — vague velocity signal.

```
git log ${repo.default_branch} --since="${state.last_run}" --no-merges --pretty=format:"%h|%an|%s"
```

Empty render: hidden.

#### GIT.10 — Recent tags + commits since each

**Cost:** S · ~150ms + ~50ms × top-3 tags · per repo.

The three most recent tags (by version sort) plus how many commits since each — release cadence signal.

```
git tag --sort=-version:refname
# orchestrator takes top 3, then per tag:
git rev-list --count <tag>..HEAD
```

Empty render: *"No tags found."*

#### GIT.11 — Drift detection (undefined — backlog)

**Cost:** — (status: undefined).

Currently undefined — spec pending. Once defined, drift will likely take a list of "referenced files" (backticked paths and markdown links from `.plans/` and wiki) and return which moved / renamed / deleted since `${state.last_run}`. Out of scope for v1.

```
# placeholder — see backlog
```

## Defaults

When this addon is enabled, these catalog calls come on automatically. Toggle individual calls via `/cafe barista calls`.

| ID     | Call                                          | Why default                                                |
| ------ | --------------------------------------------- | ---------------------------------------------------------- |
| GIT.1  | My commits since last brief                   | Quick recap of own shipped work.                           |
| GIT.2  | New commits on main since I left (excl. mine) | What landed while you were away.                           |
| GIT.3  | Current branch name                           | Drives ADO ADO.4 (red-build check) and Builds section.     |
| GIT.4  | Rebase signal vs main                         | "main moved while you were away" — renders only when behind > 0. |
| GIT.5  | Uncommitted file count                        | "I left work mid-stream" — cheap (~50ms), catches the most common Monday surprise. Hidden when 0. |

**Enabled in a fresh profile:** yes — a barista interview seeds a `git` block by default.

**Notable opt-ins:** GIT.6 (stale branches), GIT.7 (rebase needed), GIT.8 (tag distance), GIT.9 / GIT.10 (team commits / tags).

## Failure mode

The addon degrades gracefully per-repo, never aborting the brief:

- **Not a git repo** at `${repo.path}` → drop the repo, header note: `⚠ Git: ${repo.name} at ${repo.path} is not a git repository.`
- **Path doesn't exist** → drop the repo, header note: `⚠ Git: ${repo.name} path missing.`
- **No commits in window** → empty render per query (see each catalog entry).
- **Detached HEAD** → GIT.3 returns empty; orchestrator surfaces a one-line warning under the repo's section.
- **Bare repo** → drop with `⚠ Git: ${repo.name} is bare (no working tree).`

Per [SKILL.md](../SKILL.md), failures must be visible in the brief header — never silent.

## Barista onboarding

The barista's git questions:

1. *"Which repos do you work in?"* — suggests entries by scanning common dev folders (Windows: `C:\Projects\`, `D:\Projects\`; macOS/Linux: `~/Projects/`, one level deep). User picks; the barista records `{ name, path, default_branch }` per pick. `default_branch` is detected via `git -C <path> symbolic-ref refs/remotes/origin/HEAD` (falls back to asking).
2. *"Any extra repos to add manually?"* — free-form path input. The barista validates with `git -C <path> rev-parse --is-inside-work-tree` before saving.
