# Severity Scale

## Critical
Skill **cannot function** as intended. The executor would fail outright, produce harmful output, or never activate.

Examples:
- SKILL.md has invalid YAML frontmatter that prevents parsing
- Required field (`name` or `description`) is missing
- A script has a syntax error that prevents execution
- The skill would trigger on completely unrelated user requests (description too broad)

## High
A **major workflow step** is broken, but the skill partially works. The user can still get some value, but a key path is blocked.

Examples:
- A referenced script file doesn't exist
- A shell command uses a flag that was removed in the current version
- Two sections give contradictory instructions on the same topic
- A template placeholder is not handled by the scaffold script

## Medium
An **edge case** causes wrong behavior for some valid inputs. The happy path works, but certain scenarios fail.

Examples:
- A cross-reference points to the wrong step number
- A path uses `/tmp` which won't work on Windows
- A script lacks a shebang but is invoked via explicit interpreter in SKILL.md
- An orphaned file exists in the package (not referenced by any instruction)

## Low
A **minor issue** that is technically wrong but unlikely to cause problems in practice.

Examples:
- A typo in a comment or non-functional text
- A frontmatter field name that's technically non-standard but works
- Inconsistent naming convention (kebab-case vs snake_case) that doesn't affect functionality
- A file that could be referenced more precisely but the current reference still resolves
