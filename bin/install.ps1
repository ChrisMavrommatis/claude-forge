<#
.SYNOPSIS
  Install claude-forge skills into ~/.claude/skills/, honoring each skill's .skillignore.

.DESCRIPTION
  Copies skills/<name>/ into the Claude skills directory, dropping any file whose
  name matches a glob in that skill's .skillignore (e.g. AGENT.md, README.md).
  The .skillignore file itself and any .plans/ scratch directories are always
  excluded — they have no runtime purpose.

.PARAMETER Name
  One or more skill names to install (folder names under skills/). Ignored with -All.

.PARAMETER All
  Install every skill under skills/.

.PARAMETER List
  List available skills and exit.

.PARAMETER DryRun
  Show what would be copied and skipped, without writing anything.

.PARAMETER Force
  Overwrite an existing installed skill. Without it, an already-installed skill is left alone.

.PARAMETER Dest
  Destination skills directory. Defaults to ~/.claude/skills.

.EXAMPLE
  ./install.ps1 -List
.EXAMPLE
  ./install.ps1 panel-review -DryRun
.EXAMPLE
  ./install.ps1 -All -Force
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $Name,
    [switch] $All,
    [switch] $List,
    [switch] $DryRun,
    [switch] $Force,
    [string] $Dest
)

$ErrorActionPreference = 'Stop'

$repoRoot  = Split-Path $PSScriptRoot -Parent
$skillsDir = Join-Path $repoRoot 'skills'

if (-not $Dest) {
    $Dest = Join-Path $env:USERPROFILE '.claude\skills'
}

function Get-AvailableSkills {
    Get-ChildItem -Path $skillsDir -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
        Select-Object -ExpandProperty Name |
        Sort-Object
}

# Read a skill's .skillignore into a list of file-name glob patterns.
function Get-IgnorePatterns([string] $skillPath) {
    $file = Join-Path $skillPath '.skillignore'
    if (-not (Test-Path $file)) { return @() }
    Get-Content $file |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne '' -and -not $_.StartsWith('#') }
}

# True if a file should be excluded from the install.
function Test-Excluded([string] $relPath, [string] $fileName, [string[]] $patterns) {
    # .plans/ scratch dirs and .skillignore itself never ship.
    if ($relPath -split '[\\/]' -contains '.plans') { return $true }
    if ($fileName -eq '.skillignore') { return $true }
    foreach ($p in $patterns) {
        if ($fileName -like $p) { return $true }
    }
    return $false
}

$available = @(Get-AvailableSkills)

if ($List) {
    Write-Host "Available skills:"
    $available | ForEach-Object { Write-Host "  $_" }
    return
}

# Resolve which skills to install.
if ($All) {
    $targets = $available
} elseif ($Name) {
    $targets = $Name
} else {
    Write-Host "Usage: install.ps1 <skill> [<skill>...] | -All | -List   [-DryRun] [-Force] [-Dest <path>]"
    Write-Host ""
    Write-Host "Available skills:"
    $available | ForEach-Object { Write-Host "  $_" }
    return
}

foreach ($skill in $targets) {
    if ($available -notcontains $skill) {
        Write-Warning "skip '$skill' - no such skill under skills/ (try -List)"
        continue
    }

    $srcRoot   = Join-Path $skillsDir $skill
    $destRoot  = Join-Path $Dest $skill
    $patterns  = @(Get-IgnorePatterns $srcRoot)

    $files = Get-ChildItem -Path $srcRoot -Recurse -File
    $copy  = New-Object System.Collections.Generic.List[object]
    $skip  = New-Object System.Collections.Generic.List[string]

    foreach ($f in $files) {
        $rel = $f.FullName.Substring($srcRoot.Length).TrimStart('\', '/')
        if (Test-Excluded $rel $f.Name $patterns) {
            $skip.Add($rel)
        } else {
            $copy.Add([pscustomobject]@{ Full = $f.FullName; Rel = $rel })
        }
    }

    if ($DryRun) {
        Write-Host "[dry-run] $skill -> $destRoot"
        Write-Host "  would copy $($copy.Count) file(s)"
        if ($skip.Count -gt 0) {
            Write-Host "  would skip: $($skip -join ', ')  (per .skillignore)"
        }
        continue
    }

    if ((Test-Path $destRoot) -and -not $Force) {
        Write-Warning "skip '$skill' - already installed at $destRoot (pass -Force to overwrite)"
        continue
    }

    if (Test-Path $destRoot) { Remove-Item $destRoot -Recurse -Force }
    New-Item -ItemType Directory -Path $destRoot -Force | Out-Null

    foreach ($item in $copy) {
        $target    = Join-Path $destRoot $item.Rel
        $targetDir = Split-Path $target -Parent
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        Copy-Item -Path $item.Full -Destination $target -Force
    }

    Write-Host "installed $skill -> $destRoot  ($($copy.Count) files, $($skip.Count) skipped)"
}
