---
name: cafe
description: Morning brief for your projects, the way you order your coffee — sketos, metrios, glykos, optionally me-gala. Personalised by a barista who takes your order on first run. Read-only. Examples — `/cafe`, `/cafe sketos`, `/cafe glykos me-gala`, `/cafe barista`.
---

# cafe — the morning brief

You sit down with a coffee. You've been away a few days. What do you need to know before you start typing?

That's what this prints. One screen. Plain English. No dashboards, no jargon.

## When to use

- First thing in the morning, or after a long weekend / time off.
- When you switch back to a project after working on another.
- When someone asks "what's the state of things?" and you want a quick answer.

## When NOT to use

- Mid-task. The brief is for orientation, not interruption.
- For a thorough status report or deep dive — this is a glance, not an audit.
- For unfamiliar code — use a code-exploration tool, not this.

## How to invoke

```
/cafe [sweetness] [extras...]
/cafe barista
```

Order it like a coffee. Pick one sweetness, add any extras. Any order. Or call `barista` to re-take your order.

### Sweetness — pick one (how your day gets told back to you)

- `sketos` — no sugar. Terse, just the facts.
- `metrios` (default) — medium. Plain sentences.
- `glykos` — sweet. Friendly tone, a bit of context per item.

Default sweetness comes from your `profile.preferences.sweetness`. Positional always wins for one run.

### Extras — add any

- `me-gala` — with milk (με γάλα). **Fullbody.** Same sections, more context per entry — reviewers, age, last comment, linked items. The sections don't change; what's inside them gets fuller.

(Room to grow — future extras drop in without changing the sweetness axis.)

## How it works

The skill is **personal**. The brief you get depends on:

- Your **profile** — identity, projects, addon configuration.
- Your **state** — streak, last pick, lifetime counts.

If there's no profile yet, the barista takes your order before anything else. See [barista.md](barista.md).

### Execution

1. **Lazy-load profile.** Read `~/.claude/skills/cafe/profile.json`. If missing → run the barista (see [barista.md](barista.md)), then continue.
2. **Lazy-load state.** Read `~/.claude/skills/cafe/state.json`. If missing → create from `templates/state.json`.
3. **Sanity check.** If profile is missing a required field (e.g. no `projects`), invoke the barista to fill the gap, then continue.
4. **Resolve order.** Read positional args. Sweetness from arg or `profile.preferences.sweetness`. Extras from arg + `profile.preferences.default_extras`.
5. **Pick the window.** The "since you left" window starts at `state.last_run`, or 72 hours ago if no state.
6. **Gather data in parallel.** For each addon block present in the profile, issue its `enabled_calls[]` (catalog IDs from `addons/<name>.md`) in parallel. Skip addons whose blocks are absent — those are off for this user. Profile is the runtime source of truth.
7. **Compose pick of the day.** Walk the priority list in [`templates/brief.md`](templates/brief.md) → "Pick of the day priority", first hit wins.
8. **Render.** Use `templates/brief.md` for the literal structure. Apply sweetness voice transform. Apply `me-gala` per-entry expansion if it's in the extras.
9. **Check for tailoring nudges.** If `state.detected_patterns` has an unasked entry and `state.barista_notes.nudges_today < 1`, append one line at the bottom (see [barista.md](barista.md)).
10. **Update state.** Bump streak, record this run's pick, refresh `last_run`, update lifetime counters, advance any detected-pattern timers.

## Files

```text
cafe/
├── SKILL.md                core spec — always loaded
├── barista.md              the barista's interview + tailoring flow
├── AGENT.md                orientation for an agent reading this skill cold
├── addons/
│   ├── README.md           addon authoring guide
│   ├── ado.md              ADO addon — PRs, work items, builds, iterations
│   ├── git.md              local git — commits, branches, divergence
│   └── m365.md             Microsoft 365 cloud — email live (calendar/Teams/SharePoint queued)
├── templates/
│   ├── README.md           templates overview
│   ├── addon.md            authoring template for new addons
│   ├── brief.md            brief layout — section structure, slots, rules, pick priority
│   ├── profile.json        initial profile shape (barista creates from this)
│   └── state.json          initial state shape (created on first run)
├── README.md               human-facing intro
└── .skillignore            dev-facing files to leave out of installs
```

Read addon and output files **only when needed** — when the configured addon matches their filename. Keeps SKILL.md cheap on every run.

## What it does NOT do

- It does not commit, push, or open PRs. Read-only.
- It does not summarise code changes line-by-line.
- It does not page anyone. Surfaces, never alerts.
- It does not nag. The barista limits herself to one nudge per brief.
- It does not interrupt. Tailoring nudges are appended *after* the brief renders.

## Constraints

- **Parallel reads.** Git, ADO, file system all run in parallel.
- **Quiet failures.** If ADO times out, render the git-only sections. Don't abort.
- **No follow-up prompt** after the brief itself. The barista's nudge is one-line and answerable later.
- **Profile is lazy-loaded** — read only when the skill is about to brew. Missing profile → barista takes over before any brief renders.
- **Profile and state are separate files.** Profile = config (rare writes). State = runtime (every run).
- **Catalog is the safe-list.** Only invoke MCP tools / git commands listed in `addons/<name>.md` catalogs. The catalogs are curated for read-only safety and carry cost annotations — never improvise off-catalog calls. Adding a capability means adding a catalog entry (with cost) first, then calling it.
- **Brief budget.** Sum of catalog-entry cost estimates for the active-addon × default-on set must stay under `profile.preferences.budget_ms` (default 5000ms). The barista warns before exceeding it at add-time; the brief header warns at predicted overrun.

## Example runs

- `/cafe` — default brief in your saved sweetness.
- `/cafe sketos` — one-off terse run.
- `/cafe glykos me-gala` — sweet voice, fullbody.
- `/cafe barista` — re-take your order.

## See also

- [barista.md](barista.md) — the onboarding interview + tailoring nudge flow.
- [templates/brief.md](templates/brief.md) — brief layout, section icons, voice, pick-of-day priority.
- [templates/profile.json](templates/profile.json) — initial profile shape.
- [templates/state.json](templates/state.json) — initial state shape.
