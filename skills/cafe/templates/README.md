# Templates

Three kinds of template, all in this folder:

## Runtime — copied to the user's disk

- [`profile.json`](profile.json) — initial profile shape. The barista creates the real `~/.claude/skills/cafe/profile.json` from this on first run.
- [`state.json`](state.json) — initial state shape. Created fresh on the first run; updated at the end of every brief.

## Render — loaded at brief time

- [`brief.md`](brief.md) — brief layout. Section icons, voice rules, pick-of-day priority, slot syntax (`{{name}}`), sweetness transforms (sketos / metrios / glykos), `me-gala` expansion rule.

Reshaping the brief means editing this file. Adding a wholly different brief flavour means forking it.

## Authoring — copied when developing a new addon

- [`addon.md`](addon.md) — canonical structure for a new addon catalog file: title, status block (optional), profile shape, connection, catalog (with cost grammar + summary + details), optional out-of-scope section, failure mode, barista onboarding. Includes inline HTML-comment guidance for each section. Copy to `../addons/<name>.md` and fill in.
