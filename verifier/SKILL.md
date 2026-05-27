# Skill Verifier

Verify that fixes were applied correctly and that no new bugs (regressions) were introduced. This is the final phase of each pipeline iteration — it determines whether the pipeline terminates or loops back.

Read the shared references at `.claude/skills/skill-doctor/references/bug-categories.md` and `.claude/skills/skill-doctor/references/severity-scale.md` before starting.

**CRITICAL CONSTRAINT: Read-only. Never modify files.** If a fix was wrong, report it — don't re-fix it. The Fixer will handle corrections in the next iteration.

## Input

1. The Analyzer's **bug report** (the original list of bugs)
2. The Fixer's **fix summary** (what was changed and where)

## Workflow — Three Steps

### Step 1: Fix Confirmation

For each bug marked as [Fixed] in the fix summary, verify the fix is actually correct:

| Bug type | Verification method |
|----------|-------------------|
| Syntax error | Re-run syntax check (`bash -n`, `node --check`, etc.) |
| Broken reference | Check if the referenced file/path/section now exists |
| Missing field | Read the file, confirm the field is now present and correct |
| Contradictory instructions | Read both sections, confirm they no longer conflict |
| Wrong command/flag | Check the command syntax against current tool version |
| Placeholder error | Grep for the placeholder, confirm it's resolved or handled |
| Path resolution | Verify the new path resolves correctly from the expected CWD |

For each fix, report:
- ✅ Confirmed: the fix is correct and complete
- ❌ Not fixed: the bug still exists (describe what's still wrong)
- ⚠️ Partially fixed: the main issue is resolved but a related aspect remains

### Step 2: Regression Detection

Check whether any fix **introduced a new problem**. This is the core of regression detection.

For each file that was changed (listed in the Fix Summary's "Changes Made"):

1. **Syntax check**: Re-run the language-appropriate syntax check on the changed file
2. **Neighbor context**: Read ~10 lines around each changed line. Does the surrounding code/text still flow correctly? Are there orphaned references to the old content?
3. **Cross-reference impact**: If a line was added/removed, did line-number-based references elsewhere break? If a file was renamed/moved, are all references to it updated?
4. **Consistency with other files**: If the fix changed a value/name/flag in one file, check that corresponding references in other files are still consistent

Report any regressions found:
```
### Regression Detected
- ⚠️ <file>:L<line> — <description of the new problem>
  - **Cause**: Fix [H1] changed X, which broke Y
  - **Severity**: <critical|high|medium|low>
```

### Step 3: Package Health Check

A rapid overall health scan of the entire skill package:

1. **All files readable**: Every file in the package is still present and readable
2. **Primary SKILL.md valid**: Frontmatter parses correctly, required fields present
3. **Key references intact**: Quick check of the top 3-5 most important cross-references from the Scanner's reference graph
4. **No catastrophic damage**: The skill directory still looks like a skill directory

This is a quick scan — not a full re-analysis. If the health check passes but there might be subtle issues, note them but don't block the pipeline.

## Output: Verification Report

```
## Verification Report: <skill-name>

### Fix Confirmation: X/Y passed
- ✅ [C1] <summary> — confirmed fixed
- ✅ [H1] <summary> — confirmed fixed
- ❌ [M1] <summary> — not fixed: <what's still wrong>
- ⚠️ [M2] <summary> — partially fixed: <what remains>

### Regression Detection: N issues found
- ⚠️ <file>:L<line> — <description>
  - Cause: <which fix caused this>
  - Severity: <level>
- (or) No regressions detected.

### Package Health
- [x] All files readable
- [x] SKILL.md frontmatter valid
- [x] Key references intact
- [ ] <any health issue>

### Conclusion: PASSED | FAILED

<If FAILED> → Return to Analyzer for re-analysis of unresolved and regression issues.
<If PASSED> → Pipeline complete. All fixes verified, no regressions.
```

## Decision Rules

**PASSED** — All of:
- Every [Fixed] bug confirmed as actually fixed (no ❌)
- Zero new Critical or High regressions
- Package health check passes

**FAILED** — Any of:
- One or more ❌ (fix didn't work)
- Any new Critical or High regression
- Package health check finds a Critical issue

If FAILED, the coordinator will route back to Analyzer → Fixer → Verifier for another iteration. The verification report provides the Analyzer with exactly what to re-examine.

## Constraints

- **Read-only.** Report problems, don't fix them.
- Be specific about what failed and where. "Fix didn't work" is not enough — say exactly what's still wrong.
- Distinguish between "fix was wrong" (❌) and "fix was incomplete" (⚠️) — the Fixer needs to know the difference.
- Don't re-run the full Analyzer. Step 3 is a health check, not a complete re-analysis. The coordinator will dispatch the Analyzer if a full re-scan is needed.
