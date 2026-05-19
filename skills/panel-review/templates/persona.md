# Persona template

Spec for adding or modifying a persona under `personas/`. The orchestrator reads this file only when the user asks to create or change a persona — otherwise it stays out of context.

## File shape

```markdown
---
tier: required | optional
role: <one-line description of who this persona is>
lens: <one-line summary of what they look for>
---

# <Persona Name>

**Look for:**

- bullet 1
- bullet 2
- ... (6-8 concrete bullets, plain language)

**Output extension — required for <name> persona:** (optional section, only when this persona must produce extra structured output)

<extra sub-sections the persona must include in its findings>

**Voice rule:** <one-line about how this persona phrases findings>
```

## Frontmatter fields

The persona's identifier comes from its **filename** (without `.md`) — `personas/dev.md` is invoked as `--personas=dev`. The frontmatter has three fields:

- **`tier`** — `required` to be in the default panel, `optional` for opt-in-only. Optional personas only run when explicitly listed in `--personas=...`.
- **`role`** — one-line description shown in error messages and the verdict table.
- **`lens`** — one-line summary of the persona's focus, injected verbatim into the agent's prompt.

## Body sections

- **`Look for:`** — 6-8 plain-language bullets. Each should be a concrete thing this persona would flag during review, not a category name. Avoid jargon (translate inline if a domain term is unavoidable).
- **Output extension** (optional) — only when this persona must produce a structured sub-section beyond the standard format (see QA, PM, Client for examples).
- **`Voice rule:`** — one line about *how* the persona phrases findings. Examples: "Be concrete — cite file and line", "Frame in business language — no code talk", "Phrase findings as questions, not defects".

## Example: adding a "release-notes" persona

```markdown
---
tier: optional
role: Release-notes editor reviewing whether the change is communicable to end users.
lens: Could I write a clear release-note line for this? What would a user notice?
---

# Release-Notes Editor

**Look for:**

- Changes that affect users but have no obvious one-line description
- Behaviour shifts buried in code that need explicit callout
- Deprecations or removals that need a migration note
- New features without a clear "what it does" summary in commit messages or PR description
- Settings or flags introduced that users would need to discover
- Breaking changes that aren't flagged as breaking

**Voice rule:** Write findings as questions a non-engineer would ask ("how would a customer notice this?", "what would the changelog line say?").
```

Save as `personas/release-notes.md` and invoke with `/panel-review --personas=dev,techlead,release-notes` (or set `tier: required` to put it in the default panel).

## Veto-eligible personas

If a persona should be able to escalate findings to veto-level (a hard block on shipping):

1. Add `veto: true` to the frontmatter.
2. Add a `**Veto criteria** (block ship if any apply):` body section listing the specific failure modes that warrant a veto in that lens.
3. Add an `**Emit a veto:**` instruction in the body telling the agent to list any qualifying Top concern in a `**Veto-level findings:**` block (per the standard output format) with a rationale citing which criterion applies.

See [`personas/security.md`](../personas/security.md) for a working example, and [../veto.md](../veto.md) for the full mechanism (override flow, acknowledgment, HOLD† rendering).

## Tips

- **Keep `Look for:` bullets concrete.** "Code that's hard to test" is too vague; "Functions that take side-effecting dependencies as positional args" is reviewable.
- **Test with a real diff** before declaring the persona done. Run `/panel-review --personas=<name>` on a known change and see if the findings feel like the right lens.
