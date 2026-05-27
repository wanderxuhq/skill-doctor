# Skill Doctor

A self-hosted debugging pipeline for Claude Code skills. Runs **Scan → Analyze → Fix → Verify** against any skill package to find and fix bugs.

## Installation

clone it directly:

```
cd /path/to/your-project/.claude/skills/
git clone https://github.com/wanderxuhq/skill-doctor skill-doctor
```

It will appear as a slash command: `/skill-doctor`.

## Quick Start

```
/skill-doctor
```

It will ask which skill to debug and whether to use `minimal` (default) or `deep` fix mode. Then it runs the full pipeline automatically.

You can also specify everything inline:

```
/skill-doctor <skill-name> minimal
```

## Pipeline

| Phase | What it does | Sub-skill |
|-------|-------------|-----------|
| 1. Scan | Maps every file, classifies types, builds reference graph | `scanner/` |
| 2. Analyze | Finds bugs across 5 dimensions (validity, consistency, completeness, safety, reachability) | `analyzer/` |
| 3. Fix | Applies fixes — minimal (bug only) or deep (same bug class) | `fixer/` |
| 4. Verify | Confirms fixes worked, detects regressions, health check | `verifier/` |

If verification fails, the pipeline loops back through Scan → Analyze → Fix → Verify (up to 5 times).

## Directory Structure

```
skill-doctor/
  SKILL.md              Coordinator (entry point)
  scanner/SKILL.md      File discovery and structure mapping
  analyzer/SKILL.md     Bug detection across 5 dimensions
  fixer/SKILL.md        Bug fixing (minimal / deep)
  verifier/SKILL.md     Fix confirmation and regression detection
  references/           Shared reference docs (bug categories, severity scale, anti-patterns)
  scripts/              Utility scripts (YAML check, placeholder scan, bash lint)
```

## Fix Modes

- **minimal** (default): Fix only the reported bug. One line, one edit.
- **deep**: Fix the reported bug, then audit the same file for identical patterns and fix those too.

## Analysis Dimensions

The Analyzer checks every file against five dimensions:

1. **Validity** — Does it actually work? (syntax, parsing, broken code fences)
2. **Consistency** — Does it say the same thing everywhere? (no contradictions)
3. **Completeness** — Is everything that should be there, there? (references resolve, fields present)
4. **Safety** — Could this cause harm? (destructive ops, secrets exposure)
5. **Reachability** — Can everything be found and used? (no orphans, trigger accuracy)

## Bug Severity

| Level | Meaning |
|-------|---------|
| Critical | Skill cannot function — executor would fail or produce harmful output |
| High | Major workflow step broken, skill partially works |
| Medium | Edge case causes wrong behavior for some inputs |
| Low | Minor issue, unlikely to cause problems in practice |

Non-low bugs (Critical, High, Medium) are fixed by default. Low bugs are deferred unless explicitly requested.

## Edge Cases

- **Single SKILL.md** — works the same, just a smaller map
- **Skill collection** — cross-skill consistency is analyzed
- **Scan only** — runs Scan + Analyze, stops before Fix
- **Verify only** — jump to Analyze → Verify for already-applied fixes

## Constraints

- The coordinator routes work; it does not do deep analysis itself
- Sub-skills are internal — they live within this directory, not as standalone skills
- Data is passed whole between phases; never summarized or filtered
- The loop safeguard stops after 5 iterations to prevent infinite loops
