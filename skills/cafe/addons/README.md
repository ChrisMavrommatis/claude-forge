# Addons

One file per data-source / integration. Each addon owns its own top-level block in `profile.json` and its own runtime queries.

## Shipped

- [`ado.md`](ado.md) — Azure DevOps. PRs, work items, builds, iterations, releases. The brief's main data source.
- [`git.md`](git.md) — local git. Commits, branches, status, builds via repo CI. Default-on.
- [`m365.md`](m365.md) — Microsoft 365 (`claude.ai/Microsoft 365` connector). Email surface live (M365.1–M365.6); calendar / Teams / SharePoint surfaces visible on the connector and queued as future catalog entries under this same addon.

## Ideas for future addons

- `github.md` — GitHub PRs / issues for projects living outside ADO.
- `jira.md` — Jira issues / sprints when teams prefer it over ADO work items.
- `slack.md` — DM and mention digest, opt-in.

## Investigation passes

Each stub addon needs a focused investigation to upgrade it to a working adapter. One agent per addon — see the addon's own status block for what's known and what's pending.

- **m365 — calendar surface.** Investigate `outlook_calendar_search` + `find_meeting_availability` schemas. Catalog as M365.7+ under [`m365.md`](m365.md).
- **m365 — Teams chat surface.** Investigate `chat_message_search`. Catalog as additional M365-entries.
- **m365 — SharePoint surface.** Investigate `sharepoint_search` + `sharepoint_folder_search`. Catalog as additional M365-entries.

## Anatomy of an addon file

Each addon's catalog file (`<name>.md`) covers:

1. **Profile shape.** What the addon's top-level block in `profile.json` looks like.
2. **Connection.** How the addon reaches the source — MCP namespace probe / CLI / REST adapter / auth model.
3. **Catalog.** The full set of read-only calls this addon exposes. Includes a summary table (ID + Query + Size) and per-entry detail blocks (full `<size> · ~Xms · <scaling note>` + tool call + empty render). The catalog IS the safe-list — orchestrator and barista never improvise off-catalog calls.
4. **Failure mode.** How the addon degrades when offline / unauthorized / partial.
5. **Barista onboarding.** Which questions the barista asks to populate the addon's profile block.

Each addon's catalog file declares its own "Defaults" section — whether the addon is enabled in a fresh profile and which catalog calls come on automatically. The barista reads these at onboarding to seed the profile.

Adding a new addon:

1. Copy [`../templates/addon.md`](../templates/addon.md) to `<name>.md` (here in `addons/`), fill in.
2. Add a "Defaults" subsection listing which catalog IDs are default-on and whether the addon is default-on in a fresh profile.
3. Update `barista.md` to reference the addon's onboarding questions.

See [`../templates/addon.md`](../templates/addon.md) for the canonical starting point with inline guidance for each section.
