# Template: top-issues

The consolidated findings section that appears below the verdict
table on summary screens. **Presence-based** — rendered only when
there's at least one convergent finding or one solo `[BLOCK*]`.
Absent otherwise; no "(none found)" placeholder.

## Shape

```text
  TOP ISSUES — caught by 2+ personas
  ─────────────────────────────────────────────────────────────

  [BLOCK] Discount rounding overcharges by 1¢ on odd totals
  * BY: Dev, QA
       ·  src/orders/OrderService.cs:42
       >  Math.Floor(total * discount * 100) / 100  — truncates third decimal
  [DEFER] Null-guard missing on optional address line — could NPE on imports
  * BY: Dev, Tech Lead
       ·  src/orders/AddressMapper.cs:88
  [INFO]  Stale TODO references InvoiceMapper that was deleted in #4421
  * BY: Tech Lead, QA
       ·  src/orders/InvoiceWriter.cs:7
       >  // TODO: pass InvoiceMapper here when ready
```

## Section heading

- `TOP ISSUES` in caps at col 2.
- Em-dash + suffix describes the contents:
  - `— caught by 2+ personas` — only convergent findings.
  - `— any persona's [BLOCK]` — only solo `[BLOCK*]` findings.
  - `— caught by 2+ personas, plus any veto` — mix of convergent
    and a veto-source entry.
- Horizontal rule at col 2, 62 dashes.

## Issue line — three-layer indent

| Layer        | Col | Glyph    | Carries                            |
| ------------ | --- | -------- | ---------------------------------- |
| Gutter       | 2   | `[`, `*` | New-issue tag, personas line.      |
| Sub-bullet   | 7   | `·`, `>` | `·` file:line ref · `>` code/note. |
| Content      | 10  | (none)   | Title text; sub-bullet content.    |

**Per-issue order:**
1. `[SEVERITY] Title` — title at col 10. Hard-wraps with hanging
   indent at col 10 if > ~190 chars.
2. `* BY: Persona, Persona` — who flagged it. `* BY: <persona>
   (only)` for solo `[BLOCK*]`.
3. `·  file:line` — where it lives. Omit when not file-localised.
4. `>  <code excerpt or note>` — optional, one line each.

**Severity tags:**
- `[BLOCK]` — must fix before ship (7 chars including brackets).
- `[BLOCK*]` — solo specialist finding (8 chars; pad title accordingly).
- `[DEFER]` — real issue, doesn't block this PR (7 chars).
- `[INFO]`  — notable, no action needed (6 chars; pad with 2 spaces
  so the title still starts at col 10).

## Selection and ordering

- **TOP block caps at 3 items** on the summary view.
- **Sort:** convergent items first (`[BLOCK]` > `[DEFER]` > `[INFO]`),
  then solo `[BLOCK*]` findings.
- **Solo `[DEFER]` and `[INFO]`** stay in per-persona detail cards;
  they don't make TOP.
- **Veto source** marked inline with `← veto source` (pending) or
  `← veto source (accepted)` after the title. Sort to the top of
  TOP so the gate is visible without scrolling past other entries.

## Width

- Issue title and `>` content lines: **unconstrained** (target ≤
  190 chars). The terminal/chat panel handles soft-wrap if anything
  overflows.
- Section heading + rule still match the 62-col rhythm from
  `panel-overview` and `verdict-table` above.

## No blank line between issues

The `[` glyph at col 2 is the visual boundary between issues. `*`
and `·`/`>` are continuations of the issue above.

## Used by

Screens 1 (when populated), 2, 3, 4, 7 (summary view).
