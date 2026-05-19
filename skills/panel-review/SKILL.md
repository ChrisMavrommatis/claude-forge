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
- `--details` - skip the "Want per-persona details?" prompt; print the per-persona cards immediately.
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
8. **Print the console output** per the layout in [Console output](#console-output) below. Always print the summary. If `--details` was passed (or the user answers yes to the prompt), also print the per-persona cards per [details.md](details.md). Otherwise, end with "Want per-persona details?" and wait for the user.

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

Every persona MUST return findings in this shape — the orchestrator parses this to build the console cards:

```
## <Persona> review

**Lens:** <one-line summary of what you focused on>

**Good:** <one-line summary of what looks solid in this change>
**Issues:** <one-line summary of what needs work, or "none worth flagging">

**Top concerns (ordered by importance, 3-5 items):**
- [BLOCK] <concern> — <rationale + file:line ref where relevant>
- [DEFER] <concern> — <rationale + file:line>
- [INFO] <concern> — <rationale + file:line>

Each concern is tagged with its severity ([BLOCK] / [DEFER] / [INFO]). The orchestrator uses these to assign tags in the TOP block and to compute the verdict.

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

### Matching findings across personas

For convergence ("caught by 2+ personas"), match by **root cause + file/line**, not by wording.

- Same root cause + same file/lines → **merge** into one TOP entry.
- Same file, different root causes → **keep separate**.
- Different file → **keep separate** even if symptoms look similar.
- Unsure if findings match → **treat as distinct** (false negatives over false positives).

When merging: pick the **most action-oriented framing** as the canonical title — the one that tells the reader *what to fix*, not what's broken or what the consequence is. The merged TOP entry shows that title plus `flagged by: <persona>, <persona>, ...`. Other framings drop from TOP; users see them by drilling in with `/panel-review --explain <persona>` or by expanding the per-persona cards in the details section.

**Severity on merged entries.** When personas disagree on severity, the merged TOP entry uses the **most severe** tag. If any persona said `[BLOCK]`, the entry is `[BLOCK]` regardless of what others said. One concerned reviewer trumps two indifferent ones.

**Solo specialist findings.** A `[BLOCK]`-severity finding raised by a single persona (no convergence) still goes into TOP — marked with `*` (e.g. `[BLOCK*]`). The `flagged by:` line uses "X only" to make the solo status explicit. This catches genuinely critical specialist alerts (security finding a hardcoded secret, etc.) that nobody else has the lens for. Solo `[DEFER]` and `[INFO]` findings don't make TOP — they stay in per-persona cards.

**Example.** Dev says *"OrderService.cs:42 — the discount calculation rounds wrong, customers can be overcharged by 1¢"*; QA says *"no test for rounding behaviour in OrderService.cs:42"*. Same file, same root cause → merge as:

```
- [BLOCK]  Discount rounding error in OrderService.cs:42
           flagged by: Dev, QA
```

Dev's framing wins as the title because it points at *what to fix* (the calculation). QA's framing is dropped from TOP but stays visible in QA's persona card.

### Summary (always printed)

```
╭─────────────────────────────────────────────────────────────────╮
│  PANEL REVIEW                                                   │
│  <target>  ·  <N> files  ·  <M> personas  ·  <T>s               │
╰─────────────────────────────────────────────────────────────────╯

  OVERALL:  <SHIP|HOLD|REJECT>     (<N> HOLD · <N> SHIP · <N> REJECT)

  ┌────────────┬─────────┬─────────────────────────────────────┐
  │ PERSONA    │ VERDICT │ REASON                              │
  ├────────────┼─────────┼─────────────────────────────────────┤
  │ DEV        │ <X>     │ <one-line reason, ≤37 chars>        │
  │ TECH LEAD  │ <X>     │ <one-line reason, ≤37 chars>        │
  │ ...        │ ...     │ ...                                 │
  └────────────┴─────────┴─────────────────────────────────────┘

  TOP ISSUES  (caught by 2+ personas)
  ─────────────────────────────────────────────────────────────────

  - [BLOCK]  <one-line issue title>
             flagged by: <persona>, <persona>
  - [BLOCK*] <one-line issue title>     (specialist solo, e.g. security alone)
             flagged by: <persona> only
  - [DEFER]  ...

  Want per-persona details? (pass --details to skip this prompt)
```

**Summary rules:**

- Rounded corners (`╭ ╮ ╰ ╯`) for the top banner; sharp corners (`┌ ┬ ┐ ─ ├ ┤ └ ┴ ┘ │`) for the verdict table.
- `<target>` is whatever the user passed (e.g. `range:main..HEAD`), or `working-tree` if no arg.
- Banner meta line: `<target> · <N> files · <M> personas · <T>s`. If any persona failed, append `+ <K> failed` to the personas count (see [failure.md](failure.md) for details).
- The REASON column shows each persona's `Tagline` field (≤37 chars by spec). If a persona returns a tagline longer than 37 chars, truncate with `...`.
- TOP block caps at 3 items. Selection priority: convergent items first (sorted `[BLOCK]` > `[DEFER]` > `[INFO]`), then solo `[BLOCK]` findings marked with `*` (e.g. `[BLOCK*]`). Solo `[DEFER]` and `[INFO]` findings stay in per-persona cards only.
- If TOP would be empty (no convergent findings AND no solo `[BLOCK]` findings), replace it with `- (no critical findings — panel agrees there is nothing to block on)`.
- After the TOP block, end with the "Want per-persona details?" prompt and wait for the user's reply, unless `--details` was passed. Accept any affirmative response ("yes", "y", "show me", "sure", a bare "ok") as a request for details.

### Per-persona details and drill-in

Card layout and rules for `--details`, "yes" replies to the details prompt, and `--explain` drill-in live in [details.md](details.md). Read only when one of those triggers fires.

### Failure handling

When one or more personas error out (timeout, rate-limit, refusal, network failure), render per [failure.md](failure.md). Includes the compact failure card, tally/banner adjustments, and the all-personas-failed abort message. Read only when at least one persona fails.

### Width and rendering

Layout assumes Unicode box-drawing support and targets 80 columns minimum.

## Optional features (loaded on demand)

These features live in sibling files. Read each file only when its trigger condition is met — keeps SKILL.md tight on every run.

| Feature             | Spec file                                    | Loaded when                                                                  |
| ------------------- | -------------------------------------------- | ---------------------------------------------------------------------------- |
| Per-persona details | [details.md](details.md)                     | `--details`, an affirmative reply to the details prompt, or `--explain` runs |
| Failure handling    | [failure.md](failure.md)                     | At least one persona's dispatch errors out                                   |
| Veto override       | [veto.md](veto.md)                           | Any active persona has `veto: true` in frontmatter                           |
| Persona authoring   | [templates/persona.md](templates/persona.md) | User asks to create or modify a persona under `personas/`                    |

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
