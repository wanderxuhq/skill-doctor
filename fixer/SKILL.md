# Skill Fixer

Apply fixes to a skill package based on the Analyzer's bug report. Supports two fix modes. Default mode is **minimal**.

Read the anti-patterns at `.claude/skills/skill-doctor/references/anti-patterns.md` before starting.

## Fix Modes

The user (or coordinator) specifies the mode. If not specified, use **minimal**.

### Minimal Fix (default)

Fix only the reported bugs. The narrowest possible change.

- Change one line, not two
- Fix one bug, not its neighbors
- If a bug report item can be fixed with a single Edit, do that and move on
- Do NOT reword nearby text, reorganize sections, or "clean up while here"

Example:
- Bug: `scaffold.mjs:45` hardcodes `/tmp/out`
- Minimal fix: Change that one line to use a cross-platform temp directory
- Do NOT: Audit the rest of the file for similar issues

### Deep Fix

Fix the reported bug, then audit the **same file** (and related files in the same package) for identical patterns and fix those too. Still constrained by bug-fixing philosophy — deep mode is "fix all instances of the same bug class", not "improve everything you see."

Example:
- Bug: `scaffold.mjs:45` hardcodes `/tmp/out`
- Deep fix: Fix line 45, then search the entire file (and related scripts) for other hardcoded `/tmp` paths and fix all of them
- Do NOT: Fix unrelated style issues, missing error handling, or missing features you notice along the way

## Input

The Analyzer's bug report — a structured list of bugs with IDs, categories, locations, severities, descriptions, and suggested fixes.

If the user says "only fix critical" or "fix all high and above", respect that filter.

## Workflow

### Phase 1: Triage

1. Read the bug report
2. Determine the fix mode (minimal or deep)
3. Determine which bugs to fix:
   - If the user specifies a filter (e.g., "critical only"), apply it
   - If not specified, fix all **non-low** bugs (Critical, High, Medium)
   - Low-severity bugs are deferred by default — mention them in the summary
4. Sort bugs by severity (Critical first) and by file (group same-file fixes together to minimize edits)

### Phase 2: Apply Fixes

For each bug in order:

1. Read the file containing the bug to get current context
2. Apply the **minimal edit** using `Edit` tool
3. If in deep mode, search the same file and related files for the same bug pattern and fix those too
4. Mark the bug as [Fixed], [Skipped], or [Deferred]

**When to skip a fix:**
- The fix requires context or decisions only the user can make → [Skipped] with reason
- The fix would change the skill's intended behavior (not a clear bug) → [Skipped] with reason
- The fix requires tools not available → [Skipped] with reason

**When to defer:**
- Low-severity bugs (when not explicitly requested) → [Deferred]
- The fix would touch >5 files in a complex way → flag for user review

### Phase 3: Quick Self-Check

After each fix, quickly verify:
- The changed lines read correctly in context
- No obvious syntax errors introduced (unclosed quotes, missing brackets)
- The fix actually addresses the reported bug

## Output: Fix Summary

```
## Fix Summary: <skill-name>

Mode: minimal | deep
Bugs in report: N
Fixed: N | Skipped: N | Deferred: N

### Fixed
- ✅ [C1] <summary> @ <file>:<line> — <what was changed>
- ✅ [H1] <summary> @ <file>:<line> — <what was changed>

### Skipped
- ⚠️ [H1] <summary> — reason: <why>

### Deferred
- 📎 [L1] <summary> — low severity, can be handled manually

### Changes Made
| File | Lines Changed | Bugs Addressed |
|------|---------------|----------------|
| SKILL.md | L15, L42-L44 | C1, H1 |
| scripts/run.sh | L3 | H2 |
```

## Constraints

- **Only fix bugs from the report.** Never fix unreported issues, even if you notice them.
- **In minimal mode**, one bug = one edit. Do not batch unrelated fixes into a single edit.
- **In deep mode**, only extend to the same bug pattern — don't chase unrelated improvements.
- If unsure whether a bug should be fixed, skip it and flag for the user.
- After fixing, the Verifier will check your work. Don't try to verify exhaustively — that's the Verifier's job.
