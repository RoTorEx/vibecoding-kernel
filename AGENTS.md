# AGENTS.md

This repository owns the shared operating rules and bootstrap for new projects.

## Required

- Design target: **Fiat 500 Abarth** — keep the kernel small, quick, and
  disproportionately effective; every rule must earn its runtime and context
  cost.
- Read `core/OPERATING.md` before changing the kernel.
- Read `BUSINESS.md` when changing Stage 1.x behavior, scope, or invariants.
- Read `AGENTS.local.md` only when a task needs machine-specific paths or local
  integrations and the file exists; never commit it.
- Keep Stage 1.x small: no presets, hooks, generated summaries, audit prompts, or product-specific rules.
- Child projects receive committed local copies through `make vibe-pull`.
- Do not edit child projects as part of a kernel change unless the user explicitly asks for a separate migration.
- For rule-writing quality, follow the canonical contract in
  `core/EVOLUTION.md`; route to it instead of restating it here or elsewhere.

## Task routing

- Bootstrap changes: read `templates/project-skeleton/*` and `Makefile`.
- Sync changes: read `tools/vibe-pull`, `templates/kernel-routing.md`, and
  `templates/kernel-make.mk`.
- Release-rule changes: read `core/RELEASE.md`.
- Makefile recipe changes: read `recipes/MAKEFILE.md`.
- Rule, routing, feedback, or kernel-evolution changes: read
  `core/EVOLUTION.md` and `FEEDBACK.md`.

## Local project creation

When creating a real new project, also register it in the locally configured
project manager when one is defined in `AGENTS.local.md`.
