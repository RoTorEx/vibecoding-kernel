# Kernel Feedback

This is the active review inbox for reusable evidence from child projects.
Child agents may append proposals here, but must not edit parent core files.

A proposal is not a rule. Parent review accepts, narrows, rejects, or removes it.
Resolved entries may be removed because Git preserves their decision history.

Do not include secrets, private payloads, raw conversations, or identifying
details that are unnecessary to evaluate the behavior.

## Proposal template

### YYYY-MM-DD — Short title

- Source project: `<name or path>`
- Trigger: `<when the problem occurs>`
- Proposed action: `<what an agent should do>`
- Reason: `<failure prevented and why the result is worse without the rule>`
- Evidence: `<incidents, corrections, repeated cases, or tests>`
- Scope and exceptions: `<where it applies and where it does not>`
- Verification: `<how to check that it helps>`
- Removal condition: `<evidence that would narrow or delete it>`
- Status: `proposed`

## Active feedback

### 2026-08-22 — Validate release CI before first tag push

- Source project: `gtd`
- Trigger: Before pushing the first release tag for a project with a new or materially changed GitHub Actions release workflow.
- Proposed action: Validate the complete publisher topology and each target dependency path before tag push: ensure the publish job has explicit repository context, verify action inputs, inspect cross-target native dependencies, and prefer a disposable non-release workflow test when practical.
- Reason: Local build checks and YAML parsing do not exercise runner-specific linkage or repository context, so failures discovered only after tag push can force an incomplete release or pressure maintainers toward tag rewriting.
- Evidence: A first tagged Rust CLI release passed local checks and YAML parsing but failed twice in Actions: one cross target pulled an unintended native TLS dependency, and the publisher lacked repository context. The release had to be repaired with a later patch version.
- Scope and exceptions: Apply to new or materially changed automated release pipelines. Existing unchanged pipelines with recent successful tagged runs may use that run as evidence. Do not require unsupported cross-platform targets for personal tools.
- Verification: Before the real tag push, record evidence that every configured target can resolve its dependency tree and that the publisher identifies the repository and matches at least one expected artifact; after push, verify the workflow conclusion and release assets.
- Removal condition: Narrow or remove the rule if release tooling gains a reliable built-in dry run that validates runner targets, publisher permissions, repository context, and artifact matching before tag creation.
- Status: `accepted — narrowed into core/RELEASE.md`
