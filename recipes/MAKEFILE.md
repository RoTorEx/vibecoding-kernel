# Makefile Recipes

These are optional capability recipes, not project defaults.

## Selection contract

- Never apply a recipe automatically or during `make vibe-pull`.
- Recommend a recipe only when the current task makes that capability relevant.
- Before editing, name the recipe, list the targets it adds, state important
  local choices such as the install directory, and ask the project owner to
  approve it.
- Apply only the approved recipe. Adapt it to the project's native tools and
  keep the resulting `Makefile` as child-owned local truth.
- Omit unsupported targets. A target must perform real work and fail when that
  work fails.

Example approval question:

> This is a private CLI. Apply `makefile/cli-local`, adding `build`, `check`,
> `run`, and `install-local`, with installation to `~/.local/bin`?

## `makefile/cli-local`

Use for a CLI that the owner wants to run on the local machine.

- `build` creates the runnable production binary or entrypoint.
- `check` runs the project's real read-only verification.
- `run` starts the CLI from the working tree.
- `install-local` depends on `build`, installs without `sudo` into the approved
  user-owned location, and verifies the installed command with `--version` or
  `--help`.
- Re-running `install-local` safely replaces the previous local installation.

Implementation shape; replace every angle-bracket value with real project
commands before adding it to a child:

```make
.PHONY: build check run install-local

BIN := <command-name>
INSTALL_DIR ?= $(HOME)/.local/bin
BUILD_BIN := <production-artifact-path>

build:
	<production-build-command>

check:
	<read-only-project-checks>

run:
	<run-from-working-tree-command>

install-local: build
	@mkdir -p "$(INSTALL_DIR)"
	@install -m 755 "$(BUILD_BIN)" "$(INSTALL_DIR)/$(BIN)"
	@"$(INSTALL_DIR)/$(BIN)" --help >/dev/null
```

## `makefile/release`

Use only when the owner wants versioned Git releases.

- `release` starts an interactive release and asks for the SemVer version after
  the unchanged `make release` invocation.
- The release checks the project, updates version and changelog, creates the
  release commit, and tags that commit.
- `release-push` separately verifies the release tag at `HEAD`, then pushes the
  tracked branch and that tag.
- Do not add a combined release-and-push target.
- Keep non-trivial release logic in local executable tools, not dense Make shell.

```make
.PHONY: release release-push

release:
	@./tools/release

release-push:
	@./tools/release-push
```

The local tools must implement the full contract in `.vibe/kernel/RELEASE.md`.
Do not add these targets until those tools exist and pass an isolated smoke test.
