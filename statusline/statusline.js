#!/usr/bin/env node
/**
 * Cross-platform custom status line for Claude Code.
 *
 * Reads the session JSON from stdin and prints a single line, e.g.:
 *   📁 forge  •  🌱 feature/x ↑2 ↓1 ●  •  @ 2h  •  .NET 10  •  ⬢ 20  •  🤖 Opus 4.8  •  💰 $0.42  •  📝 +120 -8  •  ⏱ 14m  •  🕐 14:32
 *
 * Everything is LOCAL + fast (git + a few file reads) — no network calls,
 * because the status line re-renders constantly.
 *
 * Wire it up in settings.json:
 *   "statusLine": { "type": "command", "command": "node /path/to/statusline.js" }
 *
 * Each segment only renders when it has data, so the line stays clean across
 * different project types.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// ---------- read the session JSON from stdin ----------
// readFileSync(0) can throw EAGAIN on a piped stdin (notably on Windows), so
// read in a loop that tolerates it rather than giving up on the first miss.
function readStdin() {
  const chunks = [];
  const buf = Buffer.alloc(65536);
  while (true) {
    let n;
    try {
      n = fs.readSync(0, buf, 0, buf.length, null);
    } catch (e) {
      if (e.code === 'EAGAIN') continue; // data not ready yet — retry
      break; // EOF or no stdin attached
    }
    if (n === 0) break;
    chunks.push(Buffer.from(buf.subarray(0, n)));
  }
  return Buffer.concat(chunks).toString('utf8');
}

let data = {};
try {
  // strip a leading BOM (some shells prepend one when piping) before parsing
  data = JSON.parse(readStdin().replace(/^﻿/, ''));
} catch {
  data = {};
}

// ---------- ANSI helpers ----------
const C = (code, text) => `\x1b[${code}m${text}\x1b[0m`;
const cyan = (t) => C('36', t);
const green = (t) => C('32', t);
const yellow = (t) => C('33', t);
const blue = (t) => C('34', t);
const magenta = (t) => C('35', t);
const red = (t) => C('31', t);
const dim = (t) => C('90', t);

// ---------- working directory ----------
const dir =
  data?.workspace?.current_dir || data?.cwd || process.cwd();
const projectDir = data?.workspace?.project_dir;

// project-relative path when we're inside the project, else just the leaf
let dirLabel = path.basename(dir) || dir;
if (projectDir && dir.startsWith(projectDir)) {
  const rel = path.relative(path.dirname(projectDir), dir);
  if (rel && !rel.startsWith('..')) dirLabel = rel.split(path.sep).join('/');
}

// ---------- git helpers ----------
const git = (args) => {
  try {
    return execSync(`git ${args}`, {
      cwd: dir,
      stdio: ['ignore', 'pipe', 'ignore'],
      encoding: 'utf8',
    }).trim();
  } catch {
    return '';
  }
};

const branch = git('rev-parse --abbrev-ref HEAD');
let dirty = false;
let ahead = 0;
let behind = 0;
let commitAge = '';

if (branch) {
  dirty = git('status --porcelain').length > 0;

  const upstream = git('rev-parse --abbrev-ref @{u}');
  if (upstream) {
    const counts = git('rev-list --left-right --count @{u}...HEAD');
    const m = counts.match(/(\d+)\s+(\d+)/);
    if (m) {
      behind = parseInt(m[1], 10);
      ahead = parseInt(m[2], 10);
    }
  }

  const committed = git('log -1 --format=%ct');
  if (committed) commitAge = relAge(parseInt(committed, 10) * 1000);
}

// git-flow badge from the branch name
function flowBadge(b) {
  if (/^feature\//.test(b)) return '🌱';
  if (/^release\//.test(b)) return '🚀';
  if (/^hotfix\//.test(b)) return '🔥';
  if (/^bugfix\//.test(b)) return '🐞';
  if (/^(develop|dev)$/.test(b)) return '🌲';
  return '🌿';
}

// ---------- generic toolchain detection (walk up to repo / fs root) ----------
function findUp(filename) {
  let p = dir;
  // stop after a sane number of hops to avoid runaway loops
  for (let i = 0; i < 40; i++) {
    const candidate = path.join(p, filename);
    if (fs.existsSync(candidate)) return candidate;
    const parent = path.dirname(p);
    if (parent === p) break;
    p = parent;
  }
  return null;
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8').replace(/^﻿/, ''));
  } catch {
    return null;
  }
}

const stacks = [];

// .NET — global.json pins a version; otherwise any .sln / .csproj nearby
const globalJson = findUp('global.json');
if (globalJson) {
  const g = readJson(globalJson);
  const v = g?.sdk?.version;
  stacks.push(v ? `.NET ${v.split('.').slice(0, 2).join('.')}` : '.NET');
} else if (hasFileMatching(dir, /\.(sln|slnx|csproj)$/)) {
  stacks.push('.NET');
}

// Node — version from .nvmrc, else engines.node, else bare
const pkgFile = findUp('package.json');
if (pkgFile) {
  const nvmrc = findUp('.nvmrc');
  let nodeVer = '';
  if (nvmrc) {
    try {
      nodeVer = fs.readFileSync(nvmrc, 'utf8').trim().replace(/^v/, '');
    } catch {}
  }
  if (!nodeVer) {
    const pkg = readJson(pkgFile);
    nodeVer = (pkg?.engines?.node || '').replace(/[^\d.]/g, '').split('.')[0] || '';
  }
  stacks.push(nodeVer ? `⬢ ${nodeVer}` : '⬢ node');
}

// Python — .python-version pins a version; else pyproject / requirements
const pyVerFile = findUp('.python-version');
if (pyVerFile) {
  let v = '';
  try {
    v = fs.readFileSync(pyVerFile, 'utf8').trim();
  } catch {}
  stacks.push(v ? `🐍 ${v}` : '🐍 py');
} else if (findUp('pyproject.toml') || findUp('requirements.txt')) {
  stacks.push('🐍 py');
}

// Rust
if (findUp('Cargo.toml')) stacks.push('🦀 rust');

// Go — go.mod has a "go 1.xx" directive
const goMod = findUp('go.mod');
if (goMod) {
  let v = '';
  try {
    const m = fs.readFileSync(goMod, 'utf8').match(/^go\s+(\d+\.\d+)/m);
    if (m) v = m[1];
  } catch {}
  stacks.push(v ? `🐹 go ${v}` : '🐹 go');
}

// ---------- model ----------
const model = data?.model?.display_name || 'Claude';

// ---------- session cost / lines / duration (from the JSON) ----------
const cost = data?.cost?.total_cost_usd;
const linesAdded = data?.cost?.total_lines_added || 0;
const linesRemoved = data?.cost?.total_lines_removed || 0;
const durationMs = data?.cost?.total_duration_ms;

// ---------- assemble ----------
const segments = [];

segments.push(cyan(`📁 ${dirLabel}`));

if (branch) {
  const badge = flowBadge(branch);
  let sync = '';
  if (ahead > 0) sync += ` ↑${ahead}`;
  if (behind > 0) sync += ` ↓${behind}`;
  const text = `${badge} ${branch}${sync}`;
  segments.push(dirty ? yellow(`${text} ●`) : green(text));
}

if (commitAge) segments.push(dim(`@ ${commitAge}`));

for (const s of stacks) segments.push(blue(s));

segments.push(magenta(`🤖 ${model}`));

if (typeof cost === 'number' && cost > 0) {
  segments.push(green(`💰 $${cost.toFixed(2)}`));
}

if (linesAdded > 0 || linesRemoved > 0) {
  segments.push(
    `📝 ${green('+' + linesAdded)} ${red('-' + linesRemoved)}`
  );
}

if (typeof durationMs === 'number' && durationMs > 0) {
  segments.push(dim(`⏱ ${fmtDuration(durationMs)}`));
}

segments.push(dim(`🕐 ${clock()}`));

process.stdout.write(segments.join(dim('  •  ')));

// ---------- small formatters ----------
function clock() {
  const d = new Date();
  return `${String(d.getHours()).padStart(2, '0')}:${String(
    d.getMinutes()
  ).padStart(2, '0')}`;
}

function relAge(thenMs) {
  const sec = Math.max(0, Math.floor((Date.now() - thenMs) / 1000));
  if (sec < 60) return 'now';
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h`;
  const day = Math.floor(hr / 24);
  if (day < 30) return `${day}d`;
  const mo = Math.floor(day / 30);
  if (mo < 12) return `${mo}mo`;
  return `${Math.floor(mo / 12)}y`;
}

function fmtDuration(ms) {
  const sec = Math.floor(ms / 1000);
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m`;
  const hr = Math.floor(min / 60);
  return `${hr}h${min % 60}m`;
}

function hasFileMatching(d, re) {
  try {
    return fs.readdirSync(d).some((f) => re.test(f));
  } catch {
    return false;
  }
}
