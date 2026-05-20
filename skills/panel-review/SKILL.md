---
name: panel-review
description: Multi-persona review of a change — Dev, Tech Lead, QA, PM, Client by default, plus optional security / devops / junior. Surfaces issues caught by 2+ personas as the strongest signal. Read-only. Examples — `/panel-review`, `/panel-review range:main..HEAD`, `/panel-review --personas=dev,security`.
---

# Panel Review

*In this spec, **the orchestrator** is the Claude agent running this skill — it dispatches personas, consolidates findings, and prints the report. The **personas** are sub-agents it dispatches in parallel.*

## What this is for

Dispatches multiple persona-tailored review agents in parallel and consolidates their findings. The strongest signal is **convergence** — something flagged by 2+ personas is almost always real. **Unique signals** (one persona catching something nobody else saw) come second.

## When to use

- Big-bang feature branches before opening the PR.
- Changes that touch multiple teams (CMS content, ops config, external APIs).
- Changes where business consequences sit alongside technical correctness.

## When NOT to use

- A small bugfix or trivial change — one code review is enough.
- A WIP commit you're still iterating on — too early, will generate noise.
- Anything where only the code matters — use your single-purpose code reviewer instead.

## How to invoke

```
/panel-review [target] [--personas=<list>] [--details] [--explain <persona>] [--accept-veto="<reason>"] [--model=<name>] [--force]
```

- `target` - what to review (see table below). Defaults to working-tree diff vs HEAD.
- `--personas=<list>` - comma-separated. Default: every persona with `tier: required` in `personas/`.
- `--details` - skip the iteration prompt at the end of the summary; print all per-persona cards immediately.
- `--explain <persona>` - drill into a single persona for deeper analysis. Full spec in [details.md](details.md); typically run after a panel review.
- `--accept-veto="<reason>"` - non-interactive acknowledgment of all panel vetos with a single reason. No-op if no veto fires. Full flow in [veto.md](veto.md); only relevant when a veto-eligible persona is in the panel.
- `--model=<sonnet|opus|haiku>` - which model the personas run on. Default: `sonnet`. Use `opus` for high-stakes pre-PR passes where catch-rate matters more than cost. `haiku` is accepted but advised against - it tends to miss the subtler convergent issues that are the point of multi-lens review.
- `--force` - bypass the size-guard warning and refusal. See [Size guard](#size-guard); use sparingly.

**Target** — what to review:

| Form                | What it reviews                                                  |
| ------------------- | ---------------------------------------------------------------- |
| (no arg)            | Working-tree diff vs HEAD                                        |
| `staged`            | Staged-only diff                                                 |
| `commit:<sha>`      | A single commit                                                  |
| `range:main..HEAD`  | A commit range (typical for feature branches)                    |
| `plan:<slug>`       | Code changes implementing `.plans/<slug>.md`. Base comes from plan frontmatter `base:` if set, else auto-detected via `git merge-base` against `main`/`master`/`develop` (pick the branch whose merge-base is closest to HEAD by commit count — i.e. the branch you most likely branched from). |
| `feature:<path>`    | Full contents of a feature folder (e.g. `src/features/<name>/`)  |
| `pr:<id>`           | A GitHub / ADO PR (uses `gh` or the ADO MCP if available)        |

## Personas live in `personas/`

Each persona is a markdown file in `personas/`. The skill scans the folder every run, reads each file's frontmatter, and builds the default panel from `tier: required` entries. The persona's identifier is its filename (so `personas/dev.md` → `--personas=dev`).

### Built-in personas

| File                          | Tier     | Role                                                       |
| ----------------------------- | -------- | ---------------------------------------------------------- |
| `personas/dev.md`             | required | Peer Developer who'll maintain this code                   |
| `personas/techlead.md`        | required | Senior engineer responsible for architectural health       |
| `personas/qa.md`              | required | Test-focused engineer owning QA sign-off                   |
| `personas/pm.md`              | required | Project manager accountable for shipping without surprises |
| `personas/client.md`          | required | Non-technical business stakeholder                         |
| `personas/security.md`        | optional | AppSec / security engineer (veto-eligible)                 |
| `personas/devops.md`          | optional | Site reliability engineer                                  |
| `personas/junior.md`          | optional | Developer two months in, reviewing on day 60               |
| `personas/accessibility.md`   | optional | Accessibility engineer (a11y, keyboard, screen-reader)     |
| `personas/performance.md`     | optional | Performance engineer (latency, throughput, resource cost)  |

### Adding or modifying a persona

See [templates/persona.md](templates/persona.md) for the file shape, frontmatter fields, body sections, and a worked example. The orchestrator reads it only when the user asks to create or change a persona — otherwise it stays out of context.

## How to execute

1. **Parse the target.** Resolve to a concrete diff or set of files. If `target` is omitted, default to working-tree vs HEAD. If the working tree is empty and no target given, ask the user.

   For `plan:<slug>` targets: read the plan's YAML frontmatter. If `base: <ref>` is set, the diff base is `git merge-base HEAD <ref>`. If not set, compute `git merge-base HEAD <branch>` for each of `main`, `master`, `develop` that exists, then pick the one whose merge-base is **closest to HEAD by commit count** (`git rev-list --count <merge-base>..HEAD`). That's the branch you most likely branched from. Print one line: `Detected base: <ref> (add 'base:' to plan frontmatter to override).` If none resolve, exit with `Couldn't detect a base branch for plan:<slug>. Add 'base: <ref>' to the plan's frontmatter, or use range:<base>..HEAD instead.`
2. **Scan `personas/`.** Read each `*.md` file's frontmatter. Build the default panel from `tier: required` entries.
3. **Resolve personas.** If `--personas=...` is set, intersect the requested list with what's in `personas/`. Fail clearly if a requested persona has no file. Otherwise use the default panel.
4. **Check target size.** Count files and changed lines per [Size guard](#size-guard). Above the warn threshold → prompt for confirmation; abort if the user declines. Above the refuse threshold → exit unless `--force` was passed.
5. **Dispatch in parallel.** One Agent call per persona, all in a single message. Use the `general-purpose` subagent on the configured model (`--model` flag; defaults to Sonnet, or Opus on `--explain`). Each persona gets its `personas/<name>.md` file injected verbatim, plus the resolved target (the diff or files under review) and the mandatory output format.
6. **Wait for all to return.** All are read-only; none will modify files. If any persona's dispatch errors (rate limit, timeout, refusal, network failure), capture the error message and mark that persona as FAILED for this run. Continue with the personas that succeeded — one failure doesn't kill the review. Read [failure.md](failure.md) only when at least one persona failed, for the rendering rules.
7. **Consolidate.** If **every** persona failed, abort per the all-failed message in [failure.md](failure.md) — no verdict, exit. Otherwise compare findings across the personas that returned successfully (failed personas are skipped entirely — they don't contribute to convergence or to the verdict tally). Match by root cause + file/line (not wording). Filter each persona's "Unique findings" to drop anything already in the TOP block. Compute the verdict in order, stop at first match:
   - Start at **SHIP**.
   - Bump to **HOLD** if any persona said REJECT, or 2+ said HOLD.
   - Bump to **REJECT** if any veto-eligible persona escalated a finding to veto-level.

   If any veto fires (i.e. any active persona has `veto: true` in its frontmatter), read [veto.md](veto.md) for the persona-side requirements, override flow, and `HOLD†` rendering. Don't read it otherwise.
8. **Print the console output** per the layout in [Console output](#console-output) below. Always print the summary. If `--details` was passed, also print the per-persona cards per [details.md](details.md). Otherwise, end with the iteration prompt (`all` / `<PERSONA>` / `no`) and wait for the user's reply.

## Size guard

Before dispatching personas, count the target's size. Very large changes produce noisy reviews (the LLM loses focus across hundreds of files) and burn time and tokens with diminishing returns.

### Thresholds

| Size                                        | Behaviour                                              |
| ------------------------------------------- | ------------------------------------------------------ |
| ≤ 100 files AND ≤ 5,000 changed lines       | Proceed silently.                                      |
| > 100 files OR > 5,000 changed lines        | Warn, ask confirmation. User says yes → proceed.       |
| > 500 files OR > 20,000 changed lines       | Refuse. Exit unless `--force`.                         |

`--force` bypasses both warning and refusal. Use sparingly.

### Counting per target type

| Target              | Count via                                                            |
| ------------------- | -------------------------------------------------------------------- |
| working-tree        | `git diff HEAD --stat`                                               |
| `staged`            | `git diff --cached --stat`                                           |
| `commit:<sha>`      | `git show <sha> --stat`                                              |
| `range:A..B`        | `git diff A..B --stat`                                               |
| `plan:<slug>`       | `git diff <base>..HEAD --stat` where `<base>` is resolved per the plan target spec    |
| `feature:<path>`    | count source files in folder + sum their line counts                 |
| `pr:<id>`           | PR API metadata (changed_files + additions + deletions)              |

### Warning prompt

When size exceeds the warn threshold but stays under refuse:

```
This change is large:
  Files changed:  <N>
  Lines changed:  <M>
  Personas:       <K>  (would dispatch <K> <model> agents)

Consider splitting by directory or sub-feature, or pass --force to proceed.

Proceed? (yes/no)
```

Anything other than affirmative ("yes", "y", "go", "ok") aborts.

### Refusal exit

When size exceeds refuse threshold:

```
This change is too large for a useful panel review:
  Files changed:  <N>
  Lines changed:  <M>
  Threshold:      500 files / 20,000 lines

Run again with --force to override, or split the review.
```

Exit immediately. Do not dispatch personas. Do not prompt.

### --explain drill-in

The size guard applies to `--explain` runs the same way. A single-persona deep dive on a 500-file diff is still noisy and slow.

## Mandatory output format (per persona)

Every persona MUST return findings in this shape — the orchestrator parses this to build the console output:

```
## <Persona> review

**Lens:** <one-line summary of what you focused on>

**Good:** <one-line summary of what looks solid in this change>
**Issues:** <one-line summary of what needs work, or "none worth flagging">

**Top concerns (ordered by importance, 3-5 items):**
- [BLOCK] <concern title>
  - file:line — <file:line ref where relevant; omit when not file-localised>
  - note — <optional code excerpt, fix suggestion, or short rationale>
- [DEFER] <concern title>
  - file:line — <ref>
  - note — <optional>
- [INFO] <concern title>
  - file:line — <ref>

The orchestrator maps these to the rendered output: `file:line` items become `·` sub-bullets, `note` items become `>` sub-bullets. Multiple `note` items per concern are allowed. See [templates/overview/top-issues.md](templates/overview/top-issues.md) for the rendered shape.

**Open questions:**
- <questions for the team; omit if none>

**Veto-level findings:** (only if persona's frontmatter has `veto: true`; see [veto.md](veto.md))
- "<finding name matching a Top concerns entry>" — <rationale: why this is veto-level in your lens>

**Tagline:** <≤37-char summary for the verdict table — must fit in the REASON column without truncation>
**Verdict:** SHIP / HOLD / REJECT — <one-sentence reason>
```

`Good:` and `Issues:` are mandatory one-liners (render `Issues: none worth flagging` even on a clean SHIP). Personas with an `Output extension — required for <name> persona:` block in their file add the sub-sections it declares; inject those instructions into the agent's prompt alongside the standard format.

**Validation.** If a persona's returned output is missing any mandatory field (`Lens`, `Good`, `Issues`, `Top concerns` with severity tags, `Tagline`, `Verdict` with a valid value), mark that persona as FAILED with `agent error: malformed output (missing <field>)` and route through [failure.md](failure.md). Don't try to repair partial output — surfacing the failure is better than rendering an incomplete card.

## Console output

Every run prints a **summary**. Per-persona **details** print on user request, or immediately with `--details`.

### Severity tags

Three plain-text tags used throughout:

- `[BLOCK]` — must fix before ship
- `[DEFER]` — real issue, doesn't block this PR
- `[INFO]` — notable but no action needed

An appended `*` (e.g. `[BLOCK*]`) marks a finding raised by a single persona — a specialist's solo call. Without `*`, the finding is convergent (2+ personas).

### Layout primitives (one border, two width regimes)

- **One bordered element only** — the `panel-overview` box. Every other section uses heading + single horizontal rule, no boxes.
- **Header box and verdict table** are fixed-width — target 62 cols.
- **Issue lines** are unconstrained — title runs as long as needed (target ≤ 190 chars). Hard-wrap with hanging indent at col 10 only if a title actually overflows.
- **Three-layer indent for issues:** `[` and `*` at col 2 (gutter); `·` and `>` at col 7 (sub-bullet); title and sub-bullet content at col 10.
- **Glyph legend:** `·` = file:line ref ("where"). `>` = code excerpt / note / rationale ("what / why"). `*` = personas line ("who"). `[` = new issue tag.

### Verdict markers (verdict-table)

| Glyph | Verdict | Width |
| ----- | ------- | ----- |
| `✓`   | SHIP    | 6     |
| `▸`   | HOLD    | 6     |
| `✗`   | REJECT  | 8     |
| `!`   | FAILED  | 8     |

The VERDICT column auto-sizes to the widest marker present. `[!]` (3-char token) is reserved for alert-section headings (veto, panel-failed, large change, refuse).

### Matching findings across personas

For convergence ("caught by 2+ personas"), match by **root cause + file/line**, not by wording.

- Same root cause + same file/lines → **merge** into one TOP entry.
- Same file, different root causes → **keep separate**.
- Different file → **keep separate** even if symptoms look similar.
- Unsure if findings match → **treat as distinct** (false negatives over false positives).

When merging: pick the **most action-oriented framing** as the canonical title. The merged TOP entry shows that title plus a `* BY: <persona>, <persona>` line. Other framings drop from TOP; users see them by drilling in with `/panel-review --explain <persona>` or by viewing the per-persona cards in the details section.

**Severity on merged entries.** When personas disagree on severity, the merged TOP entry uses the **most severe** tag. If any persona said `[BLOCK]`, the entry is `[BLOCK]` regardless of what others said.

**Solo specialist findings.** A `[BLOCK]`-severity finding raised by a single persona (no convergence) still goes into TOP — marked with `*` (e.g. `[BLOCK*]`). The `* BY:` line uses "X (only)" to make the solo status explicit. Solo `[DEFER]` and `[INFO]` findings don't make TOP — they stay in per-persona cards.

**Example.** Dev says *"OrderService.cs:42 — the discount calculation rounds wrong"*; QA says *"no test for rounding behaviour in OrderService.cs:42"*. Same file, same root cause → merge as:

```text
  [BLOCK] Discount rounding overcharges by 1¢ on odd totals
  * BY: Dev, QA
       ·  src/orders/OrderService.cs:42
       >  Math.Floor(total * discount * 100) / 100  — truncates third decimal
```

### Summary screen (always printed)

Composes three blocks from [templates/overview/](templates/overview/):

1. **`panel-overview`** — rounded box with run-meta + `VERDICT:` + tally.
   Spec: [templates/overview/panel-overview.md](templates/overview/panel-overview.md).
2. **`verdict-table`** — minimal per-persona table.
   Spec: [templates/overview/verdict-table.md](templates/overview/verdict-table.md).
3. **`top-issues`** — presence-based, rendered only when there are findings worth surfacing.
   Spec: [templates/overview/top-issues.md](templates/overview/top-issues.md).

Followed by an iteration prompt (see below).

### Example: clean SHIP

```text
╭─────────────────────────────────────────────────────────────╮
│  PANEL REVIEW                                               │
│  range:main..HEAD  ·  12 files  ·  5 personas               │
│                                                             │
│  VERDICT:  SHIP                                             │
│  5 SHIP  ·  0 HOLD  ·  0 REJECT                             │
╰─────────────────────────────────────────────────────────────╯


  PERSONA      VERDICT     REASON
  ─────────────────────────────────────────────────────────────
  DEV          ✓ SHIP      clean impl, conventions respected
  TECH LEAD    ✓ SHIP      fits existing pipeline shape
  QA           ✓ SHIP      tests cover the new branches
  PM           ✓ SHIP      scope matches the ticket
  CLIENT       ✓ SHIP      no user-visible regression


  Want details? Reply with:
    - "all"        — show all per-persona cards
    - "<PERSONA>"  — drill into one persona (e.g. "DEV")
    - "no"         — done
```

### Example: HOLD with convergent issues

```text
╭─────────────────────────────────────────────────────────────╮
│  PANEL REVIEW                                               │
│  range:main..HEAD  ·  18 files  ·  5 personas               │
│                                                             │
│  VERDICT:  HOLD                                             │
│  3 SHIP  ·  2 HOLD  ·  0 REJECT                             │
╰─────────────────────────────────────────────────────────────╯


  PERSONA      VERDICT     REASON
  ─────────────────────────────────────────────────────────────
  DEV          ▸ HOLD      rounding bug blocks ship
  TECH LEAD    ✓ SHIP      ships, but null guard worth fixing
  QA           ▸ HOLD      need test for rounding edge first
  PM           ✓ SHIP      scope matches the ticket
  CLIENT       ✓ SHIP      end-to-end story still works


  TOP ISSUES — caught by 2+ personas
  ─────────────────────────────────────────────────────────────

  [BLOCK] Discount rounding overcharges by 1¢ on odd totals
  * BY: Dev, QA
       ·  src/orders/OrderService.cs:42
       >  Math.Floor(total * discount * 100) / 100  — truncates third decimal
  [DEFER] Null-guard missing on optional address line — could NPE on imports
  * BY: Dev, Tech Lead
       ·  src/orders/AddressMapper.cs:88


  Want details? Reply with:
    - "all"        — show all per-persona cards
    - "<PERSONA>"  — drill into one persona (e.g. "DEV")
    - "no"         — done
```

### Summary rules

- `<target>` is whatever the user passed (e.g. `range:main..HEAD`), or `working-tree` if no arg.
- Meta line in the box: `<target> · <N> files · <M> personas`. If any persona failed, append `+ <K> failed` (see [failure.md](failure.md)).
- The REASON column shows each persona's `Tagline` field (≤ 37 chars). Truncate longer taglines with `...`.
- **TOP block caps at 3 items.** Selection priority: convergent items first (`[BLOCK]` > `[DEFER]` > `[INFO]`), then solo `[BLOCK*]` findings. Solo `[DEFER]` and `[INFO]` stay in per-persona cards only.
- **TOP block is presence-based.** Absent when there are no findings worth surfacing — no "(none found)" placeholder.
- **Paren convention.** Short modifiers/annotations keep parens — `(only)`, `(security lens)`, `(accepted)`, `(gap, would add)`. Verdict-status appendices and section-heading suffixes use em-dash — `REJECT — veto pending`, `TOP ISSUES — caught by 2+ personas`.

### Iteration prompt (end of every summary)

Always end with:

```text
  Want details? Reply with:
    - "all"        — show all per-persona cards
    - "<PERSONA>"  — drill into one persona (e.g. "DEV")
    - "no"         — done
```

- `"all"` → render Screen 5 (all per-persona cards) per [details.md](details.md).
- `"<PERSONA>"` → render Screen 6 drill-in on that persona on Opus.
- `"no"` (or skip) → done.
- `--details` flag at invocation skips this prompt and renders all cards immediately.

### Per-persona details and drill-in

Card layout and rules live in [details.md](details.md). Templates:
- [templates/details/persona-card.md](templates/details/persona-card.md) — Screen 5.
- [templates/details/drill-in-card.md](templates/details/drill-in-card.md) — Screen 6 (`--explain`).

Read only when one of those triggers fires.

### Failure handling

When one or more personas error out (timeout, rate-limit, refusal, network failure), render per [failure.md](failure.md). One-persona case is a `! FAILED` row in the verdict table plus an optional compact section in details. All-personas case aborts with [templates/alerts/panel-failed.md](templates/alerts/panel-failed.md). Read only when at least one persona fails.

### Size guard

Above warn / refuse thresholds, render [templates/alerts/size-guard.md](templates/alerts/size-guard.md) instead of dispatching. See [Size guard](#size-guard) section above for thresholds.

### Width and rendering

Layout assumes Unicode box-drawing support. Header box and verdict table target 62 cols; issue lines target ≤ 190 chars unconstrained.

## Optional features (loaded on demand)

These features live in sibling files. Read each file only when its trigger condition is met — keeps SKILL.md tight on every run.

| Feature             | Spec file                                    | Loaded when                                                                  |
| ------------------- | -------------------------------------------- | ---------------------------------------------------------------------------- |
| Per-persona details | [details.md](details.md)                     | `--details`, an affirmative reply to the details prompt, or `--explain` runs |
| Failure handling    | [failure.md](failure.md)                     | At least one persona's dispatch errors out                                   |
| Veto override       | [veto.md](veto.md)                           | Any active persona has `veto: true` in frontmatter                           |
| Persona authoring   | [templates/persona.md](templates/persona.md) | User asks to create or modify a persona under `personas/`                    |

### Output rendering templates

The console layout is split across small per-block templates under
`templates/`. Each template documents the literal shape, slots,
and rules for one structural unit:

| Category | Template | Used by |
| -------- | -------- | ------- |
| overview | [panel-overview.md](templates/overview/panel-overview.md) | Screens 1-4, 7 (the rounded header box) |
| overview | [verdict-table.md](templates/overview/verdict-table.md)   | Screens 1-4, 7 (the minimal table)       |
| overview | [top-issues.md](templates/overview/top-issues.md)         | Screens 1-4, 7 (the TOP block)           |
| details  | [persona-card.md](templates/details/persona-card.md)      | Screen 5 (`--details`)                   |
| details  | [drill-in-card.md](templates/details/drill-in-card.md)    | Screen 6 (`--explain`)                   |
| alerts   | [veto-block.md](templates/alerts/veto-block.md)           | Screen 3 (active veto)                   |
| alerts   | [panel-failed.md](templates/alerts/panel-failed.md)       | Screen 8 (all failed)                    |
| alerts   | [size-guard.md](templates/alerts/size-guard.md)           | Screens 9-10 (warn / refuse)             |

Read a template only when its block is about to render — they're not load-on-startup.

## Constraints

- **Plain language always.** Every persona writes findings in clear, jargon-free English. If a domain term is genuinely needed, define it inline. The reader might be a PM, a client, or a junior dev — the report should make sense without specialist knowledge.

  Bad: "CSRF token validation missing."
  Good: "no protection against request forgery — an attacker could submit forms on someone else's behalf."

  Applies to every text field a persona produces (Good, Issues, findings, open questions, veto rationale, verdict reason).
- **Read-only.** Personas never edit code. They only produce findings.
- **Parallel dispatch.** All personas run at once in a single Agent batch, not sequentially. The consolidation happens after all return.
- **Bounded prompts.** Each persona's brief is its `personas/<name>.md` body, expected to fit comfortably under 800 words.

## Example runs

- `/panel-review range:main..HEAD` — default panel (Sonnet) on the commit range.
- `/panel-review --personas=dev,techlead,security --model=opus` — three personas on Opus for a high-stakes pre-PR pass. `security` is opt-in.
- `/panel-review feature:src/features/Loyalty --personas=client,pm` — business-lens "should we ship this?" gut check.
