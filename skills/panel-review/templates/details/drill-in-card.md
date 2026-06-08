# Template: drill-in-card

The single-persona deep-dive rendered by `--explain <PERSONA>`.
Same shape as `persona-card`, with three modifications:

1. Heading gains a **`[drill-in]` suffix**.
2. **`Unique findings:` is renamed `Deep findings:`** to signal the
   format change: each `>` sub-bullet can carry a full paragraph of
   rationale with hanging indent at col 10.
3. Footer offers **"another persona" or "done"** — no `"all"` since
   the user is iterating one-by-one.

## Shape

```text
  DEV  ·  ▸ HOLD  [drill-in]
  ─────────────────────────────────────────────────────────────

  Lens:    Would I want to maintain this?
  Good:    Service split keeps the call sites tidy.
  Issues:  Rounding logic + a silent null fallback.

  Deep findings:
  [BLOCK] Discount rounding overcharges by 1¢ on odd totals
       ·  src/orders/OrderService.cs:42
       >  Math.Floor(total * discount * 100) / 100  — truncates third decimal
       >  For totals where the cents would round up (e.g. €19.995),
          the customer is charged €19.99 instead of €20.00. Across
          10k orders/day with avg basket €30, this is ~€500/year
          leaked — small, but it shows up in monthly reconciliation.
       >  Fix: Math.Round(..., MidpointRounding.ToEven), plus pin
          it with a test for €19.995 and €0.005 inputs.

  Open questions:
    - Is the rounding direction intentional, or copied from the legacy
      PriceCalc service?


  ─────────────────────────────────────────────────────────────
  Want to drill into another persona? Reply with:
    - "<PERSONA>"  — drill into another persona
    - "no"         — done
```

## Differences from `persona-card`

| Aspect              | `persona-card` (Screen 5)   | `drill-in-card` (Screen 6)   |
| ------------------- | --------------------------- | ---------------------------- |
| Heading suffix      | none                        | `[drill-in]`                 |
| Findings label      | `Unique findings:`          | `Deep findings:`             |
| `>` sub-bullet content | one-line per bullet      | multi-paragraph OK with hang-indent at col 10 |
| Footer menu         | `all` / `<PERSONA>` / `no`  | `<PERSONA>` / `no`           |
| Card count          | many (one per persona)      | one                          |

## Multi-line `>` content

When a `>` sub-bullet carries prose, wrap with hanging indent at
col 10 (the content column). Each `>` bullet starts a new logical
paragraph; the wrap continues the same paragraph.

```text
       >  For totals where the cents would round up (e.g. €19.995),
          the customer is charged €19.99 instead of €20.00.
       >  Fix: Math.Round(..., MidpointRounding.ToEven).
```

## Low-content drill-in

When the persona shipped cleanly and has no individual findings,
say so in plain prose under `Deep findings:` (indent 2 spaces, no
parens, no italics):

```text
  Deep findings:
    PM shipped cleanly with no individual concerns. The TOP issues
    from the panel summary are the only items in PM's view; the
    deeper read confirms PM stands by SHIP.
```

The extension sub-sections (`Scope coverage:`, `Readiness:`, etc.)
carry the rest.

## Used by

Screen 6 (`--explain` drill-in), triggered by `/panel-review
--explain <PERSONA>` or natural-language replies (`"DEV"`,
`"explain DEV"`, `"go deeper on PM"`) on summary or details screens.
