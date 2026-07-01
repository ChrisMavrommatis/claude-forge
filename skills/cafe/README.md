# cafe

A personal morning-brief skill for Claude Code. You've been away a few days and want to know the state of your projects before you start work.

One screen. Plain English. Read-only.

> **This skill is personal** — built around how the author starts the morning. It ships fully working, but anyone can adopt it and adapt it to their own setup. The barista (her name is Sofia) takes your order on first run; everything she asks about is configurable. See **Make it yours** at the bottom.

## Quick start

```bash
/cafe                # default brief, your saved sweetness
/cafe sketos         # terse, just the facts
/cafe glykos         # friendly tone, context per item
/cafe me-gala        # fullbody — more context per entry
/cafe glykos me-gala # sweet voice + fullbody
/cafe barista        # re-take your order, add/remove addons
```

Order it like a coffee. Pick one **sweetness** (`sketos / metrios / glykos`), add any **extras** (currently just `me-gala`). Any order.

On first run, the barista takes your order — your projects, your usual sweetness. Subsequent runs just brew the cup.

Full invocation in [SKILL.md](SKILL.md).

## What you get

| Section            | What's in it                                                          |
| ------------------ | --------------------------------------------------------------------- |
| 📰 Since you left  | Commits on `main` / active branches in your repos.                    |
| 📬 Your inbox      | PRs waiting on you + your own PRs with comments / red builds.         |
| 📋 Your queue      | Work items assigned to you.                                           |
| 🚧 Builds          | `main` and your-branch status — only when red.                        |
| 🌊 Drift           | Branch behind `main`, `.plans/*.md` whose referenced files have moved.|
| 🎯 Pick of the day | One thing to do next.                                                 |

Section vocabulary, voice, and pick-of-day priority all live in [`templates/brief.md`](templates/brief.md) — edit there to change what the brief looks like.

## Design principles

1. **One screen.** A short printout, not a dashboard.
2. **Presence-based.** Sections drop when they have nothing to show.
3. **Plain English.** Short, clear sentences.
4. **Read-only.** Never commits, pushes, comments, schedules.
5. **Quiet on failure.** ADO times out → git-only brief. No prompts unless required.
6. **Personalised.** The barista takes your order; the brief is for you.

## Addons

Each data source is a self-contained addon. Mix and match:

- **ado** — Azure DevOps PRs, work items, builds, iterations. Works with any registered ADO MCP server.
- **git** — local commits, branches, divergence, drift.
- **m365** — Microsoft 365 cloud email today; calendar / Teams / SharePoint queued under the same addon.

Off-by-default addons are omitted until you opt in via the barista — no half-state.

## File layout

```text
cafe/
├── SKILL.md           orchestration spec
├── barista.md         interview + tailoring nudges
├── AGENT.md           orientation for an agent reading this skill cold
├── addons/
│   ├── README.md      addon authoring guide
│   ├── ado.md         Azure DevOps
│   ├── git.md         local git
│   └── m365.md        Microsoft 365 cloud
├── templates/
│   ├── README.md      templates overview
│   ├── brief.md       brief layout, voice, pick priority
│   ├── profile.json   initial profile shape
│   ├── state.json     initial state shape
│   └── addon.md       authoring template for new addons
└── README.md          you are here
```

## Install

From the repo root, using the installer in [`bin/`](../../bin/README.md):

```bash
# Linux / Mac
bin/install.sh cafe

# Windows (PowerShell)
bin\install.ps1 cafe
```

Then `/cafe` from any Claude Code session. The barista does first-run setup.

After first run, the skill writes its profile and state to `~/.claude/skills/cafe/profile.json` and `~/.claude/skills/cafe/state.json` — inspect or back them up from there.

## Make it yours

This skill is shipped as a working personal config — the author's barista (Sofia) speaks with Greek vocatives, the coffee metaphor runs throughout, and the sweetness levels are `sketos / metrios / glykos`. None of that is required; it's just the voice. Edit freely.

The lowest-friction customizations:

- **Rename your barista.** Edit [`barista.md`](barista.md) — change the name in section 1 and her greeting. Drop the Greek vocatives if they're not for you.
- **Change the metaphor.** `sketos / metrios / glykos` are coffee sweetness. Rename them to whatever maps to your morning — `short / medium / long`, `quiet / normal / verbose`, etc. Edit [`SKILL.md`](SKILL.md) → "Sweetness — pick one" plus the matching transforms in [`templates/brief.md`](templates/brief.md).
- **Change brief sections, icons, or pick-of-day priority.** Edit [`templates/brief.md`](templates/brief.md) — section vocabulary, voice, and pick-of-day algorithm all live in that file.
- **Reshape the brief into something else entirely** (PM-style, support-style, sales-style, etc.). The skill ships with one brief shape; rewrite `templates/brief.md` and the section list in your fork to fit whatever your morning looks like.
- **Add an addon.** Copy [`templates/addon.md`](templates/addon.md) to `addons/<name>.md`, fill in the catalog, list its onboarding questions for the barista to ask. See [`addons/README.md`](addons/README.md) for the anatomy.

The two non-negotiable rules — **read-only** and **catalog-as-safe-list** — are documented in [SKILL.md](SKILL.md) and [AGENT.md](AGENT.md). Stay inside those and any change is safe.

## See also

- [AGENT.md](AGENT.md) — orientation for picking this skill up cold (an agent's mental model + design history).
- [SKILL.md](SKILL.md) — the orchestration spec (what runs when, how data flows).
- [barista.md](barista.md) — Sofia's interview + customization UI + tailoring-nudge patterns.
