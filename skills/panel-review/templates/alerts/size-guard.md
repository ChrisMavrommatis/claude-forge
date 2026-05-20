# Template: size-guard

Two variants — `warn` and `refuse` — gating the dispatch when the
target diff exceeds size thresholds. No `panel-overview` box (the
run hasn't dispatched yet); just an alert section + stat block +
recovery instructions.

## Shared structure

1. **`[!] <HEADING TEXT>`** at col 2.
2. **Horizontal rule** at col 2, 62 dashes.
3. **Stat block** — labels at col 2, values at col 19, threshold
   annotations in `(parens)` after each value.
4. **Recommendation / reason** paragraph at col 2.
5. **Recovery instructions** at col 2 (warn: prompt; refuse: text).

## Variant: warn

**Trigger:** target above warn threshold (>100 files OR >5,000
lines) but below refuse.

```text
  [!] LARGE CHANGE — confirm before dispatch
  ─────────────────────────────────────────────────────────────

  Files changed:   147     (warn at >100)
  Lines changed:   8,402   (warn at >5,000)
  Personas:        5       (would dispatch 5 sonnet agents)

  Large changes produce noisy reviews — the LLM loses focus across
  hundreds of files. Consider splitting by directory or sub-feature
  for a sharper result.

  Proceed? (yes / no — or rerun with --force to skip this prompt)
```

**Behaviour:**
- Awaits a yes/no reply from the user.
- `yes` / affirmative reply → dispatches the panel.
- `no` / anything else → aborts cleanly with no further output.
- `--force` on the next invocation skips this screen entirely.

## Variant: refuse

**Trigger:** target above refuse threshold (>500 files OR >20,000
lines).

```text
  [!] REFUSED — change too large for panel review
  ─────────────────────────────────────────────────────────────

  Files changed:   612     (refuse at >500)
  Lines changed:   24,118  (refuse at >20,000)

  At this size the LLM can't keep enough context in focus to give
  a useful review — convergence detection breaks down, and the
  result is mostly noise.

  Split the review, or rerun with --force if you really mean it.
```

**Differences from `warn`:**
- Heading word changes from `LARGE CHANGE — confirm` to
  `REFUSED — too large`. Semantic shift from "I'd rather not" to
  "I won't".
- **No `Personas:` line** in the stat block — no dispatch to forecast.
- **No `Proceed?` prompt.** Exit immediately. User's only paths are
  out-of-band: split the diff, or rerun with `--force`.

## Stat block alignment

- Labels at col 2: `Files changed:`, `Lines changed:`,
  optionally `Personas:`.
- Values at col 19 (16-char label column with `:` and 2 spaces).
- Threshold annotation in parens at col 28 onward
  (`(warn at >100)`, `(refuse at >500)`, `(under warn)`).

## Counting per target type

The orchestrator counts size before dispatch:

| Target              | Count via                                                |
| ------------------- | -------------------------------------------------------- |
| working-tree        | `git diff HEAD --stat`                                   |
| `staged`            | `git diff --cached --stat`                               |
| `commit:<sha>`      | `git show <sha> --stat`                                  |
| `range:A..B`        | `git diff A..B --stat`                                   |
| `plan:<slug>`       | `git diff <base>..HEAD --stat`                           |
| `feature:<path>`    | source files in folder + sum of their line counts        |
| `pr:<id>`           | PR API metadata (changed_files + additions + deletions)  |

## `--force` flag

`--force` bypasses both warn and refuse. Use sparingly — meant for
CI / scripted invocations where the user has already accepted the
cost of a noisy review, or for genuinely-needed reviews on
ostensibly-huge diffs.

## Used by

Screens 9 (warn) and 10 (refuse). Same template, two heading-text
variants.
