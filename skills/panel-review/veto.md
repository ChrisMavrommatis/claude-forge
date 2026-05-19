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

When one or more unacknowledged vetos fire, render this at the TOP of the report, before the banner. One block per veto:

```
╔════════════════════════════════════════════════════════════════╗
║  [!] VETO  ·  <PERSONA> says this should not ship              ║
╚════════════════════════════════════════════════════════════════╝

  Finding:
    <finding name> (<file:line if available>)

  Why this is veto-level in the <persona-name> lens:
    <persona's veto rationale, verbatim from Veto-level findings>

  To proceed, choose one:
    - Fix the issue and rerun.
    - Override by replying:  accept veto: <your reason in one line>
    - Or pass --accept-veto="<reason>" on the next invocation.

  Until acknowledged, OVERALL stays REJECT.
```

If multiple vetos fire, stack blocks in the standard panel order (required personas first, then optional, then custom alphabetical), and within a persona, in the order findings appeared in their Top concerns list.

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

When all vetos are acknowledged, the OVERALL line in the summary becomes:

```
OVERALL: HOLD†  (<N> HOLD · <N> SHIP · <N> REJECT · <K> veto acknowledged)
                † <persona1>'s veto on <finding1> accepted by user:
                  "<reason1>"
                † <persona2>'s veto on <finding2> accepted by user:
                  "<reason2>"
```

The `†` marker MUST appear on the verdict line. Each acknowledged veto gets a footnote with the persona's name, finding, and the user's reason.

## --accept-veto no-op

If `--accept-veto="<reason>"` is passed but no veto fires, silently ignore it — no warning, no error, no "nothing happened" message.

## Edge cases

- **All veto-eligible personas FAILED**: no veto can fire; verdict per normal rule. (Other personas' verdicts still count.)
- **One veto-eligible persona failed, others ran**: the failed one can't veto (no output to scan). Other veto personas still fire normally.
- **One veto-eligible persona ran, no veto-level findings**: behaves as a normal persona.
- **Veto-eligible persona has empty Veto criteria section**: treat as malformed; warn and degrade to non-veto for the run.
- **`accept veto:` reply without a reason** (e.g. just "accept veto"): orchestrator prompts again asking for a reason. Reasons are mandatory.
