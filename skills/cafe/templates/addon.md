# Addon — {{NAME}}

One-line description of what this addon connects to and the kind of data it surfaces in the brief.

<!--
  Drop this status block when the addon is fully live.
  Keep it whenever any part is stubbed (no real adapter, inferred tool names, etc.).
-->
> **Status — {{live | stub | partial}}.** {{One paragraph: what's wired, what's pending, what the brief shows when offline.}}

## Profile shape

Top-level `{{name}}` block in `profile.json`:

```json
{
  "{{name}}": {
    "{{field}}": "{{example}}",
    "{{nested}}": [
      { "{{key}}": "{{value}}" }
    ]
  }
}
```

- `{{field}}` — what it is, default behavior, required vs optional.
- `{{nested}}[]` — shape + meaning per entry.

## Connection

How the addon reaches the data source: MCP namespace probe / CLI invocation / REST adapter / OAuth flow.

<!--
  Pick the relevant pattern:
  - MCP: probe namespace `mcp__<vendor>__*`. State the failure mode if absent.
  - CLI: shell-portability note. Avoid Unix-only pipes inside commands; parse in the orchestrator.
  - REST adapter: auth model + token storage location.
  - Stub: state explicitly that there's no real adapter yet; link to investigation pass in `.plans/`.
-->

Throughout this catalog, {{any namespace prefix or shared invocation context}} is implied — `<short>` means `<full>`.

## Catalog

The full set of read-only calls this addon exposes. See [Defaults](#defaults) below for which entries come on automatically. The orchestrator may issue any catalog entry on demand; anything not in the default set requires explicit opt-in via the barista.

**Cost grammar.** The summary table carries only the **size** (XS / S / M / L / XL) for at-a-glance triage. The full cost — `<size> · ~Xms · <scaling note>` — lives in each entry's detail block:
- **Size** — t-shirt class for the at-a-glance feel.
- **~Xms** — per-call wall-time estimate. Total brief cost is summed across active calls; must stay under `profile.preferences.budget_ms`.
- **Scaling note** — how the call grows with config (`per repo`, `per project`, `parallel`, `paginated`, etc.).

<!-- If ms estimates are speculative (e.g. stub addon, inferred tool names), note that here. -->

Placeholders (used in queries below):
- `${currentUser}` — from `profile.identity.{{name}}.email` (or another identity field).
- `${state.last_run}` — from `state.json`.
- `${each_other_placeholder}` — document its source.

### Summary

Every catalog entry MUST fill all five columns. They are mandatory, not optional:
- **ID** — stable prefix-unique identifier (e.g. `XYZ.1`, `XYZ.2`).
- **What it does** — one-sentence plain-English description of what the call actually returns, in real-user terms. Not the tool name; not a noun phrase. Answer "what does this give me?"
- **When it matters** — a short rationale or quoted user-thought explaining why someone would turn this on. The "so what?" angle.
- **Default** — `✅` if the entry appears in this addon's `## Defaults` table (default-on in a fresh profile), `⛔` if it's opt-in, `—` for backlog/undefined entries. Cross-check against `## Defaults` below — don't make it up.
- **Size** — t-shirt class (`XS` / `S` / `M` / `L` / `XL`) from the per-entry detail block.

| ID        | What it does                                  | When it matters                                | Default | Size |
| --------- | --------------------------------------------- | ---------------------------------------------- | ------- | ---- |
| {{XYZ.1}} | {{one-line plain-English description}}        | {{when this call matters to a user}}           | ✅      | XS   |
| {{XYZ.2}} | {{another}}                                   | {{another}}                                    | ⛔      | M    |

### Details

<!--
  One block per catalog entry, matching the order in the summary table.
  Keep each block under ~10 lines: cost, one-line description, code block, empty render.
-->

#### {{XYZ.1}} — {{Query name}}

**Cost:** {{size}} · ~{{X}}ms · {{scaling note}}.

{{One- or two-sentence description: what the query returns, when it's useful.}}

```
{{exact tool call or command, with ${placeholders}}}
```

Empty render: *"{{what the brief shows when this returns nothing}}"*

<!-- Repeat per query. Keep IDs prefix-unique across all catalog files (ADO.1..ADO.18 for ado, GIT.1..GIT.11 for git, etc.). -->

## Defaults

When this addon is enabled, these catalog calls come on automatically. Toggle individual calls via `/cafe barista calls`.

| ID        | Call                                     | Why default                                                  |
| --------- | ---------------------------------------- | ------------------------------------------------------------ |
| {{XYZ.1}} | {{Call name}}                            | {{One-line rationale.}}                                      |

**Enabled in a fresh profile:** {{yes | no}} — {{if yes, a barista interview seeds a `{{name}}` block by default; if no, opt-in via the optional-addons offer at first run, or `/cafe barista add {{name}}`}}.

**Notable opt-ins:** {{ID}} ({{why interesting but not default}}), {{ID}} ({{...}}).

<!--
  OPTIONAL section. Include ONLY when the addon investigation surfaced
  capabilities that belong in a *different* future addon (e.g. the email
  investigation found calendar + tasks tools that don't fit the email
  addon). List them here so they're not forgotten and so addon boundaries
  stay explicit. Omit this section entirely if not applicable.

## Out of scope for this addon

These came up in the investigation but belong in separate future addons:

- **{{capability}}** ({{tool reference}}) — why it's separate. Future `addons/<other-name>.md`.

See `.plans/` backlog.
-->

## Failure mode

How the addon degrades when it can't deliver. Each row: a condition → what the brief does + the header note shown.

- **{{condition 1}}** → drop / partial render / header note `⚠ {{addon-name}}: ...`.
- **{{condition 2}}** → ...

Per [SKILL.md](../SKILL.md), failures must be visible in the brief header — never silent.

## Barista onboarding

Questions the barista asks when this addon is plausibly in use (default-on per the Defaults section above, OR user opt-in):

1. *"{{question 1}}"* — {{what it sets in the profile; how to suggest a default value (e.g. from disk scan, from another addon's data, etc.)}}.
2. *"{{question 2}}"* — {{...}}.

If the user declines the addon, the barista omits its profile block entirely.

---

<!--
  After writing this catalog file:

  1. Fill in the "Defaults" section above:
       - Whether the addon is default-on in a fresh profile
       - Which catalog IDs default-on, with one-line rationale
       - Notable opt-ins (catalog entries that are useful but not default)

  2. Update barista.md to reference this addon's onboarding questions when
     it's plausibly in use.
-->
