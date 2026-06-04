# Output template

The literal structure to render for the morning brief. Read this when assembling the markdown.

Slots are written as `{{slot}}`. They're filled at render time. Omit the entire section if it has nothing to show (presence-based).

## Section icons

📰 Since you left · 📬 Your inbox · 📋 Your queue · 🚧 Builds · 🌊 Drift · 🎯 Pick of the day

## Voice

PR numbers, file paths, branch names, work item IDs. Technical is fine — the reader writes code.

## Pick of the day priority

The pick-of-day algorithm walks this list, first hit wins:

1. Red build on your branch — unblock yourself.
2. Unresolved comment on your PR — quick reply, unblocks merge.
3. PR awaiting your review with no other reviewers — someone's blocked on you.
4. Work item marked in-progress with no recent activity — pick back up.
5. Highest-priority work item with no in-progress alternative — start fresh.
6. Nothing pressing — *"Nothing's on fire. Pick something from the queue when you're ready."*

## Worked sample — the scenario

Pavlos Stratos is a dev on **ShopCo** and **LoyaltyApp**. It's Tuesday, 26 May 2026. He last committed Friday afternoon — three days off the keyboard.

Underlying data:

- **Since you left.** Eleni merged PR #1234 "fix giftcard stock alignment" yesterday. Yorgos pushed 4 commits to `features/checkout-rewrite`, last commit two hours ago.
- **Your inbox.** PR #1240 "Add gift wrapping option" (Eleni, 6 files, opened 2 days ago) awaiting Pavlos's review. PR #1238 "Giftcard validation update" (Pavlos's own) has one unresolved comment from Yorgos on `src/giftcards/stock-step.ts:42`, posted four hours ago.
- **Your queue.** #5678 "Giftcard purchase flow" — in progress, due Wednesday. #5681 "Survey addon deferred" — to do. #5689 "Checkout regression #4" — bug, to do.
- **Builds.** `main` red since this morning — `checkout.test.giftcardStockAlignsWithCartTotal` failing. Last passing commit: `c8f1a2e`.
- **Drift.** `.plans/giftcards-stock-rewrite.md` references five files that have moved since the plan was last touched.
- **State.** 5-day streak. Yesterday's pick was *"reply to Yorgos on PR #1238"* — not yet done (the comment is still unresolved).

The brief that gets rendered, four ways:

### metrios (default)

```markdown
> # ☕ Morning Brief · Pavlos · ShopCo · LoyaltyApp
> Tuesday, 26 May 2026 · 5-day streak

⛈ Red build on `main` since this morning

## 📰 Since you left

- ✅ Eleni merged "fix giftcard stock alignment" (**PR #1234**)
- 🔧 Yorgos pushed 4 commits to `features/checkout-rewrite`

## 📬 Your inbox · 2

- 🟡 **PR #1240** "Add gift wrapping option" — awaiting your review
- 🔴 **PR #1238** "Giftcard validation update" (yours) — 1 unresolved comment

## 📋 Your queue · 3

- 🔥 **#5678** "Giftcard purchase flow" — in progress · due Wed
- 📌 **#5681** "Survey addon deferred" — to do
- 🐛 **#5689** "Checkout regression #4" — bug

## 🚧 Builds

- 🔴 `main` — red since this morning · last passing: `c8f1a2e`

## 🌊 Drift

- ⚠️ `.plans/giftcards-stock-rewrite.md` — 5 referenced files moved

## 🎯 Pick of the day

Reply to Yorgos on **PR #1238** — small thread, blocks merge.

🔥 5-day streak · ⛈ red build on `main`
```

### sketos

Same data, terse voice. Drops the date subtitle, drops the weather line at the top (still in footer), collapses entries to `icon ref — state`.

```markdown
> # ☕ Morning Brief · ShopCo · LoyaltyApp

## 📰 Since you left

- ✅ PR #1234 — Eleni
- 🔧 4 commits — Yorgos · `features/checkout-rewrite`

## 📬 Inbox · 2

- 🟡 PR #1240 — awaiting review
- 🔴 PR #1238 — 1 unresolved comment

## 📋 Queue · 3

- 🔥 #5678 — due Wed
- 📌 #5681
- 🐛 #5689

## 🚧 Builds

- 🔴 `main` — red since this morning

## 🌊 Drift

- ⚠️ `giftcards-stock-rewrite.md` — 5 refs moved

## 🎯 Pick

PR #1238 — reply to Yorgos.

🔥 5-day streak
```

### glykos

Friendly tone, full sentences. Greeting on top. Entries get a *why* clause.

```markdown
Καλημέρα, Pavlo ☕

> # ☕ Morning Brief · Pavlos · ShopCo · LoyaltyApp
> Tuesday, 26 May 2026 · 5-day streak

⛈ Red build on `main` since this morning — checkout regression suite is failing

## 📰 Since you left

- ✅ Eleni merged "fix giftcard stock alignment" (**PR #1234**) — Eleni's been on this for a few days, good to see it land.
- 🔧 Yorgos pushed 4 commits to `features/checkout-rewrite`
  - The big one rewrites `checkout-service.ts`, which you touched last week. Worth a look before it merges.

## 📬 Your inbox · 2

- 🟡 **PR #1240** "Add gift wrapping option" — Eleni opened this two days ago, she's waiting on you. Six files, looks small.
- 🔴 **PR #1238** "Giftcard validation update" (yours) — Yorgos left a comment on `src/giftcards/stock-step.ts:42` four hours ago. Otherwise looks ready to merge.

## 📋 Your queue · 3

- 🔥 **#5678** "Giftcard purchase flow" — in progress, due Wednesday. Four linked PRs.
- 📌 **#5681** "Survey addon deferred" — to do, no due date.
- 🐛 **#5689** "Checkout regression #4" — bug, to do.

## 🚧 Builds

- 🔴 `main` has been red since this morning — last passing commit was `c8f1a2e` (Eleni, yesterday at 5pm).

## 🌊 Drift

- ⚠️ `.plans/giftcards-stock-rewrite.md` — five of the referenced files have moved since you last touched the plan. Worth a re-read before you resume.

## 🎯 Pick of the day

Reply to Yorgos on **PR #1238** first — it's a small thread on `GiftcardStockStep.cs:42` and one comment away from green. Then jump on Eleni's review on **PR #1240**; she's been waiting two days and it looks like a quick read.

🔥 5-day streak · ⛈ red build on `main`
```

### metrios + me-gala (fullbody)

Same metrios voice, but each entry picks up a sub-line with the extra context.

```markdown
> # ☕ Morning Brief · Pavlos · ShopCo · LoyaltyApp
> Tuesday, 26 May 2026 · 5-day streak

⛈ Red build on `main` since this morning

## 📰 Since you left

- ✅ Eleni merged "fix giftcard stock alignment" (**PR #1234**)
  - ShopCo · 12 files · merged yesterday at 4:18pm
- 🔧 Yorgos pushed 4 commits to `features/checkout-rewrite`
  - ShopCo · last commit 2h ago · 28 lines changed

## 📬 Your inbox · 2

- 🟡 **PR #1240** "Add gift wrapping option" — awaiting your review
  - 6 files · opened 2 days ago · reviewers: Pavlos (you), Eleni · no comments yet
- 🔴 **PR #1238** "Giftcard validation update" (yours) — 1 unresolved comment
  - Yorgos · 4h ago · `src/giftcards/stock-step.ts:42` · linked work item #5678

## 📋 Your queue · 3

- 🔥 **#5678** "Giftcard purchase flow" — in progress · due Wed
  - 4 linked PRs · last activity 4h ago · parent epic: ShopCo Giftcards FY26
- 📌 **#5681** "Survey addon deferred" — to do
  - Created 2 weeks ago · no due date · linked to feature #5142
- 🐛 **#5689** "Checkout regression #4" — bug
  - Reported by QA yesterday · severity 2 · linked PR #1238

## 🚧 Builds

- 🔴 `main` — red since this morning · last passing: `c8f1a2e` (Eleni, yesterday 5pm)
  - Failure: `checkout.test.giftcardStockAlignsWithCartTotal`

## 🌊 Drift

- ⚠️ `.plans/giftcards-stock-rewrite.md` — 5 referenced files moved since last touched
  - Moved: `GiftcardStockService.cs` → `Services/`, plus 4 others under `Pipelines/`

## 🎯 Pick of the day

Reply to Yorgos on **PR #1238** — small thread, blocks merge.

🔥 5-day streak · ⛈ red build on `main`
```

---

## Header

```markdown
> # ☕ Morning Brief · {{preferred_name}} · {{project_label}}
> {{day_of_week}}, {{date}} · {{streak_phrase}}
```

- `{{preferred_name}}` — from `profile.identity.preferred_name`. Falls back to the first token of `profile.identity.git.name`. Omit the ` · {{preferred_name}}` segment if neither is set (rare — barista always asks).
- `{{project_label}}` — the user's profile.projects names joined by ` · ` when multi-project. With one project, just that name.
- `{{streak_phrase}}` — derived from `state.streak` and `state.last_run`:
  - `state.streak == 1` (or first ever run today) → `first brew`
  - `state.streak >= 2` → `{{N}}-day streak`
  - `state.streak == 0` with `state.last_run` set (gap occurred) → `back after {{days_since_last_run}} days`
- If a streak or weather line is present (see Footer), the eye still lands on the heading first.

## Yesterday's pick check (optional, top of brief)

If `state.last_pick.completion_check` returned true on this run, prepend one line below the header:

```markdown
✓ Yesterday's pick: done — {{last_pick_summary}}
```

Otherwise omit.

## Project weather (optional, top of brief)

One line below header. Compute from gathered data — red builds count, aged-PR count, overdue items.

```markdown
{{weather_emoji}} {{weather_phrase}}
```

- `☀` — clear (no red builds, no aged items).
- `🌤` — attention soon (aged PRs > 7 days or one overdue item).
- `⛈` — red builds on `main`, or multiple overdue items.

## 📰 Since you left

```markdown
## 📰 Since you left

- {{status_icon}} {{author}} {{verb}} "{{title}}" (**{{ref}}**)
  - {{context_line}}
```

Status icons:
- `✅` — merged PR.
- `🔧` — branch pushes / code activity.
- `🔴` — red build event.

Sort order: most recent first. Cap at 5 entries. If more, append the overflow line:

```markdown
- _…and {{N}} more{{ — overflow_summary}}_
```

`{{overflow_summary}}` is a one-clause characterization of the hidden items (e.g. "all bugs, all New", "all due this week", "all by Eleni"). If nothing characteristic stands out, drop the trailing clause and keep the bare `…and N more`.

## 📬 Your inbox · {{count}}

```markdown
## 📬 Your inbox · {{count}}

- {{status_icon}} **{{ref}}** "{{title}}" — {{state_summary}}
```

Status icons:
- `🟡` — waiting on you (review requested, no other reviewers).
- `🔴` — blocking you (your PR with unresolved comment or red build).

Sort order: oldest first (oldest = most urgent). Cap at 5. If more, append the same `…and N more` line.

## 📋 Your queue · {{count}}

```markdown
## 📋 Your queue · {{count}}

- {{status_icon}} **{{ref}}** "{{title}}" — {{state_summary}}
```

Status icons:
- `🔥` — in progress.
- `🐛` — bug, regardless of state.
- `📌` — to-do.

Sort: in-progress → to-do → new, then by due date. Cap at 5.

## 🚧 Builds

Hidden when everything is green. Render only if `main` is red OR your current branch is red.

```markdown
## 🚧 Builds

- 🔴 `{{branch}}` — red since {{when}} · last passing: {{last_passing_ref}}
```

## 🌊 Drift

Render when at least one drift signal is present. **"Drift" = something has slipped out of sync** — same icon, two flavours of signal share the section.

### Rebase signal (from GIT.4)

Render only when `behind > 0` on the current branch — i.e. `main` moved while you were away. Drop the raw "ahead" count entirely; that's biography, not news. Hidden when `behind == 0`.

```markdown
- ⚠️ `{{current_branch}}` needs a rebase — `{{default_branch}}` moved {{N}} commits while you were away
```

### `.plans/` references moved (from GIT.11, when defined)

Render when one or more `.plans/*.md` files reference paths that have been renamed, moved, or deleted since the plan was last touched.

```markdown
- ⚠️ `{{plan_path}}` — {{drift_summary}}
```

If both flavours fire, list rebase signals first (they're more time-sensitive) then `.plans/` drift below.

## 🎯 Pick of the day

Always renders. One paragraph. No inline icons in the paragraph (the 🎯 in the heading is enough).

```markdown
## 🎯 Pick of the day

{{pick_paragraph}}
```

When nothing's pressing:

```markdown
## 🎯 Pick of the day

Nothing's on fire. Pick something from the queue when you're ready.
```

## Footer

A short line at the very end. Always renders when at least one signal is present (streak ≥ 1, weather, anniversary, addon status).

```markdown
🔥 {{streak_phrase}} · {{addon_status_line}}{{anniversary_appendix}}
```

### Streak segment

- `state.streak == 1` → `first brew`
- `state.streak >= 2` → `{{N}}-day streak`
- Otherwise → omit the `🔥 …` segment entirely.

### Addon status segment

One badge per **enabled** addon (top-level block present in profile) — never list disabled addons. Each badge reads `<name> <icon>[ <short_note>]`:

| Icon | Meaning                                                              | When                                                          |
| ---- | -------------------------------------------------------------------- | ------------------------------------------------------------- |
| ✓    | Healthy — addon's healthcheck call (e.g. ADO.12, M365.6) returned ok. | Default for a clean run.                                |
| ⚠    | Degraded — partial render. Healthcheck ok but a query failed.        | Append a 1–3-word note after the icon, e.g. `git ⚠ slow`.     |
| ✗    | Offline — healthcheck failed. The addon contributed nothing.         | Append a 1–3-word note, e.g. `m365 ✗ auth needed`.            |

Example combinations:

```markdown
🔥 first brew · ado ✓ · git ✓

🔥 4-day streak · ado ✓ · git ✓ · m365 ✗ auth needed

🔥 12-day streak · ado ⚠ partial · git ✓
```

Addon order matches the profile's enabled-addon order: `ado, git, m365`. One-line cap — if you'd exceed ~120 chars wrap to a second line for the addon-status segment only.

### Barista nudge (separate line)

If a barista nudge is queued (state.detected_patterns has an unasked one and `nudges_today` < 1), append on its own line below the footer:

```markdown
💭 *{{barista_nudge_text}} (y / n / later)*
```

---

## Sweetness transformations

The structure above is the **metrios** layout. Apply these transforms for the other voices.

### metrios (default — explicit rules)

- Header subtitle uses `{{streak_phrase}}` as defined above.
- Entries are plain: `icon · ref · title · state_summary`. No editorial commentary, no rationale per entry.
- **Exception — Pick of the day**: one to two short sentences. The pick itself plus a tight rationale ("blocks merge" / "due today"). Multi-sentence reasoning is okay here *only*; everywhere else in metrios stays terse.

### sketos (no sugar)

- Drop the date subtitle in the header (keep title only).
- Drop the project weather line.
- Bullet entries collapse to: `- {{status_icon}} {{ref}} — {{state_summary}}` (drop title quotes; trim verbs).
- "Pick of the day" stays one short sentence, drop the "blocks merge" / "small thread" descriptors.
- Footer keeps streak only — drop weather.

### glykos (sweet)

- Keep all metrios elements.
- Each entry gets a context tail — *who, when, why it matters in one short clause*. Sub-line `- {{context_line}}` becomes a full sentence under the entry.
- "Pick of the day" paragraph adds *why this first* in plain words.
- Optional opening greeting before the header: `Καλημέρα, {{preferred_name}} ☕` (one line).

## me-gala (fullbody) transformation

Applies regardless of sweetness. For each entry in Inbox, Queue, Since you left:

- Append a sub-line with the extra context — reviewers waiting, age in days, last comment with file:line, linked work item, file refs.

```markdown
- 🟡 **PR #1240** "Add gift wrapping option" — awaiting your review
  - 6 files · opened 2 days ago · reviewers: Eleni, Yorgos · last comment 4h ago on `Checkout/CartView.cshtml:42`
```

No new sections. Same skeleton, fuller per entry.
