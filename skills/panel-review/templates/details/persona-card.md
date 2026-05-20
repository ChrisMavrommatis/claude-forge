# Template: persona-card

The per-persona block in the Screen 5 details view. **No border** —
heading + horizontal rule + content sections, separated from the
next persona by two blank lines.

## Shape

```text
  DEV  ·  ▸ HOLD
  ─────────────────────────────────────────────────────────────

  Lens:    Would I want to maintain this?
  Good:    Service split keeps the call sites tidy.
  Issues:  Rounding logic + a silent null fallback.

  Unique findings:
  [DEFER] Silent fallback to 0 hides bad inputs
       ·  src/orders/OrderService.cs:71
       >  if (price is null) price = 0;  — hides type contract bugs

  Open questions:
    - Is the rounding direction intentional, or copied from the legacy
      PriceCalc service?
```

## Section heading

- `PERSONA  ·  <marker> <VERDICT>` at col 2. Persona name in caps.
- Horizontal rule at col 2, 62 dashes wide (matches `verdict-table`).
- Two blank lines between this section and the next persona's.

## Content sections (fixed order)

1. **`Lens:`** — one-line summary of what this persona focused on.
2. **`Good:`** and **`Issues:`** — mandatory one-liners.
   `Issues: none worth flagging` even on clean SHIP.
3. **`Unique findings:`** — uses the locked three-layer issue
   format (see `templates/overview/top-issues.md`), but **omits
   the `* BY:` line** since the section heading names the persona.
   - If everything this persona flagged is already in TOP, render
     the placeholder at 4-space indent:
     ```
     Unique findings:
       None worth flagging on top of the TOP issues
     ```
4. **`Open questions:`** — `-` bullets at col 4. Sub-section
   omitted entirely if empty.
5. **Output-extension sub-sections** — persona-specific extras
   (e.g. `Test gaps:` for QA, `Scope coverage:` for PM,
   `Readiness:` for Client). Same `-` bullets at col 4.

## Empty placeholder convention

When a section has no content but should still render (because the
section is mandatory), indent the placeholder text **2 spaces** under
the heading, no italics, capitalised first word:

```text
  Unique findings:
    None worth flagging on top of the TOP issues
```

## Failed persona variant

A persona that errored gets a compact section instead of a full
card:

```text
  TECH LEAD  ·  ! FAILED
  ─────────────────────────────────────────────────────────────

  Agent error:  timeout after 60s

    Failed personas don't count toward convergence or tally.
    Rerun /panel-review to retry.
```

No `Lens:` / `Good:` / `Issues:` / `Unique findings:` etc — the
agent didn't produce them. Just the error + a status note.

## Card order

Required personas first (`dev`, `techlead`, `qa`, `pm`, `client`),
then optional personas in panel order, then custom personas
alphabetically. Failed personas appear in their natural panel
position (not sorted to the end).

## Footer

After the last card, render the drill-in prompt:

```text
  ─────────────────────────────────────────────────────────────
  Want to go deeper on one persona? Reply with:
    - "<PERSONA>"  — re-run that persona on Opus with deeper analysis
    - "no"         — done
```

## Used by

Screen 5 (details view). For drill-in (Screen 6), see
`templates/details/drill-in-card.md`.
