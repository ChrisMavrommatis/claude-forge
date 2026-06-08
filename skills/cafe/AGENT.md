# cafe — agent brief

Read this first if you're picking up this skill cold. It orients you to what this is, how it works, what was decided and why, and where to look for what.

## What this skill is for

A morning brief for your projects. The user types `/cafe` and gets a one-screen markdown brief tailored to their projects. The brief is personalised (identity, projects, addons), uses icons and a consistent voice plus tailoring nudges, and is read-only.

The skill orders like a coffee:
- **Sweetness** — pick one. `sketos / metrios / glykos`. Same data, three voices.
- **Extras** — add any. `me-gala` (with milk) = fullbody. Same brief, richer per entry.

## Mental model

- **The orchestrator** is the Claude agent running this skill — it lazy-loads profile/state, gathers data via the addons configured in the profile, renders via the output template, applies sweetness + extras, updates state.
- **The barista** is a sub-flow in [`barista.md`](barista.md). She runs *instead of* a brief on first run (no profile yet) or when info is missing. She also appends *one line* to the bottom of a finished brief when she's noticed a pattern worth surfacing.
- **The skill is prompt-based.** No compiled code. The markdown content IS the implementation. `SKILL.md` is the always-loaded core; `templates/brief.md`, `addons/<name>.md`, and `barista.md` lazy-load only when they're needed.
- **Two files on disk for the user.** `~/.claude/skills/cafe/profile.json` is config (rare writes — barista creates and updates). `~/.claude/skills/cafe/state.json` is runtime (every brief writes to it).

## Where to look for what

| I want to change                                | Edit                                                  |
| ----------------------------------------------- | ----------------------------------------------------- |
| Invocation / sweetness / extras                 | `SKILL.md` → How to invoke                            |
| Execution flow                                  | `SKILL.md` → How it works                             |
| Brief sections / section icons / voice          | `templates/brief.md` (section icons + voice)     |
| Pick-of-day priority                            | `templates/brief.md` → Pick of the day priority  |
| Brief layout                                    | `templates/brief.md`                             |
| Sweetness transformations (sketos / glykos)     | `templates/brief.md` → Sweetness transforms      |
| `me-gala` (fullbody) expansion                  | `templates/brief.md` → me-gala                   |
| Profile shape (top-level + addons)              | `templates/profile.json` + `addons/<name>.md`         |
| State shape                                     | `templates/state.json`                                |
| How an addon queries its source                 | `addons/<name>.md` → Catalog                          |
| Which catalog calls are default-on for an addon | `addons/<name>.md` → Defaults                         |
| An addon's failure mode                         | `addons/<name>.md` → Failure mode                     |
| Barista interview flow                          | `barista.md` → First-time interview                   |
| Tailoring nudges (patterns + rate limit)        | `barista.md` → Tailoring nudges                       |
| Adding a new addon                              | `addons/README.md` (anatomy) + copy `templates/addon.md` |

## Profile + state semantics

The JSON templates give you the shape; these are the rules that aren't visible from the shape alone.

### profile.json (v3)

- **`version`** — schema marker. Currently **3** (v2 → v3 dropped the `role` field when roles were collapsed; the barista quietly migrates v2 profiles by stripping `role` and bumping the version).
- **`identity`** — `git` is mandatory; per-addon identity follows the addon (e.g. `identity.ado` present only when the `ado` addon is enabled). Display name + email both captured because ADO matches against either. **Addressing fields** are top-level peers, not system identifiers: `identity.preferred_name` (how the brief addresses you — header, greeting, nudges; falls back to first token of `git.name`) and `identity.vocative` (optional Greek vocative form like `Πάβλο` — `null` when not set; Sofia only uses it when explicit).
- **`preferences.sweetness`** — default if no positional is passed.
- **`preferences.default_extras`** — `["me-gala"]` if the user wants fullbody always on, else `[]`.
- **`preferences.budget_ms`** — soft cap on total brief wall-time (default 5000). Sum of enabled-call ms estimates must stay under this. Barista warns at add-time; brief header warns at predicted overrun.
- **Each addon is a top-level block** (`ado`, `git`, `m365`, future ones). **Block present = addon enabled. Block absent = addon off.** Adding a new addon to a user = creating a new top-level block in their profile. See [`addons/`](addons/) for one catalog file per addon.
- **`<addon>.enabled_calls[]`** — array of catalog IDs (e.g. `["ADO.1", "ADO.2", "ADO.12"]`) currently active for this user within that addon. Seeded from each addon's "Defaults" section (in `addons/<name>.md`) during barista onboarding; **profile is authoritative thereafter** — addon files are NOT consulted for defaults at brief render time. User toggles via `/cafe barista`.
- **`ado.projects[]`** — carries `{ name, repos: [...] }` per project.
- **Off-by-default addons** (`m365`) are omitted entirely until the user opts in via the barista. No "configured but disabled" half-state.

### state.json

- **`last_run`** — drives the "since you left" window. Updated at the end of every successful brief.
- **`streak`** — increment if today is yesterday + 1 workday. Reset to 1 if a workday was skipped. No nag.
- **`last_pick`** — yesterday's pick + a machine-checkable description for "did you do it?". Used at the top of the next brief.
- **`lifetime`** — counters for round-number celebrations (anniversaries).
- **`detected_patterns`** — candidate tailoring nudges. Each entry: `kind`, `evidence`, `asked` (bool). `asked: true` once raised so we don't ask twice.
- **`barista_notes.nudges_today`** — rate-limit. Max one nudge per brief. Resets daily.

## Design history — the big calls

- **Single-axis order model.** Earlier drafts had two positionals (`mode` and `sweetness`) with three modes (`quick / full / deep`). Collapsed into one axis — sweetness positional only — plus opt-in extras (currently just `me-gala`). Simpler to learn, easier to render consistently.
- **Sweetness + extras are independent.** Sweetness is *voice* (how the brief talks). Extras are *content* (more or less per entry). They compose freely. `glykos me-gala` = sweet voice with fullbody detail.
- **`me-gala` is fullbody, not an extra section.** Earlier draft had `me-gala` add an Environment section (Hangfire / ES / K8s). Dropped — `me-gala` changes how much detail each entry carries, it does not add a new section. Now `me-gala` just expands each entry with reviewers, age, last comment, etc. No new sections.
- **Roles collapsed (2026-06-04).** The skill was originally two-role (`dev` and `pm`) when it lived as a shared team tool. After it became a personal skill, roles were retired entirely — there's one brief, and anyone forking who wants a different shape edits `templates/brief.md` and the addon defaults directly. Addon defaults themselves moved inline at the same time — they used to live in per-role tables, now each `addons/<name>.md` declares its own in a Defaults section. Less abstraction, fewer indirections.
- **Profile + state are two files.** Profile is config — written by the barista, mostly read. State is runtime — written every brief (streak, last_pick, detected_patterns). Different update cadence, cleaner concerns.
- **Lazy-load profile.** Missing profile → barista takes over and produces no brief that run. No "skip onboarding" escape. This forces real onboarding before personalisation can degrade silently.
- **Short first interview.** Aim for four questions or fewer. Anything else lives in later tailoring nudges. Long forms reduce adoption; the barista finishes in under a minute.
- **One nudge per brief.** The barista may append *one* tailoring line at the bottom. Never interrupts mid-brief. Rate-limited via `state.barista_notes.nudges_today`. No nag.
- **The barista handles personalisation setup.** She replaces three earlier sketches (a config wizard, a silent identity-matching heuristic, and a "your area" filter). One conversation, not three guesses.
- **Names everywhere are fake.** Pavlos Stratos, Eleni, Yorgos, ShopCo, LoyaltyApp, Example Corp. The skill repo may end up public; never check in real client or teammate data.
- **No flags.** `--since`, `--section`, `--user` and friends were dropped during the rebuild. Will come back once the core is stable.

## What's complete

- Three locked rules — engaging output, sweetness + extras, personalised.
- Single-axis order: `sketos / metrios / glykos` + optional `me-gala`.
- Barista flow — first-time interview, tailoring nudges with rate limit, schema-version migration.
- Profile + state schema, with initial templates.
- Output template — section structure, sweetness transforms, me-gala expansion.
- Markdown + emoji output design (no fixed widths).

## Deliberately out of scope

- **"Fair" sweetness** (ask each morning). Conflicts with the no-follow-up-prompt rule. Type `/cafe sketos` for a one-off if needed.
- **Flags.** Coming back once the core is stable.
- **Multi-org per profile.** One ADO org for now.
- **Wrike** — investigated; see `.plans/wrike-discovery.md` for findings. Dropped from the shipped skill until a workable install path is locked in.
- **Auto-posting to ADO / channels.** Read-only.
- **Anniversary celebrations beyond a one-line footer note.** Nothing more than that one line.

## Common edits — how to extend

- **Change brief sections, icons, or pick-of-day priority.** Edit `templates/brief.md` — that file owns the section vocabulary, the voice rules, and the pick-of-day algorithm in one place.
- **Change a sweetness voice.** Edit the "Sweetness transformations" section near the bottom of `templates/brief.md` (sketos / glykos rules — metrios is the baseline layout above).
- **Add a tailoring nudge pattern.** Edit `barista.md` → Tailoring nudges → "Patterns she watches for". Each entry needs `kind`, `evidence` description, and the line the barista says.
- **Add a new extra (beyond `me-gala`).** Update `SKILL.md` → Extras list, add an expansion rule in `templates/brief.md`, and let the barista offer it during onboarding ("any extras you usually take?").
- **Change identity matching logic.** Edit the barista's first-question handling in `barista.md`. There's no separate identity matcher — the barista is the only place identity is resolved.

## Pitfalls / don'ts

- **Don't reference `.plans/cafe-development.md` from skill files.** The dev-journal file is gitignored and won't ship with the skill. The plan references skill files (one-way). Never the reverse. (References to `.plans/*.md` as a *brief input* — the drift signal — are fine; those are the user's own plans, not ours.)
- **Don't use real names in examples.** Pavlos Stratos, Eleni, Yorgos, ShopCo, LoyaltyApp, Example Corp. The repo may be public.
- **Don't make the brief interrupt.** No follow-up prompts after the brief renders. The barista nudge is an appended line, not a question that blocks.
- **Don't bloat first-run interview.** Keep it under four questions. New questions go to tailoring nudges instead.
- **Don't ask twice.** When a barista nudge gets `y` or `n`, mark `asked: true`. Only `later` keeps the entry open for another week.
- **Don't surface "fair" mode** — it's been removed. Sweetness is always one of three.
- **Don't bypass the lazy-load rule.** Missing profile means the barista runs. No "render a generic brief" fallback.
- **Don't quietly degrade.** Every degraded state (ADO down, plugin missing, profile incomplete) should produce a visible note in the header. A silent empty brief looks like a bug, not a clean result.
- **Don't auto-edit code from the skill.** Read-only is a hard constraint.
- **Don't add a section without a section icon.** Icons are part of the brief's identity, not decoration.
- **Don't improvise off-catalog calls.** The orchestrator and barista must only use MCP tools / git commands listed in `addons/<name>.md` catalogs. They're curated read-only and cost-annotated. Need a new capability? Add it to the catalog first (with cost), then call it. Same rule for the barista when offering opt-ins.
- **Don't ignore the brief budget.** Every catalog entry carries a per-call ms estimate; the active set's total must fit under `profile.preferences.budget_ms`. Adding entries silently is what makes briefs slow.
- **Don't infer a vocative form.** `identity.vocative` is opt-in only via the address-flair question. `null` means plain English — Sofia must not Greek-ify `git.name` on her own (`"Chris"` → `"Χρήστο"` is ambiguous, gendered, and not the user's call to make). Greeting uses `preferred_name` plain, or `Καλημέρα!` with no name when not yet captured.
