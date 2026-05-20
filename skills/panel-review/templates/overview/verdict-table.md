# Template: verdict-table

The per-persona breakdown that sits below the `panel-overview` box on
every summary-shaped screen. Minimal: no surrounding box, no vertical
separators, one horizontal rule under the column headers.

## Shape

```text
  PERSONA      VERDICT     REASON
  ─────────────────────────────────────────────────────────────
  DEV          ✓ SHIP      clean impl, conventions respected
  TECH LEAD    ✓ SHIP      fits existing pipeline shape
  QA           ▸ HOLD      no test for rounding edge
  PM           ✓ SHIP      scope matches the ticket
  CLIENT       ✓ SHIP      no user-visible regression
```

- Row indent: col 2 (matches everything else on the page).
- Single horizontal rule at col 2, 62 dashes wide (matches the
  `panel-overview` box width above it).
- Columns separated by whitespace alignment, not pipes or borders.

## Columns

| Column   | Purpose                                                 |
| -------- | ------------------------------------------------------- |
| PERSONA  | Persona name in caps. Width auto-sizes to longest name. |
| VERDICT  | Marker glyph + word. Width auto-sizes to widest marker. |
| REASON   | One-line tagline from the persona's output.             |

## Verdict markers

| Glyph | Verdict | Width (chars) |
| ----- | ------- | ------------- |
| `✓`   | SHIP    | 6             |
| `▸`   | HOLD    | 6             |
| `✗`   | REJECT  | 8             |
| `!`   | FAILED  | 8             |

The VERDICT column width is set by the widest marker present on the
panel. A clean SHIP run keeps the column tight at 6 chars; a panel
with FAILED or REJECT grows to 8.

## REASON column

- Concise one-line tagline. Comes from each persona's `Tagline:` /
  `Verdict:` field (≤ 37 chars by the persona output spec).
- For SHIP-with-caveat votes, use the "ships, but X" framing so the
  reader sees the nuance before the TOP block elaborates.
- For FAILED rows, REASON shows the agent error message:
  `agent error: <short cause>`.

## Edge cases

- **Longer persona names** (`ACCESSIBILITY`, `PERFORMANCE`) push the
  PERSONA column wider for the whole table. All rows pad to match.
- **Failed persona** appears inline as a regular row with `! FAILED`
  in the VERDICT column. No special separator or highlight.
- **Acknowledged veto** doesn't change the table — the veto-eligible
  persona still shows their original `✗ REJECT`; the override status
  lives in the `panel-overview` footnote.

## Used by

Every screen that renders a verdict table — Screens 1, 2, 3, 4, 7.
Screens 5 (details), 6 (drill-in), 8 (all failed), 9-10 (size guard)
do not render this block.
