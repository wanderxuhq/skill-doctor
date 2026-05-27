# Skill Scanner

Load a target skill package and produce a complete **structure map**. This is the first phase of the skill-doctor pipeline. Pure read — no files are modified.

## Input

A path to a skill directory (e.g., `.claude/skills/playwright-mcp-builder/` or `.claude/skills/skill-doctor/`).

## Workflow

### Phase 1: Discovery

1. List all files recursively with `Glob` — exclude `node_modules/`, `.git/`, `dist/`, `debug-artifacts/`
2. Identify the primary SKILL.md (at directory root, either `SKILL.md` or `skill.md`)
3. Read the primary SKILL.md to extract metadata

### Phase 2: Classification

Classify every file into one of these types:

| Type | Pattern | Examples |
|------|--------|---------|
| skill-definition | Root `SKILL.md` or `skill.md` | The skill's main instruction file |
| script | `.sh`, `.mjs`, `.js`, `.py`, `.ts` (executable code) | `scripts/scaffold.mjs` |
| template | Files containing `{{...}}` placeholders | `template/index.ts` |
| config | `.json`, `.yaml`, `.yml`, `.toml` | `package.json`, `tsconfig.json` |
| document | `.md` files other than SKILL.md | `README.md`, `references/*.md` |
| library | `.ts`, `.js` files that are imported, not run directly | `lib/logger.ts` |
| binary | Images, fonts, binaries | `.png`, `.ico`, `.ttf` |
| other | Everything else | `.gitignore`, `.env.example` |

### Phase 3: Reference Graph

Build a directed reference graph:

1. **SKILL.md → files**: Scan SKILL.md for file path references (backtick-quoted paths, `scripts/...`, `template/...`, `references/...`). Each referenced path → verify it resolves to an actual file.
2. **Script → dependencies**: For each script, parse imports/requires/source statements to find which files it depends on.
3. **Template → placeholders**: For each template file, list all `{{PLACEHOLDER}}` markers found. Use `scripts/check-placeholders.sh <dir>` as a shortcut to find all `{{...}}` markers in a directory.
4. **Script → placeholder handling**: For each scaffold/substitution script, find which placeholders it replaces (grep for `.replace`, `replaceAll`, `sed`, placeholder names).

### Phase 4: Metadata Extraction

From the primary SKILL.md frontmatter, extract:
- `name`, `description`, `tools` or `allowed-tools`, `version` (if present)
- Number of workflow steps/phases
- Any explicitly declared dependencies

Run `scripts/check-yaml.sh <path/to/SKILL.md>` to validate frontmatter syntax and required fields.

## Output: Structure Map

Produce the structure map in this exact format:

```
## Structure Map: <skill-name>

### Directory
Root: <absolute-path>
Files total: N (M types)

### File Inventory
| Path | Type | Size | Notes |
|------|------|------|-------|
| SKILL.md | skill-definition | 8.2K | Primary instruction file |
| scripts/scaffold.mjs | script | 4.3K | CLI scaffold tool |
| template/index.ts | template | 6.1K | 5 {{REPLACE}} blocks |
| ... | ... | ... | ... |

### Metadata
- name: <value>
- description: <value>
- tools: <list>
- version: <value or "not set">
- phases: <count or "not counted">
- dependencies: <list or "none declared">

### Reference Graph
SKILL.md references:
  - scripts/scaffold.mjs → EXISTS
  - references/config.md → EXISTS
  - scripts/run.sh → NOT FOUND ⚠

scripts/scaffold.mjs references:
  - ../template/ (directory copy) → EXISTS

### Placeholder Map
| Placeholder | Found In | Handled By |
|-------------|----------|------------|
| {{TOOL_NAME}} | template/index.ts, template/package.json | scripts/scaffold.mjs |
| {{DESCRIPTION}} | template/index.ts, template/package.json | scripts/scaffold.mjs |
| {{REPLACE}} | template/index.ts (5 occurrences) | (manual — not handled by script) |

### Structure Health (quick flags)
- [ ] All referenced files exist
- [ ] All placeholders have documented handling
- [ ] No orphaned files (unreferenced)
- [ ] File naming follows conventions
```

If a file that should exist is missing, mark it as NOT FOUND. If a file exists but is never referenced, mark it as ORPHANED.

## Constraints

- **Read only.** Never create, edit, or delete files.
- Report what you see, not what you think should be there.
- If the skill has no scripts, templates, or configs, the corresponding sections will be empty — that's fine.
- The structure map is data for the Analyzer to consume. Include enough detail that the Analyzer doesn't need to re-scan.
