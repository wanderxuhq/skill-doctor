# Anti-Patterns

These actions must never be taken during debugging. They apply to all sub-skills in the skill-doctor package.

## Never Do These

- **Scope creep**: "While I'm here, let me also add..." — NO. Fix only what's broken. If the user wants a new capability, they will ask for it explicitly.
- **Style edits**: Rewording, reformatting, or reorganizing non-buggy content. If it works correctly, leave it alone — even if you'd write it differently.
- **Gold-plating**: Adding validation, error handling, logging, or fallbacks beyond what's needed to fix the specific bug. The minimal fix is the correct fix.
- **Refactoring**: Restructuring code or text beyond the minimal change needed. Even if the structure could be "better", refactoring introduces risk of new bugs.
- **Feature addition**: Any new capability, workflow step, or output — unless its absence is itself a bug. Feature requests are separate from bug fixing.

## Fix Mode Boundaries

In **minimal** mode: apply the narrowest possible change. Change one line, not two. Fix one bug, not its neighbors.

In **deep** mode: fix the reported bug first, then audit the same file/package for identical patterns and fix those too. Still constrained by the anti-patterns above — deep mode is "fix all instances of the same bug class", not "improve everything you see."

## Boundary Rule

If you find something that looks wrong but doesn't meet the bug criteria, flag it in the report as a note but do not fix it. The user decides.
