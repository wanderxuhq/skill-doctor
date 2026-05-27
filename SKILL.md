---
name: skill-doctor
description: Debug and fix bugs in skill packages. Use when the user asks to "debug this skill", "fix skill bugs", "find bugs in skill", "skill has a bug", "diagnose skill", "check skill package", "skill not working", or wants to verify a skill works correctly. Handles any skill type — single SKILL.md files, multi-file packages, skills with scripts/templates, or collections of collaborating skills.
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill Doctor

Diagnose and fix bugs in **any** skill package through a generic 4-phase pipeline: **Scan → Analyze → Fix → Verify**.

This is the coordinator. It routes work to four sub-skills and controls the Analyze→Fix→Verify loop. On verification failure, it loops back through Scan→Analyze→Fix→Verify. It does NOT do deep analysis itself.

Sub-skills (nested in this skill's directory):
- `scanner/` — load and map the target skill package
- `analyzer/` — deep analysis, find all bugs
- `fixer/` — apply fixes (minimal or deep mode)
- `verifier/` — verify fixes, detect regressions

Utility scripts (in `scripts/`):
- `check-yaml.sh` — validate YAML frontmatter of a SKILL.md
- `check-placeholders.sh` — find unreplaced `{{...}}` markers in a directory
- `lint-bash.sh` — syntax-check all `.sh` files in a directory

## When to Use This Skill Directly

This skill triggers on broad skill-debugging requests. It should be used as the entry point.

If the user's request is clearly scoped to one phase (e.g., "just scan this skill"), you can `Read` the relevant sub-skill's SKILL.md directly and follow only that phase. Otherwise, run the full pipeline.

## Pipeline

### Step 0: Onboarding

Ask the user two things if not already clear:

1. **Which skill to debug?** The skill name or directory path.
2. **Fix mode?** `minimal` (default) or `deep`. If not specified, use minimal.

Locate the target skill:
- Check `.claude/skills/<name>/` for project skills
- Check user-specified path
- If not found, report and stop

### Step 1: Scan

Load the Scanner sub-skill:

> `Read` the instructions at `scanner/SKILL.md`, then follow them to scan the target skill path. Produce a **Structure Map**.

The Structure Map is the foundation for everything that follows.

### Step 2: Analyze

Load the Analyzer sub-skill:

> `Read` the instructions at `analyzer/SKILL.md`, then follow them with the Structure Map from Step 1. Produce a **Bug Report**.

If the Bug Report shows 0 bugs, skip to Step 5 (Final Report) — the skill is clean, no fixing needed.

### Step 3: Fix

Load the Fixer sub-skill:

> `Read` the instructions at `fixer/SKILL.md`, then follow them with the Bug Report from Step 2 and the fix mode (`minimal` or `deep`). Produce a **Fix Summary**.

### Step 4: Verify

Load the Verifier sub-skill:

> `Read` the instructions at `verifier/SKILL.md`, then follow them with the original Bug Report and the Fix Summary. Produce a **Verification Report**.

Read the Conclusion in the Verification Report:

- **PASSED** → Go to Step 5 (Final Report). The pipeline is complete.
- **FAILED** → Go back to Step 1 to re-scan the target skill (producing a fresh Structure Map), then Step 2 (Analyze) with both the fresh Structure Map and the Verification Report. The Analyzer re-examines unresolved bugs and regressions, producing an updated Bug Report. Then Fixer → Verifier again. Loop until PASSED.

**Loop safeguard:** If the pipeline has looped 5 times without PASSED, stop and present the full history to the user. Something is fundamentally wrong — don't loop indefinitely.

### Step 5: Final Report

Synthesize all outputs into a final summary:

```
## Skill Doctor: Final Report for `<skill-name>`

### Pipeline Summary
- Scanned: N files, M types
- Analyzed: N bugs found (C: X, H: Y, M: Z, L: W)
- Fixed: N bugs (mode: minimal|deep)
- Verified: PASSED after N iteration(s)

### Changes Made
| File | Change |
|------|--------|
| <file> | <what changed> |

### Remaining
- Deferred: N low-severity bugs (see Bug Report)
- Skipped: N bugs requiring user decision (see Fix Summary)

### Verdict
<skill-name> is clean. All fixable bugs resolved, no regressions.
```

If 0 bugs were found initially:
```
## Skill Doctor: Final Report for `<skill-name>`

Scanned: N files. Bugs found: 0.
No bugs found. The skill is clean.
```

## Coordinating Sub-Skills

### How to Load Sub-Skills

Use `Read` to load the sub-skill instructions from this skill's directory:
- `scanner/SKILL.md` — scanning and mapping
- `analyzer/SKILL.md` — deep analysis and bug finding
- `fixer/SKILL.md` — applying fixes
- `verifier/SKILL.md` — verifying fixes and detecting regressions

Each sub-skill is self-contained within the `skill-doctor/` directory. When you load one, follow its instructions with the provided context:

**For Scanner:** "Scan the skill at `<path>`. Produce a complete structure map."

**For Analyzer:** "Analyze this skill. Here is the Structure Map: `<map>`. Find all bugs."

**For Fixer:** "Fix the bugs in this Bug Report using `<minimal|deep>` mode. Here is the report: `<report>`."

**For Verifier:** "Verify the fixes. Original Bug Report: `<report>`. Fix Summary: `<summary>`."

### Data Flow Between Sub-Skills

```
Scanner → Structure Map → Analyzer → Bug Report → Fixer → Fix Summary → Verifier → Verification Report
                                                                                              │
                                                                              ┌───────────────┘
                                                                              ▼ FAILED
                                                              Back to Scanner → Analyzer
                                                                              │
                                                                              ▼ PASSED
                                                                        Final Report
```

Each sub-skill's output is the next sub-skill's input. Pass the full output — don't summarize or filter. The sub-skill knows how to parse it.

## Edge Cases

**Target is a single SKILL.md file (not a package):**
The pipeline works the same way. Scanner will produce a small map, Analyzer will focus on SKILL.md content. The generic dimensions (validity, consistency, completeness, safety, reachability) all apply.

**Target is a collection of skills (package like plugin-dev):**
Scanner maps all of them. Analyzer analyzes cross-skill consistency. Fixer fixes across the package. Verifier checks the whole package.

**User only wants to scan, not fix:**
Run only Step 1 (Scanner) and Step 2 (Analyzer). Present the Bug Report. Stop before Step 3.

**User wants to verify a specific fix:**
Jump to Step 2 (Analyzer) with context about the fix, then Step 4 (Verify). Skip Fixer if fixes are already applied. Before Step 4, construct a minimal Fix Summary from the known fixes (list each fix with file, line, and what changed) — the Verifier needs it for fix confirmation.

## Constraints

- **Route, don't analyze.** The coordinator's job is pipeline control, not deep debugging. Trust the sub-skills.
- **Don't skip the loop.** If Verifier says FAILED, always go back. The only valid exit is PASSED or 0 bugs.
- **Pass data whole.** Don't summarize sub-skill outputs when passing to the next sub-skill.
- **Sub-skills are internal.** They live under `scanner/`, `analyzer/`, `fixer/`, `verifier/` within this skill's directory. They don't depend on any external skills.
