# Skill Analyzer

Perform deep analysis on a skill package to find **all bugs**. Takes the Scanner's structure map as input. Works generically on any skill — single SKILL.md, multi-file package, script-heavy, template-heavy, or any combination.

Read the shared references at `.claude/skills/skill-doctor/references/bug-categories.md` and `.claude/skills/skill-doctor/references/severity-scale.md` before starting. Follow the anti-patterns in `.claude/skills/skill-doctor/references/anti-patterns.md`.

**CRITICAL CONSTRAINT: Only identify bugs. Do NOT fix them.** This is a read-only analysis phase. Fixing happens in the Fixer phase.

## Input

The Scanner's structure map, plus the skill's file contents. If no structure map is provided, do a quick scan first.

## Analysis Dimensions

Apply all five dimensions to every file and cross-file relationship. These dimensions are universal — they apply regardless of file type.

### 1. Validity

"Does this actually work?"

- **SKILL.md**: YAML frontmatter parses without error. Markdown syntax is correct (no broken code fences, no malformed tables). All heading cross-references resolve.
- **Scripts**: Syntax check per language (`bash -n` for .sh, `node --check` for .mjs/.js, `python -m py_compile` for .py, `npx tsc --noEmit` for .ts if tsconfig exists). For batch-checking all `.sh` files in a directory, run `scripts/lint-bash.sh <dir>`.
- **Config files**: Valid JSON/YAML/TOML that would parse correctly.
- **Templates**: No syntax errors in template code (the filled-in result should be valid).

### 2. Consistency

"Does this say the same thing everywhere?"

- **Within SKILL.md**: No contradictory instructions between sections. Branching logic covers all paths. Conditions used in branches are established earlier.
- **SKILL.md vs scripts**: Script name/behavior matches how SKILL.md describes it. Flags mentioned in instructions match what the script actually accepts.
- **SKILL.md vs frontmatter**: `tools`/`allowed-tools` field covers every tool referenced in the body. The `description` field accurately describes what the skill does.
- **Across multiple SKILL.md files** (package skills): No conflicting instructions between sub-skills. Dispatch references match actual sub-skill names.

### 3. Completeness

"Is everything that should be there, there?"

- **Required files**: Every skill directory has a valid SKILL.md. Template directories that are referenced exist.
- **Required frontmatter fields**: `name` and `description` present and non-empty.
- **Referenced files exist**: Every file path mentioned in SKILL.md resolves to an actual file. Every script import resolves.
- **Placeholder coverage**: Every `{{...}}` in templates is handled by some substitution mechanism (script or documented manual step).
- **Sub-skill coverage**: If the skill dispatches to sub-skills, every referenced sub-skill name exists.

### 4. Safety

"Could this cause harm?"

- **Destructive operations**: `rm -rf`, `git reset --hard`, `git push --force`, database drops — do they carry adequate warnings? Are they gated by confirmation?
- **Secrets exposure**: Would any instruction cause secrets, tokens, or credentials to appear in output or logs?
- **Irreversible actions**: Does the skill warn before actions that can't be undone?
- **Interactive hangs**: Are there commands that would hang waiting for input without it being documented?

### 5. Reachability

"Can everything be found and used?"

- **Trigger description** (`description` field): Contains concrete phrases users would say. Not so broad it triggers on unrelated requests. Not so narrow it almost never matches.
- **Tool availability**: Every tool referenced in the body is declared in `tools`/`allowed-tools` and is actually available.
- **Sub-skill discoverability**: Sub-skills in a package have valid SKILL.md files that can be discovered.
- **No orphaned files**: Every file in the package is referenced by at least one instruction or import chain.

## Output: Bug Report

Produce the bug report in this exact format:

```
## Bug Report: <skill-name>

Source: <path/to/skill>
Analyzed files: N
Bugs found: N

### Critical
- [C1] <one-line summary>
  - **Category**: <from bug categories>
  - **Location**: <file>:L<line>
  - **What goes wrong**: <concrete failure description>
  - **Suggested fix**: <1-2 sentence direction, not a specific edit>

### High
- [H1] ...

### Medium
- [M1] ...

### Low
- [L1] ...

---
No bugs found in categories not listed above.
```

If 0 bugs found:

```
## Bug Report: <skill-name>

Source: <path/to/skill>
Analyzed files: N
Bugs found: 0

No bugs found. The skill is clean.
```

### Severity Definitions

- **Critical**: Skill cannot function as intended — executor would fail, produce harmful output, or never activate
- **High**: Major workflow step is broken, but skill partially works
- **Medium**: Edge case causes wrong behavior for some valid inputs
- **Low**: Minor issue; unlikely to cause problems in practice but still technically wrong

## What NOT to Report

- Missing features (that's enhancement, not a bug)
- Style or wording preferences (unless causing actual misinterpretation)
- Missing error handling (unless the happy path itself is broken)
- Missing examples or documentation
- Performance concerns (unless causing functional failure)
- "This could be organized better" (refactoring is not bug fixing)

Flag-and-ask boundary cases (see `.claude/skills/skill-doctor/references/bug-categories.md`).

## After Producing the Report

The bug report is the Analyzer's complete output. Pass it back to the coordinator. Do not proceed to fixing — that is the Fixer's responsibility.
