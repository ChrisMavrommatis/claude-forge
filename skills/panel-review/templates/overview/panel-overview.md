# Template: panel-overview

The **only** bordered element on the summary screen. Holds identity,
scope, and overall verdict in one compact box. Everything below it
(table, issues) is whitespace-driven — no further boxes, no vertical
separators, no fixed-width frames.

## Why a box here and only here

Borders break when the user's terminal or chat panel is narrower than
the box width. The verdict is the one place worth the risk: a
misaligned border on a 5-line header is tolerable; one around a long
table is not. Everything else uses indentation and a single
horizontal rule.

## Shape

```text
╭─────────────────────────────────────────────────────────────╮
│  PANEL REVIEW                                               │
│  <target>  ·  <N> files  ·  <M> personas[ + <K> failed]     │
│                                                             │
│  VERDICT:  <VERDICT>                                        │
│  <N> SHIP  ·  <N> HOLD  ·  <N> REJECT                       │
╰─────────────────────────────────────────────────────────────╯
```

- Box width: **62 cols** (outer including borders). Tight enough to
  render in chat panels and 80-col terminals without wrapping.
- Rounded corners (`╭ ╮ ╰ ╯`).
- Two stanzas inside: identity (top two lines) and verdict
  (bottom two lines), separated by a blank line.
- The verdict word goes right after `VERDICT:  ` on its own line —
  no centering, no extra borders. Caps and the label are enough.

## Slots

| Slot         | Meaning                                                              |
| ------------ | -------------------------------------------------------------------- |
| `<target>`   | What the user passed (`range:main..HEAD`, `working-tree`, etc.).     |
| `<N> files`  | Files changed in the diff/folder being reviewed.                     |
| `<M>`        | Personas that returned successfully.                                 |
| `<K> failed` | Personas that errored. Omit the `+ <K> failed` segment when zero.    |
| `<VERDICT>`  | `SHIP` / `HOLD` / `REJECT` / `HOLD†`.                                |
| Tally line   | Count of each verdict among successful personas. Failed not counted. |

Elapsed time (`<T>s`) was in the previous draft and is now dropped —
it added nothing essential, and removing it keeps the meta line on one
row at narrower widths. Add it back per-screen if a reviewer asks for it.

## Variants

### Acknowledged veto (HOLD†)

Verdict line shows `HOLD†`; tally gets `· <K> veto acknowledged`;
footnote line(s) appear under the tally **inside** the box, so the
verdict and its caveat stay in one place:

```text
│  VERDICT:  HOLD†                                            │
│  2 SHIP · 2 HOLD · 1 REJECT · 1 veto acknowledged           │
│                                                             │
│  † Security's veto on "Hardcoded API key" accepted by user: │
│    "rotating key next sprint, monitored access in interim"  │
```

### Failed personas

Meta line gains the `+ <K> failed` segment. Tally still only counts
verdicts from personas that returned.

```text
│  range:main..HEAD  ·  18 files  ·  4 personas + 1 failed    │
│                                                             │
│  VERDICT:  HOLD                                             │
│  2 SHIP  ·  2 HOLD  ·  0 REJECT                             │
```

## Used by

Every summary-shaped screen. The all-personas-failed abort omits this
block — no verdict, no overview, just the failure list.

## Not used by

- Per-persona detail cards.
- Drill-in cards.
- Size-guard warn/refuse screens (those have their own minimal block).
