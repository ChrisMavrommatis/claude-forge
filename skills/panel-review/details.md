# Per-persona details

Spec for rendering the per-persona cards and handling drill-in. The orchestrator reads this file only when one of these triggers fires — otherwise it stays out of context:

- `--details` flag is set, OR
- User affirmatively replied to "Want per-persona details?", OR
- `--explain <persona>` is used.

## Card layout

```
Per-persona findings
═════════════════════


╭─ Persona: <NAME>  ·  Verdict: <X> ───────────────────────────╮
│                                                              │
│  Good:    <one-line summary of what looks solid>             │
│  Issues:  <one-line summary of what needs work, or "none">   │
│                                                              │
│  Unique findings:                                            │
│    - <finding>                                               │
│    - <finding>                                               │
│                                                              │
│  Open questions:                                             │
│    - <question>                                              │
│                                                              │
│  <any output-extension sub-sections required by this persona>│
│                                                              │
╰──────────────────────────────────────────────────────────────╯


<next card>
...
```

## Card rules

- **Width is fixed at 64 characters.** Every content line is padded with spaces so the closing `│` lands at column 64 exactly. Padding may drift by 1-2 characters on edge cases (LLMs occasionally miscount); this is a known limitation, not a spec violation. Aim for the target.
- **Title sits in the top border**: `╭─ Persona: <NAME>  ·  Verdict: <X> ────...───╮`. Persona names are upper-cased in the title.
- **Persona name max 14 characters.** Longer names truncate with `...`.
- **`Good:` and `Issues:` are mandatory.** Even on a clean SHIP, render `Issues:  none worth flagging`.
- **Empty sub-sections are omitted entirely.** No "Open questions: none" placeholders — if a persona has no Open questions, drop the sub-section.
- **All lists use `- ` bullets.** No numbered lists inside cards.
- **Long lines wrap at word boundary.** Continuation lines indent to align with the start of the bullet's text (the column after `    - `).
- **Convergent findings must NOT repeat in `Unique findings`.** Filter each persona's findings, dropping anything already shown in the summary's TOP block. If everything was convergent, render `Unique findings:` with the single bullet `- none worth flagging on top of the TOP issues`.
- **Variance allowed**: QA, PM, Client (and any custom persona declaring one) add their output-extension sub-sections after `Unique findings`. Same wrapping and empty-omission rules apply.
- **Two blank lines between cards.** No dividers between them.
- **Card order**: required personas first (`dev`, `techlead`, `qa`, `pm`, `client`), then optional personas in the order they appear on the panel, then custom personas alphabetically.

## Drill-in footer

After the last card, render this footer:

```
─────────────────────────────────────────────────────────────────
Drill into any persona for a deeper look:
  /panel-review --explain <PERSONA>
  (or just say: "explain <PERSONA>", "go deeper on <PERSONA>")
```

## `--explain` behaviour

When the user follows up with `--explain <PERSONA>` or a natural-language equivalent ("explain DEV", "go deeper on PM"), dispatch a single Agent call to that persona with a brief asking for deeper file/line-level analysis on the findings already surfaced.

- **`--explain` defaults to model `opus`**; override with `--model=<name>` if you want a different model.
- The expanded output reuses the card layout above, just with longer findings and more references.
- The size guard still applies — large-target drill-in is just as noisy.
