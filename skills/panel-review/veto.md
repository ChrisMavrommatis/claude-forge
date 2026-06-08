# Veto and override

Spec for the panel's veto mechanism. The orchestrator reads this file only when a persona with `veto: true` is in the active panel — otherwise it stays out of context.

## Persona file requirements

A persona that can veto must declare it in two places in its `.md` file:

1. **Frontmatter**: `veto: true`
2. **Body**: a `**Veto criteria** (block ship if any apply):` section listing the specific failure modes that warrant a veto in that lens.

Example shape (the `security` persona ships with this enabled; other built-ins do not):

```markdown
---
tier: required | optional
role: ...
lens: ...
veto: true
---

# <Persona Title>

**Look for:**
- ...

**Veto criteria** (block ship if any apply):
- <specific failure mode 1>
- <specific failure mode 2>
- ...

**Voice rule:** ...
```

The persona consults its own Veto criteria when reviewing — it does NOT escalate findings that fall outside its lens or below its own threshold.

## Validation at startup

For each persona in the panel:

- `veto: true` AND has a `Veto criteria` section → veto-eligible.
- `veto: true` AND no `Veto criteria` section → print a warning and treat as non-veto for this run:
  ```
  Warning: persona <name> declares veto: true but has no "Veto criteria"
           section — treating as non-veto for this run.
  ```
- No `veto: true` → never veto-eligible. Any `Veto-level findings:` section the persona produces is ignored silently.

## How vetos surface in persona output

A veto-eligible persona returns findings in the standard format, plus one additional optional section:

```markdown
**Veto-level findings:**
- "<finding name matching a Top concerns entry>" — <rationale: why this is veto-level in your lens>
- "<finding name>" — <rationale>
```

- One bullet per veto-level finding.
- The finding name must match an entry in the persona's Top concerns list.
- The rationale is the persona's reasoning for escalating (used in the veto block UI verbatim).
- The whole section is omitted if no findings qualify.

## Verdict rule with veto

The canonical verdict rule lives in SKILL.md step 7 (`SHIP → HOLD on any REJECT or 2+ HOLD → REJECT on any unacknowledged veto`). Vetos plug into the REJECT bump: a veto-eligible persona that produced unacknowledged `Veto-level findings` triggers it.

Acknowledged vetos move the verdict from REJECT to **HOLD†**, never to SHIP.

## Veto block (console)

When one or more unacknowledged vetos fire, render the veto block(s)
**above** the `panel-overview` box — the only content that ever
appears before the run-meta. The block uses the alert-section pattern
(no border, `[!]` heading + horizontal rule). Full shape spec at
[templates/alerts/veto-block.md](templates/alerts/veto-block.md):

```text
  [!] VETO  ·  <PERSONA> says this should not ship
  ─────────────────────────────────────────────────────────────

  Finding:  <finding title>
       ·  <file:line if available>

  Why veto-level (<persona-name> lens):
    <persona's veto rationale, verbatim from Veto-level findings>

  To proceed:
    - Fix the issue and rerun.
    - Reply:  accept veto: <your reason in one line>
    - Or pass --accept-veto="<reason>" on the next invocation.

  Until acknowledged, OVERALL stays REJECT.
```

If multiple vetos fire, stack blocks in the standard panel order
(required → optional → custom alphabetical), and within a persona,
in the order findings appeared in their Top concerns list. The
shared `To proceed:` instructions move to the end with an
`(applies to all vetos above)` qualifier — don't repeat them per
veto.

### Companion: panel-overview verdict line

The `panel-overview` box reflects the veto status:

- Single active veto: `VERDICT:  REJECT — veto pending`
- Multiple active vetos: `VERDICT:  REJECT — 2 vetos pending`
- Tally suffix appends `· <N> veto` / `· <N> vetos` after the
  REJECT count.

### TOP-block marker

The veto source appears in TOP block, sorted to the top, with
`← veto source` after the title (pending) or `← veto source (accepted)`
once acknowledged.

## Override flow

After the veto block(s), the orchestrator waits for the user's reply.

**Affirmative override** — user replies `accept veto: <reason>` (or close variants: "ack veto: <reason>", "override veto: <reason>"):
- Reason is recorded against the first unacknowledged veto.
- If multiple vetos remain, orchestrator prompts again: `1 of 3 vetos acknowledged — <persona>'s veto on <finding> still pending.`
- Once all vetos are acknowledged, verdict moves from REJECT to HOLD†.
- The summary renders with the HOLD† marker and footnotes for each acknowledged veto.

**Non-acknowledgment** — user asks a question, says no, asks for more detail:
- Verdict stays REJECT.
- Veto block stays visible.
- Orchestrator answers the question if applicable, then re-prints the prompt.

**Non-interactive override** — `--accept-veto="<reason>"` flag:
- Acknowledges ALL vetos with the same reason.
- Use sparingly — usually you want a different reason per veto.

## Acknowledged-veto rendering

When all vetos are acknowledged, the veto block(s) disappear from
the top of the screen. The `panel-overview` box grows to carry the
acknowledged-veto footnote(s) inline, so the verdict and its caveats
stay in one place:

```text
╭─────────────────────────────────────────────────────────────╮
│  PANEL REVIEW                                               │
│  range:main..HEAD  ·  18 files  ·  6 personas               │
│                                                             │
│  VERDICT:  HOLD†                                            │
│  2 SHIP  ·  2 HOLD  ·  1 REJECT  ·  1 veto acknowledged     │
│                                                             │
│  † Security's veto on "Hardcoded API key" accepted:         │
│    "rotating key next sprint, monitored access in interim"  │
╰─────────────────────────────────────────────────────────────╯
```

- The `†` marker MUST appear on the verdict line. Without it the
  user can't tell HOLD† apart from a fresh HOLD.
- Each acknowledged veto gets a 2-line footnote inside the box:
  the `†` summary line, then the indented reason quote (4 spaces
  in from the box edge).
- Footnote text uses a dense form (`"<title>" accepted:` not
  `"<title>" accepted by user:`) to fit inside the 62-col box
  without wrapping.
- Tally suffix becomes `· <N> veto acknowledged` / `· <N> vetos
  acknowledged` (mirroring the pending forms above).
- The TOP-block marker shifts from `← veto source` to
  `← veto source (accepted)` so the status is also visible there.

Box height grows by 2 lines per acknowledged veto. This keeps the
explanation attached to the verdict instead of sitting below it.

## --accept-veto no-op

If `--accept-veto="<reason>"` is passed but no veto fires, silently ignore it — no warning, no error, no "nothing happened" message.

## Edge cases

- **All veto-eligible personas FAILED**: no veto can fire; verdict per normal rule. (Other personas' verdicts still count.)
- **One veto-eligible persona failed, others ran**: the failed one can't veto (no output to scan). Other veto personas still fire normally.
- **One veto-eligible persona ran, no veto-level findings**: behaves as a normal persona.
- **Veto-eligible persona has empty Veto criteria section**: treat as malformed; warn and degrade to non-veto for the run.
- **`accept veto:` reply without a reason** (e.g. just "accept veto"): orchestrator prompts again asking for a reason. Reasons are mandatory.

## See also

- [templates/alerts/veto-block.md](templates/alerts/veto-block.md) — full shape of the pre-summary veto block with single and multi-veto layouts.
- [templates/overview/panel-overview.md](templates/overview/panel-overview.md) — the `panel-overview` variants for `REJECT — veto pending`, `REJECT — 2 vetos pending`, and `HOLD†` with footnotes.
- [templates/overview/top-issues.md](templates/overview/top-issues.md) — the `← veto source` marker convention in the TOP block.
