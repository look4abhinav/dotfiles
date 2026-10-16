# Global Agent Instructions

These are global default instructions across all projects. If a project root or subdirectory contains its own `AGENTS.md`, project-specific rules and commands take precedence over these defaults.

## 1. Orchestration & Sub-Agent Workflow (CRITICAL)
* **Main Chat is for Orchestration:** Treat the primary chat session as a high-level control plane and discussion thread. Keep your responses in the main chat concise so I can converse with you while work happens.
* **Default to Sub-Agents for Heavy Lifting:** Do not pollute the main context window with deep codebase searches, multi-file refactoring, or long test/debug loops. Proactively delegate these to targeted sub-agents:
  * **Exploration:** Spawn a read-only exploration sub-agent (`@explore`) to map directories, locate symbols, or summarize architecture before planning changes.
  * **Implementation & Testing:** Delegate isolated coding tasks, file migrations, and test-fixing loops to dedicated sub-agents. Have them return a concise summary of changes and test outputs.
* **No Unapproved Swarms:** Spawning 1-3 focused sub-agents for sequential or clearly isolated tasks is encouraged. However, before utilizing "dynamic workflows," "ultra code," or any harness feature that spawns a large swarm of parallel sub-agents, you **MUST** explain the trade-offs (token cost, blast radius) and wait for explicit approval.
* **Sub-Agent Guardrails:** Give every spawned sub-agent a strict scope, clear file boundaries, and a low step limit (5-10 steps max) so it reports back rather than looping endlessly on errors.

## 2. Core Engineering & Bug Fixing Philosophy
* **Quality & Maintainability:** Prioritize simplicity, robustness, scalability, and long-term maintainability over quick hacks. Prefer standard library solutions or established project dependencies before introducing new packages.
* **KISS (Keep It Simple):** Write straightforward, flat, and readable code. Avoid clever one-liners, deep inheritance hierarchies, or convoluted generics when simple functions and data structures work.
* **YAGNI (No Speculative Engineering):** Build only what is required for the current task. Do not add unrequested feature flags, extra configuration options, premature abstractions, or backwards-compatibility shims for hypothetical future use cases.
* **Pragmatic DRY (Rule of Three):** Avoid premature abstraction. Tolerate minor code duplication across 2 instances if it keeps the code decoupled and easy to read. Only extract shared helpers or components on the 3rd repetition, or when business logic must stay strictly synchronized.
* **Atomic Scope (Flag, Don't Derail):** Keep changes tightly scoped to the requested task. If you spot unrelated UI flaws, broken tests, or tech debt along the way:
  * If it is a trivial 1-2 line fix in the exact file you are already editing, fix it and mention it.
  * Otherwise, **do not** derail the current task. Log the issue briefly in your summary and offer to spawn a background sub-agent to fix it separately.
* **E2E Bug Reproduction First:** Never guess at a bug fix. Always start by reproducing the bug in an End-to-End (E2E) or realistic integration setting that mirrors actual user experience. Verify the test fails for the expected reason before writing implementation code.

## 3. Domain & Stack Standards

### Shell & Automation Scripts (`bash` / `sh`)
* **Safety Header:** Always start bash scripts with `set -euo pipefail`.
* **Defensive Scripting:** Quote all variable expansions (`"$var"`), prefer `[[ ... ]]` over `[ ... ]`, and use `local` for function variables.
* **Idempotency & Ergonomics:** Scripts should be idempotent where possible, handle cleanup via `trap` when creating temp files/background processes, and support `--help` or clear usage output.
* **Verification:** Validate scripts with `shellcheck` (if installed) and `bash -n` before marking a task complete.

### Python Development
* **Tooling Defaults:** Prefer `uv` (e.g., `uv run`, `uv add`) for environment and dependency management unless the repo explicitly uses Poetry, Pipenv, or Conda.
* **Code Standards:** Write modern Python (3.11+) with strict type hints on all function signatures and return values. Prefer `pathlib.Path` over `os.path`, and `pydantic` or `dataclasses` over raw dictionaries for structured data.
* **Verification:** Run `ruff check --fix` and `ruff format` for linting/formatting, and `pytest` (scoped to affected test files first) to verify behavior.

### Web Application & UI Development
* **Pixel Perfection & UX:** Be obsessive about UI polish, alignment, spacing consistency, responsive breakpoints, and accessible states (hover, focus, loading, empty, and error states). If a layout looks visually unbalanced, fix it.
* **Architecture:** Keep route/API handlers thin. Validate all external inputs at system boundaries. Never trust client-supplied roles, IDs, or permissions without server-side verification.
* **Verification:** Always run the project's type-checker (`tsc --noEmit`) and linter before concluding UI or API changes. Use Playwright (or the project's E2E runner) to verify critical user flows.

## 4. Code Hygiene, Formatting & Git Boundaries
* **High-Signal Inline Comments Only:** Write self-documenting code using descriptive variable and function names. **Do not** add line-by-line narrator comments explaining *what* the code is doing.
  * **Explain Why, Not What:** Only write comments to explain non-obvious *why* decisions, complex regex/algorithms, external API quirks, or intentional workarounds.
  * **No Changelog Comments:** Never add comments referencing your current edit, the prompt, or the bug fix (e.g., never write `// Fixed bug`, `# Added check`, or `// Changed from X to Y`). Comments must read as timeless documentation of the system.
* **Pragmatic Docstrings (Python & JSDoc/TSDoc):**
  * **When to Include:** Write concise docstrings for public modules, classes, CLI entrypoints, and complex functions to document high-level purpose, side effects, invariants, or raised exceptions.
  * **When to Omit:** Do **not** add docstrings to private/internal helper functions (`_helper`), simple getters/setters, or straightforward functions where the function name and type signature already make the behavior obvious.
  * **No Redundant Type Boilerplate:** Never repeat parameter or return types in docstrings that are already declared in the function's type annotations, and never restate the function name in prose (e.g., avoid `def get_user(user_id: int) -> User: """Gets the user by user_id."""`). Prefer a single-line docstring unless complex caveats require more detail.
* **Typography:** Never use the em dash character (the long dash). Always use a plain hyphen/dash (`-`) in prose, comments, UI copy, and documentation.
* **Commit Authorship:** When writing git commit messages, **NEVER** auto-add your agent name, `Co-Authored-By:` trailers, or "Generated with..." footers. Use clean, imperative commit messages (e.g., `feat(auth): add token refresh retry`).
* **Generated Files:** Never manually edit `CHANGELOG.md`, lockfiles (`uv.lock`, `pnpm-lock.yaml`, `package-lock.json`), database migration history, or any file marked as auto-generated.
* **Secrets & Safety:** Never hardcode, log, or commit secrets, API keys, or `.env` files. Ask for explicit confirmation before running destructive commands (`rm -rf`, `git reset --hard`, `git push --force`, or dropping database tables).

