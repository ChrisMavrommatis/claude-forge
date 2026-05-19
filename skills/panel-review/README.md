# panel-review

Multi-persona review of a code change. Dispatches several role-based review agents in parallel — Dev, Tech Lead, QA, PM, Client by default; Security / DevOps / Junior / Accessibility / Performance as opt-ins — and consolidates their findings into one verdict. The strongest signal is **convergence**: anything flagged by 2+ personas is almost always real.

## Quick start

```bash
/panel-review                                # working-tree diff, default panel
/panel-review range:main..HEAD               # commit range
/panel-review --personas=dev,security        # custom subset (security is opt-in)
/panel-review --details --model=opus         # full detail, Opus for high-stakes
/panel-review --explain DEV                  # drill into one persona post-review
```

Full invocation, target types, and flags: [SKILL.md](SKILL.md).

## What you get

| Always              | What it shows                                                                       |
| ------------------- | ----------------------------------------------------------------------------------- |
| Verdict             | One overall **SHIP / HOLD / REJECT** for the whole panel.                           |
| Verdict table       | Each persona's vote and a one-line reason.                                          |
| TOP issues          | Up to 3 most severe convergent findings (caught by 2+ personas), tagged by severity. |

| On request          | What it shows                                                                       |
| ------------------- | ----------------------------------------------------------------------------------- |
| Per-persona details | One card per persona — Good / Issues, unique findings, open questions, role-specific extensions (QA test gaps, PM scope coverage, Client readiness). |
| Drill-in            | `--explain <persona>` re-runs that single persona on Opus for deeper analysis.      |

## File layout

```
panel-review/
├── SKILL.md                 core spec, always loaded
├── personas/                one .md per persona — the lenses the panel uses
├── details.md               per-persona card rendering + drill-in (loaded on --details / --explain)
├── failure.md               failure rendering + abort (loaded when a persona errors)
├── veto.md                  veto mechanism + override flow (loaded when a veto:true persona is on the panel)
├── templates/persona.md     authoring template (loaded when adding/changing a persona)
└── README.md                you are here
```

Optional features lazy-load — they only get read when their trigger condition is met, so the always-on context stays small.

## Customising the panel

- **Add a persona** — drop a `.md` file in `personas/`. See [templates/persona.md](templates/persona.md) for the file shape and a worked example.
- **Make a persona a veto gate** — add `veto: true` to its frontmatter plus a `Veto criteria` section listing specific failure modes. See [veto.md](veto.md).
- **Run only some personas** — `--personas=dev,client` overrides the default panel.
- **Change models per run** — `--model=opus|sonnet|haiku` (defaults to Sonnet).

The skill ships with `security` as the only veto-eligible persona, but `security` is `tier: optional` — it's not on the default panel. To enable veto behaviour, add it explicitly: `/panel-review --personas=dev,techlead,qa,pm,client,security`. Other personas can be made veto-eligible by editing their files (see [veto.md](veto.md)).

## Design principles

1. **Lightweight by default.** Only the core spec loads every run. Optional behaviour (details, failure, veto, authoring) lazy-loads.
2. **Plain language always.** Findings must be readable by someone outside the persona's specialty — no jargon without an inline definition.
3. **Convergence beats authority.** What multiple lenses agree on matters more than any single persona's strong opinion.
4. **Read-only.** The skill produces findings; humans decide what to do with them. The skill never edits code, never commits, never auto-merges.

## Install

The skill lives in this repo. Until the repo's installer lands, copy it manually into `~/.claude/skills/`:

```bash
# Linux / Mac
cp -r skills/panel-review ~/.claude/skills/

# Windows (PowerShell)
Copy-Item -Recurse skills\panel-review $env:USERPROFILE\.claude\skills\
```

See the parent [README](../../README.md) for repo-level context.
