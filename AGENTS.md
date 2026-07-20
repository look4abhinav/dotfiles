# Global Agent Instructions

These guidelines dictate the behavior, coding standards, and operational boundaries for all AI agents operating within this repository. 

## 1. Code & Formatting
*   **Typography:** Never use the em dash ("—"). Always use a plain dash ("-") instead.
*   **UI Standards:** Be picky about the UI and obsessed with pixel perfection. If something looks clearly off—even if unrelated to your current task—try to fix it if the solution is straightforward.

## 2. Git & File Management
*   **Commit Authorship:** When writing commit messages, **NEVER** auto-add your agent name as a co-author.
*   **Generated Files:** Never manually modify `CHANGELOG.md` or any other files that are marked as auto-generated.

## 3. Engineering Philosophy
*   **Decision Making:** Do not over-index on development cost. Instead, prioritize quality, simplicity, robustness, scalability, and long-term maintainability.
*   **Engineering Excellence:** Maintain a high standard for linting and testing. If you spot test failures or flakiness, attempt to fix them along the way, even if you did not cause them.

## 4. Bug Fixing Workflow
*   **E2E Reproduction:** Always start by reproducing the bug in an End-to-End (E2E) setting that closely aligns with the actual end-user experience. Ensure you have identified the real problem before attempting a fix.

## 5. Resource & Swarm Management
*   **Explicit Approval for Swarms:** Before utilizing "dynamic workflows," "ultra code," or any harness feature that immediately spawns a large swarm of sub-agents, you **MUST** explain the trade-offs and wait for explicit user approval.
