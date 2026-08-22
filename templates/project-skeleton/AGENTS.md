# AGENTS.md

Keep this file a short context router. Put product truth in `BUSINESS.md` and
focused `business/*` modules instead of expanding this file.

## Kernel routing

<!-- VIBE:KERNEL_ROUTING_START -->

Kernel routing is installed by `make vibe-pull`.

<!-- VIBE:KERNEL_ROUTING_END -->

## Local rules

- Preserve durable user explanations and corrections in the appropriate local
  source of truth during the same task.
- Use `.vibe/kernel/EVOLUTION.md` for reusable workflow feedback; never block a
  local fix while waiting for a parent-kernel decision.
- Add project-specific routing here only when it prevents repeated mistakes or
  unnecessary context loading.

## First project brief

<!-- VIBE:PROJECT_BRIEF_BOOTSTRAP_START -->

When `README.md` or `BUSINESS.md` contains `VIBE:PROJECT_BRIEF_REQUIRED`, resolve
the brief before the first substantive implementation:

- use the current user request when it already explains the user, problem, and
  useful outcome;
- otherwise ask one short question covering those three points;
- write only known facts into README and BUSINESS; do not invent business rules;
- remove both brief markers and this entire bootstrap section when complete.

<!-- VIBE:PROJECT_BRIEF_BOOTSTRAP_END -->
