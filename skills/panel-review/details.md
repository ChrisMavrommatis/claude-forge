# Per-persona details

Spec for rendering the per-persona blocks and handling drill-in. The
orchestrator reads this file only when one of these triggers fires —
otherwise it stays out of context:

- `--details` flag is set, OR
- User replied `"all"` (or affirmative-equivalent) to the iteration prompt, OR
- User replied with a single persona name (or `--explain <persona>`).

## Two render modes

| Trigger                       | What renders                          | Template                                                       |
| ----------------------------- | ------------------------------------- | -------------------------------------------------------------- |
| `--details` or reply `"all"`  | One section per persona on the panel  | [templates/details/persona-card.md](templates/details/persona-card.md) |
| Reply `"<PERSONA>"` or `--explain` | One drill-in section (Opus by default) | [templates/details/drill-in-card.md](templates/details/drill-in-card.md) |

Both render styles share the same primitives — heading + horizontal
rule + content sections, no borders, three-layer indent for findings.

## Section layout (both modes)

```text
  <PERSONA>  ·  <marker> <VERDICT>[  [drill-in]]
  ─────────────────────────────────────────────────────────────

  Lens:    <one-line summary of what this persona focused on>
  Good:    <one-line summary of what looks solid>
  Issues:  <one-line summary of what needs work, or "none worth flagging">

  <Findings section — Unique findings: for --details, Deep findings: for drill-in>
  [<SEVERITY>] <Title>
       ·  <file:line>
       >  <optional code excerpt or note>

  Open questions:
    - <question>
    - <another question>

  <Output-extension sub-sections — persona-specific>
```

## Section rules

- **Heading at col 2**: `<PERSONA>  ·  <marker> <VERDICT>`. Persona
  name in caps. Marker glyphs per the locked verdict table
  (`✓ ▸ ✗ !`). Drill-in mode appends `  [drill-in]`.
- **Horizontal rule at col 2**, 62 dashes wide.
- **Two blank lines between sections.**
- **Persona-name max 14 chars.** Longer names truncate with `…`.
- **`Lens:`, `Good:`, `Issues:` are mandatory.** Even on a clean SHIP,
  render `Issues:  none worth flagging.`
- **Findings inside cards omit the `* BY:` line.** The section
  heading already names the persona. Title + `·`/`>` sub-bullets
  still follow the three-layer indent (see [templates/overview/top-issues.md](templates/overview/top-issues.md)).
- **Convergent findings must NOT repeat in `Unique findings`.**
  Filter each persona's findings, dropping anything already in TOP.
  If everything was convergent, render:
  ```text
  Unique findings:
    None worth flagging on top of the TOP issues
  ```
  (2-space indent, no italics, capitalised first word.)
- **`Open questions:`** is `-` bullets at col 4. Omitted entirely
  if empty.
- **Output-extension sub-sections** (e.g. `Test gaps:` for QA,
  `Scope coverage:` for PM, `Readiness:` for Client) render after
  `Open questions:` with `-` bullets at col 4. Each declared by the
  persona's own file. Same empty-omission rule.

## Section order

Required personas first (`dev`, `techlead`, `qa`, `pm`, `client`),
then optional personas in panel order, then custom personas
alphabetically. Failed personas appear in their natural panel
position (not sorted to the end); they render as the compact
failure section per [failure.md](failure.md).

## Drill-in mode (`--explain`)

When the user follows up with a single persona name or
`--explain <PERSONA>`, dispatch a single Agent call to that persona
with a brief asking for deeper file/line-level analysis on the
findings already surfaced.

- **Defaults to model `opus`** for catch-rate; override with
  `--model=<name>`.
- **Findings label changes** from `Unique findings:` to
  `Deep findings:` to signal the format shift: each `>` sub-bullet
  can carry a full paragraph with hanging indent at col 10.
- **Multi-line `>` content** wraps at col 10 (the content column).
- **Heading gains `[drill-in]` suffix** so the section is visually
  distinct from a Screen 5 card in screenshots.
- **Low-content drill-in:** if the persona shipped cleanly with
  nothing to add, render under `Deep findings:` (2-space indent):
  ```text
  Deep findings:
    PM shipped cleanly with no individual concerns. The TOP issues
    from the panel summary are the only items in PM's view; the
    deeper read confirms PM stands by SHIP.
  ```
- **Size guard still applies.** A drill-in on a 500-file diff is
  still noisy and slow.

## Footer

After the last section, render the iteration footer:

**For `--details` (Screen 5):**

```text
  ─────────────────────────────────────────────────────────────
  Want to go deeper on one persona? Reply with:
    - "<PERSONA>"  — re-run that persona on Opus with deeper analysis
    - "no"         — done
```

**For `--explain` drill-in (Screen 6):**

```text
  ─────────────────────────────────────────────────────────────
  Want to drill into another persona? Reply with:
    - "<PERSONA>"  — drill into another persona
    - "no"         — done
```

(Drill-in mode omits `"all"` — the user is iterating one persona
at a time; to return to summary, they rerun `/panel-review`.)

## See also

- [templates/details/persona-card.md](templates/details/persona-card.md) — Screen 5 full shape with examples.
- [templates/details/drill-in-card.md](templates/details/drill-in-card.md) — Screen 6 drill-in.
- [templates/overview/top-issues.md](templates/overview/top-issues.md) — the issue line format used inside cards (without the `* BY:` line).
