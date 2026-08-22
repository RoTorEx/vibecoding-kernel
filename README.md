# Vibecoding Kernel

The minimal shared operating layer for AI-assisted projects.

The kernel owns how work is performed. Each child owns its product, business
logic, architecture, code, and delivery mechanism.

`BUSINESS.md` defines the kernel's own product decisions and invariants.
`CHANGELOG.md` tracks notable kernel changes.

## Stage 1.1

The shared runtime contains only:

- `core/OPERATING.md` — required workflow, Git, command, documentation, and safety rules;
- `core/RELEASE.md` — conditional release contract;
- `core/EVOLUTION.md` — conditional feedback, rule-quality, and adoption contract;
- `VERSION` — the copied kernel version.

A new project also receives local files that the kernel never overwrites:

- `BUSINESS.md` — business purpose, concepts, invariants, decisions, and module map;
- `CHANGELOG.md` — release history beginning with `Unreleased`;
- `AGENTS.md` — short context router;
- `README.md`, `Makefile`, and `.gitignore`.

## Create a project

```bash
make new-project
```

The command prompts for a target path. It creates a missing directory or fills
an existing empty directory (an empty `.git` is allowed), initializes `main`,
installs the operational foundation, and creates the exact first commit
`Initial commit`. Product details belong in later task commits.

On the first substantive task, the local agent uses the user's request to fill
the short project purpose in `README.md` and `BUSINESS.md`. If the request is not
enough, it asks one compact question about the user, problem, and useful
outcome. The bootstrap instruction and markers then remove themselves, so they
consume no context in later work.

For automation, the same command accepts explicit values:

```bash
make new-project TARGET=/absolute/path/to/project NAME=project-name
```

The target must be new or empty except for `.git`. The command copies the
minimal skeleton, records this kernel path in `.vibe/KERNEL_SOURCE`, and pulls
the current operating files.

## Update a child

From the child repository:

```bash
make vibe-pull
```

The update is explicit and reviewable. It refreshes `.vibe/kernel/*`, the
managed kernel-routing block in `AGENTS.md`, and the managed kernel-command
block in `Makefile`. It never changes business documentation, source code,
README, changelog, or project-owned commands. Content outside managed markers
is preserved byte for byte.

Every `core/*.md` file is discovered automatically, so future conditional
kernel contracts reach children without changing the sync implementation.

## Optional recipes

`recipes/MAKEFILE.md` is a parent-side exhibit for implementing real Make
capabilities. Recipes are never pulled or applied automatically. In a child,
the agent names the relevant recipe and its local choices, then waits for the
project owner's explicit approval before implementing it.

## Feedback loop

Agents repair local truth first. Reusable workflow lessons are proposed in
`FEEDBACK.md` with evidence, reviewed in the parent, released as a kernel
version, and explicitly pulled by children. See `core/EVOLUTION.md` for the full
contract.

From a child, start a proposal with the stable interactive command:

```bash
make vibe-propose
```

It writes only a structured inbox entry. Parent review, rule changes, release,
and child adoption remain separate decisions.

If the parent directory moves:

```bash
make vibe-kernel-set KERNEL=/absolute/path/to/vibecoding-kernel
make vibe-pull
```

## Development

```bash
make check
```

## Release

```bash
make release
make release-push
```

Run exactly `make release` in an interactive terminal and enter the exact
version when prompted. Do not pipe the version or add it to the command; this
keeps the command approval reusable across releases. The command runs checks,
updates `VERSION` and `CHANGELOG.md`, creates a release commit, and tags it.
Pushing is separate.
