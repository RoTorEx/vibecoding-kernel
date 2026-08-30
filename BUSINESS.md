# Business

## Purpose

Vibecoding Kernel gives AI-assisted projects one small, durable way to perform
work without centralizing product behavior. It reduces repeated workflow setup
while keeping every child independently understandable and reviewable.

Its design target is a Fiat 500 Abarth: a deliberately small system whose few
parts are fast, sharp, and more effective than their size suggests.

## Actors

- The project owner defines product truth and corrects agent behavior.
- Coding agents perform tasks using committed local operating rules.
- Child projects own all business logic, architecture, code, and delivery.

## Core concepts

- **Kernel runtime:** the files copied into `.vibe/kernel/` and read by agents.
- **Local truth:** child-owned business, product, architecture, and command docs.
- **Explicit sync:** a reviewed `make vibe-pull`, never an automatic update.
- **Managed routing:** marked kernel blocks inside child `AGENTS.md` and
  `Makefile`; product rules and commands remain outside them.
- **Evolution loop:** evidence moves from local repair to reviewed shared rules,
  then returns to children through a versioned pull.
- **Feedback:** a proposal backed by observed behavior; it is not a rule until
  parent review and release.
- **Recipe:** an optional parent-side implementation exhibit that a child adopts
  only after the project owner explicitly selects it.
- **Work mode:** the task boundary between repository maintenance, operational
  execution, and read-only audit.
- **Outcome boundary:** the smallest verifiable result authorized by the current
  request and constrained by local truth.
- **Planning horizons:** a roadmap records durable direction without authorizing
  work; a task queue records accepted, executable work.

## Business flow

1. Bootstrap creates the smallest useful child skeleton.
2. The child records the local kernel path and pulls a versioned runtime copy.
3. Agents read the local copy, not the parent repository.
4. User explanations and corrections are preserved in local truth during the
   same task.
5. Reusable lessons are proposed to the parent without blocking the local task.
6. The parent reviews evidence, removes conflicts, and releases a versioned rule.
7. Children pull and adopt relevant changes as reviewable diffs.
8. Later behavior supplies evidence to keep, refine, or remove the rule.

## Invariants

- Sync never overwrites `BUSINESS.md`, `business/*`, README, changelog,
  project-owned commands, source code, tests, or other local truth; content
  outside managed markers is preserved byte for byte.
- `.vibe/kernel/` contains only the current managed runtime.
- Product-specific behavior never enters the shared runtime.
- Machine-specific paths and integrations stay in ignored local configuration,
  never in committed shared instructions.
- New projects contain no empty architecture trees, presets, hooks, generated
  summaries, or fake command targets.
- A correction from the user must survive the current conversation in the
  appropriate durable source of truth unless explicitly marked temporary.
- A child fixes local truth before proposing a shared improvement.
- A child writes to the parent only through `make vibe-propose`; it never edits
  the parent inbox or rules manually.
- Proposals never become shared rules without parent review and a versioned
  release.
- Rule feedback never blocks the child task that produced it.
- Every substantive new rule is self-contained: trigger, action, reason,
  evidence, scope, verification, and removal condition are recoverable.
- Every rule has one canonical home and plain wording; duplicates and
  near-duplicates are repaired or merged instead of accumulated.
- A new repository's `Initial commit` contains only its operational foundation.
- A fresh project resolves its product brief once, from the first sufficient
  user request or one compact question, then removes the bootstrap instruction.
- Recipes are never runtime defaults, automatically pulled, or applied without
  the project owner's explicit choice.
- Operational execution never inherits the maintenance commit cycle, and an
  audit never silently becomes repair.
- Work never silently expands beyond its authorized outcome, and research stops
  when enough relevant evidence exists to make a safe decision.
- Child planning uses `ROADMAP.md` for durable direction and `TASK.md` for an
  accepted execution queue only when each horizon exists; empty planning files
  and ambiguous `TODO.md` files are omitted.
- A new or materially changed automated publisher gets the closest practical
  non-release preflight before its first pushed tag and authoritative read-back
  after publishing; unchanged recent success may serve as evidence.
- Task-owned temporary artifacts have an explicit lifecycle and are removed
  before completion unless the user or an active task still needs them;
  pre-existing and unowned data is never swept up as collateral cleanup.
- `${HOME}/construction_side` is the single user-visible disposable root for
  bulky agent scratch, temporary checkouts, build outputs, and reusable caches;
  it never owns the only copy of durable source truth or user deliverables.

## Decisions and numbers

| Value | Unit | Meaning | Rationale/source | Change impact | Protecting tests |
|---|---|---|---|---|---|
| 1 | always-read file | `OPERATING.md` is the only mandatory kernel document | Minimize routine context and rule conflicts | Adding another mandatory file increases every task's context | `make check` layout and bootstrap smoke |
| all | `core/*.md` files | Every current core document is versioned runtime | New conditional contracts must reach children without changing sync code | A new file also requires routing and tests | dynamic-file smoke test and routing check |
| 150 | lines | Maximum size of `OPERATING.md` in Stage 1.x | Keeps mandatory context near 1–2K tokens | Exceeding it signals that conditional material should be split out | `make check` line ceiling |
| SemVer | version format | Kernel releases use `MAJOR.MINOR.PATCH` and `vMAJOR.MINOR.PATCH` tags | Children need an ordered, reviewable update boundary | A version change triggers adoption review | release checks and bootstrap version assertion |
| 1 stable command | real release invocation | Run exactly `make release`; provide the version only to its interactive prompt | A reusable command approval should not change with every release version | Encoding the version in the command causes recurring one-off approvals | release argument guard and copied-contract smoke check |
| 1 | canonical home per rule | State a rule once and route to it elsewhere | Duplicate wording drifts and makes agents resolve avoidable conflicts | Rule edits must repair the canonical source and its routes | parent review and bootstrap smoke |
| 1 | maximum bootstrap question | Ask once for the user, problem, and useful outcome only when the first request is insufficient | Avoids both invented product truth and a context-heavy onboarding interview | New-project bootstrap changes | marker assertions in bootstrap smoke |
| 3 | work modes | Maintenance, operation, and audit have distinct authority and completion contracts | Prevent operational agents from editing rails and maintainers from inheriting product-run machinery | Every task must select the mode implied by its requested outcome | copied runtime smoke and mode-contract assertions |
| 1 | active outcome/task | Work has one explicit verifiable boundary at a time | Prevent helpful-looking additions and repeated research from displacing the requested result | Agents must stop for approval before crossing documented or user-defined boundaries | copied runtime scope assertions and final diff/result review |
| 0 | default planning files | New children receive neither `ROADMAP.md` nor `TASK.md` until that horizon exists | Empty queues add routing and context without product truth | A child creates only the locally needed horizon and may keep both when they remain distinct | skeleton absence assertions and copied runtime planning markers |
| 1 | disposable root | `${HOME}/construction_side` contains bulky reproducible scratch and build state | The owner can inspect or delete one obvious tree instead of hunting through hidden system paths | Child build and temporary-work paths must converge here when changed | copied runtime marker and child checks |

## Module map

The kernel is small enough to need no `business/*` modules yet.

| Code area | Business responsibility |
|---|---|
| `core/OPERATING.md` | Required task, Git, command, knowledge-capture, and safety behavior |
| `core/RELEASE.md` | Conditional release behavior |
| `core/EVOLUTION.md` | Feedback, rule-quality, parent-review, and child-adoption loop |
| `tools/vibe-pull` | Explicit versioned distribution without touching local truth |
| `tools/vibe-propose` | Structured child-to-parent feedback submission |
| `templates/project-skeleton` | Minimal new-project bootstrap |
| `recipes/MAKEFILE.md` | Optional owner-selected Make capability examples |
| `recipes/AGENTIC_OPERATIONS.md` | Optional owner-selected operational workflow contract |

## Non-goals

- Defining child product architecture or folder structures beyond Stage 1.x entrypoints.
- Automatically migrating child product files when operating rules change.
- Automatically editing rules from LLM session history without human review.
- Providing technology presets, release channels, or recipes without repeated
  child-project evidence and an explicit owner-controlled adoption boundary.
