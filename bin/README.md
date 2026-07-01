# bin

Install scripts for copying skills out of this repo into your Claude Code
skills directory. Two equivalent implementations — use whichever matches your
shell:

| Script        | Platform        |
| ------------- | --------------- |
| `install.ps1` | Windows (PowerShell) |
| `install.sh`  | Linux / Mac (bash)   |

Both do the same thing: copy `skills/<name>/` into `~/.claude/skills/<name>/`,
dropping any file whose name matches a glob in that skill's `.skillignore`.

## What gets left out

A skill's `.skillignore` lists dev-facing files that should not ship at
runtime (typically `AGENT.md` and `README.md`). The installer honours it, and
always also excludes:

- the `.skillignore` file itself, and
- any `.plans/` scratch directory (gitignored, local-only).

So an installed skill contains just what the skill engine loads — no
orientation docs, no scratch notes.

## Usage

```powershell
# Windows (PowerShell)
bin\install.ps1 <skill> [<skill> ...]   # install named skills
bin\install.ps1 -All                    # install every skill
bin\install.ps1 -List                   # list available skills
```

```bash
# Linux / Mac (bash)
bin/install.sh <skill> [<skill> ...]    # install named skills
bin/install.sh --all                    # install every skill
bin/install.sh --list                   # list available skills
```

### Flags

| PowerShell      | bash          | Effect                                                      |
| --------------- | ------------- | ----------------------------------------------------------- |
| `-DryRun`       | `--dry-run`   | Show what would be copied and skipped; write nothing.       |
| `-Force`        | `--force`     | Overwrite an already-installed skill (otherwise it's left alone). |
| `-Dest <path>`  | `--dest <path>` | Destination skills dir. Default: `~/.claude/skills`.      |

A `-DryRun` preview looks like:

```text
[dry-run] panel-review -> ~/.claude/skills/panel-review
  would copy 23 file(s)
  would skip: .skillignore, AGENT.md, README.md, .plans/output-design.md  (per .skillignore)
```

## Manual copy

If you'd rather not use the script, copy the folder and delete the
dev-facing files afterwards:

```bash
cp -r skills/panel-review ~/.claude/skills/
rm ~/.claude/skills/panel-review/AGENT.md ~/.claude/skills/panel-review/README.md
```

## Re-installing after an edit

Skills are copied, not linked — editing a skill in this repo does not update an
installed copy. Re-run the installer with `-Force` / `--force` to refresh it.
