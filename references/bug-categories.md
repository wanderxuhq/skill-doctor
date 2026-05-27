# Bug Categories

A bug is a flaw that would cause the skill executor to produce a **wrong, harmful, or non-functional result**. Apply this test: "If the executor follows this instruction literally, will something go wrong?"

## Bug Categories (fix these)

| Category | Applies to | Example |
|----------|-----------|---------|
| **Broken commands** | Scripts, SKILL.md | Shell command has wrong syntax, missing flags, or would error out when run |
| **Broken references** | SKILL.md, templates | Links/references to files, paths, or sections that don't exist |
| **Logic errors** | SKILL.md, scripts | Step 3 requires output from Step 2, but Step 2 doesn't produce it |
| **Contradictory instructions** | SKILL.md (cross-section) | Section A says "always do X", Section B says "never do X" |
| **Ambiguous instructions** | SKILL.md | Wording that a reasonable executor could interpret in two conflicting ways |
| **Missing required frontmatter** | SKILL.md | Required fields (`name`, `description`) missing or malformed |
| **Dangerous instructions** | SKILL.md, scripts | Commands that would irreversibly delete, overwrite, or corrupt without warning |
| **Trigger description bugs** | SKILL.md frontmatter | `description` field too broad or too narrow |
| **Tool declaration gaps** | SKILL.md frontmatter | Skill references a tool not declared or not available |
| **Type/format errors** | SKILL.md, config files | Invalid YAML, wrong field names, incorrect enum values |
| **Ordering / dependency bugs** | SKILL.md | Instructions assume state from a prior step that may not exist |
| **Syntax errors** | Scripts (.sh, .mjs, .js, .py, .ts) | Missing `fi`, unclosed quotes, invalid JavaScript/TypeScript |
| **Placeholder errors** | Templates | Unresolved `{{...}}`, mismatch between template markers and scaffold replacements |
| **Path resolution bugs** | Scripts, SKILL.md | Relative paths that break when called from wrong CWD; hardcoded absolute paths |
| **Platform assumptions** | Scripts | Hardcoded `/tmp`, `/bin/bash` instead of `/usr/bin/env bash`, Windows-incompatible separators |
| **Cross-reference gaps** | Package structure | SKILL.md references a script/sub-skill that doesn't exist; orphaned files with no referrer |

## NOT Bugs (don't fix these)

| Not a bug | Why |
|-----------|-----|
| Missing features | Skill does what it specifies; adding more is enhancement |
| Style/preference | "This could be worded better" — unless wording causes actual misinterpretation |
| Missing error handling | If the happy path works, adding fallbacks is a feature |
| Missing examples | Examples are enhancements, not bugfixes |
| Terse instructions | If they're correct, brevity is not a bug |
| Missing documentation | Undocumented behavior that works correctly is not a bug |
| Scope limitations | "Skill doesn't handle X scenario" — that's a feature request |
| Performance issues | Unless causing actual timeout or functional failure |

## Boundary Cases

Flag and ask the user when:
- An instruction is ambiguous enough that an executor could reasonably take the wrong action → IS a bug
- A missing edge case causes silently wrong output for valid input → IS a bug
- Unsure whether bug or missing feature → flag it, don't silently decide
