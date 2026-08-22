# Agentic Operations Recipe

This optional recipe is for repositories where an agent uses project tools and
workflows to operate on user files, queues, SaaS records, mailboxes, browsers,
or other external state. It does not apply to ordinary repository maintenance.

## Selection contract

- Never install this recipe automatically or through `make vibe-pull`.
- The project owner explicitly chooses it for a real operational workflow.
- Adapt it to existing local truth; do not replace mature workflows or copy
  product-specific state, statuses, limits, or approval rules into the kernel.
- Keep the repository maintainer and workflow operator contracts distinct.

## Operator contract

For each operational run:

1. Resolve the requested outcome, data sources, entities, and mutation authority.
2. Load only the local workflow, policies, and source-of-truth definitions needed.
3. Establish the inputs, exact target, blockers, and verification method before
   expensive work or mutation.
4. Freeze a bounded queue or scope when processing multiple items. Give every
   item a stable identity and do not silently replace the requested scope with a
   convenient subset.
5. Use deterministic tools for repeatable mechanics, agent judgment for semantic
   interpretation, and the human for reserved or materially ambiguous decisions.
6. Inspect or preview current state, mutate only the intended target, then read
   back the authoritative result.
7. Give every queued item exactly one verified, deferred, skipped, or failed
   outcome using the project's own vocabulary.
8. Isolate item-local failures, stop only the affected platform for
   platform-local failures, and stop the run only when the remaining scope
   genuinely cannot proceed.
9. Preserve enough non-secret evidence to resume or audit the run. Never treat a
   tool exit code, log claim, or generated summary as proof of external state.
10. Reconcile processed, remaining, and unresolved scope before reporting
    completion. Report partial work explicitly.

## Human intervention

- Ask only when a missing value or authority would materially change the result.
- Defer only the affected item while independent authorized work can continue.
- State the exact action needed, what remains blocked, and the continuation step.
- Do not poll or repeat the same request without new evidence.

## Feedback handoff

An operator completes or safely stops the operational run without editing the
repository. Repeated friction, a workflow gap, or a user correction becomes
evidence for a separate maintenance task. The maintainer decides whether to
repair a local workflow, add a deterministic tool, or propose a kernel change.

Do not build a framework for a first occurrence. Handle one safe novel case
locally, record recurrence, and extract the smallest workflow or tool only after
the pattern is demonstrated.

## Adoption checklist

- The root `AGENTS.md` routes maintenance, operation, and audit requests clearly.
- Operational workflows name their sources of truth and mutation boundaries.
- A real read-only `make check` verifies repository code and rules; operational
  commands remain separate and do not masquerade as maintenance checks.
- Operational output and evidence paths are local, ignored when appropriate,
  and contain no secrets or private reasoning.
- Completion reporting is protected by state read-back or queue reconciliation.
