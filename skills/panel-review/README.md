# panel-review

Multi-persona review of a code change. Dispatches several role-based
review agents in parallel — Dev, Tech Lead, QA, PM, Client, Junior by
default; Security / DevOps / Accessibility / Performance / Contract as
opt-ins — and consolidates their findings into one verdict. The
strongest signal is **convergence**: anything flagged by 2+ personas is
almost always real.

## Quick start

```bash
/panel-review                              # working-tree diff, default panel
/panel-review range:main..HEAD             # commit range
/panel-review --personas=dev,security      # custom subset (security is opt-in)
/panel-review --details --model=opus       # full detail, Opus for high-stakes
/panel-review --explain DEV                # drill into one persona post-review
```

Full invocation, target types, and flags: [SKILL.md](SKILL.md).

## What it looks like

The summary screen on a typical HOLD:

```text
╭─────────────────────────────────────────────────────────────╮
│  PANEL REVIEW                                               │
│  range:main..HEAD  ·  18 files  ·  6 personas               │
│                                                             │
│  VERDICT:  HOLD                                             │
│  4 SHIP  ·  2 HOLD  ·  0 REJECT                             │
╰─────────────────────────────────────────────────────────────╯


  PERSONA      VERDICT     REASON
  ─────────────────────────────────────────────────────────────
  DEV          ▸ HOLD      rounding bug blocks ship
  TECH LEAD    ✓ SHIP      ships, but null guard worth fixing
  QA           ▸ HOLD      need test for rounding edge first
  PM           ✓ SHIP      scope matches the ticket
  CLIENT       ✓ SHIP      end-to-end story still works
  JUNIOR       ✓ SHIP      readable; one naming question


  TOP ISSUES — caught by 2+ personas
  ─────────────────────────────────────────────────────────────

  [BLOCK] Discount rounding overcharges by 1¢ on odd totals
  * BY: Dev, QA
       ·  src/orders/OrderService.cs:42
       >  Math.Floor(total * discount * 100) / 100  — truncates third decimal
  [DEFER] Null-guard missing on optional address line — could NPE on imports
  * BY: Dev, Tech Lead
       ·  src/orders/AddressMapper.cs:88


  Want details? Reply with:
    - "all"        — show all per-persona cards
    - "<PERSONA>"  — drill into one persona (e.g. "DEV")
    - "no"         — done
```

Four glyphs carry the TOP block: `[` opens a new issue, `*` names the
personas, `·` points at a file:line, `>` carries a code excerpt or fix
note.

## What you get

| Always              | What it shows                                                                       |
| ------------------- | ----------------------------------------------------------------------------------- |
| Verdict             | One overall **SHIP / HOLD / REJECT** for the whole panel.                           |
| Verdict table       | Each persona's vote and a one-line reason.                                          |
| TOP issues          | Up to 3 most severe convergent findings (caught by 2+ personas), tagged by severity. Absent when there's nothing to surface — no "(none found)" placeholder. |

| On request          | What it shows                                                                       |
| ------------------- | ----------------------------------------------------------------------------------- |
| Per-persona details | One section per persona — Lens, Good / Issues, unique findings, open questions, role-specific extensions (QA test gaps, PM scope coverage, Client customer-support / admin / risks / trade-offs). |
| Drill-in            | Reply with a persona name (or `--explain <PERSONA>`) to re-run that single persona on Opus for deeper analysis. |

## File layout

```text
panel-review/
├── SKILL.md                    core spec, always loaded
├── personas/                   one .md per persona — the lenses the panel uses
├── details.md                  per-persona section rendering + drill-in
├── failure.md                  failure rendering + abort (one or all)
├── veto.md                     veto mechanism + override flow
├── templates/
│   ├── overview/               panel-overview, verdict-table, top-issues
│   ├── details/                persona-card, drill-in-card
│   ├── alerts/                 veto-block, panel-failed, size-guard
│   └── persona.md              authoring template for new personas
├── AGENT.md                    orientation for Claude when picking the skill up cold
└── README.md                   you are here
```

Optional features lazy-load — they only get read when their trigger
condition is met, so the always-on context stays small.

## Customising the panel

- **Add a persona** — drop a `.md` file in `personas/`. See [templates/persona.md](templates/persona.md) for the file shape and a worked example.
- **Make a persona a veto gate** — add `veto: true` to its frontmatter plus a `Veto criteria` section listing specific failure modes. See [veto.md](veto.md).
- **Run only some personas** — `--personas=dev,client` overrides the default panel.
- **Change models per run** — `--model=opus|sonnet|haiku` (defaults to Sonnet).

The skill ships with two veto-eligible personas, `security` and
`contract` (external API / schema / migration compatibility), both
`tier: optional` — neither is on the default panel. To enable veto
behaviour, add them explicitly, e.g.
`/panel-review --personas=dev,techlead,qa,pm,client,security,contract`.
Other personas can be made veto-eligible by editing their files (see
[veto.md](veto.md)). `contract`'s veto-eligibility is a provisional
call, flagged in the file to revisit.

## Design principles

1. **Lightweight by default.** Only the core spec loads every run.
   Optional behaviour (details, failure, veto, authoring, alerts)
   lazy-loads.
2. **Plain language always.** Findings must be readable by someone
   outside the persona's specialty — no jargon without an inline
   definition.
3. **Convergence beats authority.** What multiple lenses agree on
   matters more than any single persona's strong opinion.
4. **One bordered box only.** Just `panel-overview` at the top of
   summary screens. Every other section uses heading + horizontal
   rule + indented content — robust across narrow terminals.
5. **Read-only.** The skill produces findings; humans decide what to
   do with them. The skill never edits code, never commits, never
   auto-merges.

## Install

From the repo root, using the installer in [`bin/`](../../bin/README.md):

```bash
# Linux / Mac
bin/install.sh panel-review

# Windows (PowerShell)
bin\install.ps1 panel-review
```

It honours this skill's `.skillignore`, so `AGENT.md` and `README.md` are left
out of the runtime copy. See the parent [README](../../README.md) for
repo-level context.
