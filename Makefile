.PHONY: check check-layout check-agent-paths smoke-new-project smoke-propose smoke-release new-project release release-push

TARGET := $(strip $(TARGET))
NAME := $(strip $(NAME))

check: check-layout check-agent-paths
	@python3 -c "import os, py_compile, tempfile; py_compile.compile('tools/vibe-pull', cfile=os.path.join(tempfile.gettempdir(), 'vibe-pull.pyc'), doraise=True)"
	@python3 -c "import os, py_compile, tempfile; py_compile.compile('tools/release', cfile=os.path.join(tempfile.gettempdir(), 'vibe-release.pyc'), doraise=True)"
	@python3 -c "import os, py_compile, tempfile; py_compile.compile('tools/vibe-propose', cfile=os.path.join(tempfile.gettempdir(), 'vibe-propose.pyc'), doraise=True)"
	@$(MAKE) smoke-new-project
	@$(MAKE) smoke-propose
	@$(MAKE) smoke-release
	@echo "OK"

check-layout:
	@test "$$(wc -l < core/OPERATING.md | tr -d ' ')" -le "150"
	@test -f BUSINESS.md
	@test -f CHANGELOG.md
	@test -f core/OPERATING.md
	@test -f core/RELEASE.md
	@test -f core/EVOLUTION.md
	@test -f VERSION
	@test -f tools/vibe-pull
	@test -f tools/release
	@test -f tools/vibe-propose
	@test -f recipes/MAKEFILE.md
	@test -f recipes/AGENTIC_OPERATIONS.md
	@test -f templates/kernel-routing.md
	@test -f templates/kernel-make.mk
	@test -f templates/project-skeleton/AGENTS.md
	@test -f templates/project-skeleton/BUSINESS.md
	@test -f templates/project-skeleton/CHANGELOG.md
	@test -f templates/project-skeleton/README.md
	@test -f templates/project-skeleton/Makefile
	@test -f templates/project-skeleton/.gitignore
	@test ! -e presets
	@test ! -e docs
	@test ! -e PROPOSALS.md
	@test ! -e templates/project-skeleton/TASK.md
	@test ! -e templates/project-skeleton/TODO.md
	@test ! -e templates/project-skeleton/ROADMAP.md
	@test ! -e templates/project-skeleton/.githooks
	@for file in core/*.md; do name="$$(basename "$$file")"; grep -Fq "$$name" templates/kernel-routing.md || { echo "ERROR: $$name is not routed." >&2; exit 1; }; done
	@grep -Fq '## Work mode' core/OPERATING.md
	@grep -Fq 'Use this cycle only when tracked repository state changes.' core/OPERATING.md
	@grep -Fq 'Audit' core/OPERATING.md
	@grep -Fq 'Operation' core/OPERATING.md
	@grep -Fq 'named uncertainty' core/OPERATING.md
	@grep -Fq 'Stop for approval before crossing' core/OPERATING.md
	@grep -Fq 'Use `ROADMAP.md` only for durable product direction' core/OPERATING.md
	@grep -Fq 'Use `TASK.md` only for accepted, executable work' core/OPERATING.md
	@grep -Fq 'do not use the ambiguous `TODO.md` name' core/OPERATING.md
	@grep -Fq 'remove owned temporary artifacts' core/OPERATING.md
	@grep -Fq '$${HOME}/construction_side/<project>/' core/OPERATING.md

check-agent-paths:
	@python3 -c 'from pathlib import Path; import glob, re; text=Path("AGENTS.md").read_text(); refs={value for value in re.findall(r"`([^`]+)`", text) if "/" in value or value.endswith(".md") or value == "Makefile"}; optional={"AGENTS.local.md"}; missing=sorted(value for value in refs - optional if not glob.glob(value)); assert not missing, "missing AGENTS.md path(s): " + ", ".join(missing)'

new-project:
	@set -eu; \
	target="$(TARGET)"; \
	name="$(NAME)"; \
	if [ -z "$$target" ]; then printf "Target path: "; read -r target; fi; \
	if [ -z "$$target" ]; then echo "ERROR: target path is required." >&2; exit 1; fi; \
	if [ -z "$$name" ]; then trimmed="$${target%/}"; name="$$(basename "$$trimmed")"; fi; \
	if [ -d "$$target" ]; then \
		if [ -n "$$(find "$$target" -mindepth 1 -maxdepth 1 ! -name .git -print -quit)" ]; then \
			echo "ERROR: target must be empty except for .git: $$target" >&2; exit 1; \
		fi; \
		if [ -e "$$target/.git" ]; then \
			git -C "$$target" rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: target contains an invalid .git: $$target" >&2; exit 1; }; \
			! git -C "$$target" rev-parse --verify HEAD >/dev/null 2>&1 || { echo "ERROR: target Git repository already has commits: $$target" >&2; exit 1; }; \
		fi; \
		cp -R templates/project-skeleton/. "$$target"; \
	else \
		cp -R templates/project-skeleton "$$target"; \
	fi; \
	if [ -e "$$target/.git" ]; then \
		git -C "$$target" symbolic-ref HEAD refs/heads/main; \
	else \
		git -C "$$target" init -q -b main; \
	fi; \
	python3 -c "from pathlib import Path; import sys; p=Path(sys.argv[1])/'README.md'; p.write_text(p.read_text().replace('TODO_PROJECT_NAME', sys.argv[2], 1))" "$$target" "$$name"; \
	mkdir -p "$$target/.vibe"; \
	printf "%s\n" "$(CURDIR)" > "$$target/.vibe/KERNEL_SOURCE"; \
	python3 tools/vibe-pull "$$target"; \
	git -C "$$target" add -A; \
	git -C "$$target" commit -qm "Initial commit"; \
	echo "Created $$target"

smoke-new-project:
	@set -eu; \
	tmp="$$(mktemp -d "$${TMPDIR:-/tmp}/vibe-stage1.XXXXXX")"; \
	case "$$tmp" in /|"") echo "ERROR: unsafe temporary path." >&2; exit 1;; esac; \
	trap 'rm -rf "$$tmp"' EXIT INT TERM; \
	git -C "$$tmp" init -q; \
	GIT_AUTHOR_NAME=smoke GIT_AUTHOR_EMAIL=smoke@example.invalid GIT_COMMITTER_NAME=smoke GIT_COMMITTER_EMAIL=smoke@example.invalid \
		$(MAKE) new-project TARGET="$$tmp" NAME=stage-one-smoke >/dev/null; \
	test "$$(git -C "$$tmp" branch --show-current)" = "main"; \
	test "$$(git -C "$$tmp" log -1 --format=%s)" = "Initial commit"; \
	test "$$(git -C "$$tmp" rev-list --count HEAD)" = "1"; \
	grep -Fq 'VIBE:PROJECT_BRIEF_REQUIRED' "$$tmp/README.md"; \
	grep -Fq 'VIBE:PROJECT_BRIEF_REQUIRED' "$$tmp/BUSINESS.md"; \
	grep -Fq 'VIBE:PROJECT_BRIEF_BOOTSTRAP_START' "$$tmp/AGENTS.md"; \
	test -f "$$tmp/BUSINESS.md"; \
	test -f "$$tmp/CHANGELOG.md"; \
	test -f "$$tmp/.vibe/kernel/OPERATING.md"; \
	test -f "$$tmp/.vibe/kernel/RELEASE.md"; \
	test -f "$$tmp/.vibe/kernel/EVOLUTION.md"; \
	grep -Fq 'start exactly `make release`' "$$tmp/.vibe/kernel/RELEASE.md"; \
	grep -Fq '## Work mode' "$$tmp/.vibe/kernel/OPERATING.md"; \
	grep -Fq 'Operation and audit' "$$tmp/.vibe/kernel/OPERATING.md"; \
	grep -Fq 'named uncertainty' "$$tmp/.vibe/kernel/OPERATING.md"; \
	grep -Fq 'Stop for approval before crossing' "$$tmp/.vibe/kernel/OPERATING.md"; \
	grep -Fq 'Use `ROADMAP.md` only for durable product direction' "$$tmp/.vibe/kernel/OPERATING.md"; \
	grep -Fq 'Use `TASK.md` only for accepted, executable work' "$$tmp/.vibe/kernel/OPERATING.md"; \
	test "$$(cat "$$tmp/.vibe/kernel/VERSION")" = "$$(cat VERSION)"; \
	git -C "$$tmp" check-ignore -q .vibe/KERNEL_SOURCE; \
	grep -q "Always read.*OPERATING.md" "$$tmp/AGENTS.md"; \
	grep -Fq '# VIBE:KERNEL_MAKE_START' "$$tmp/Makefile"; \
	grep -Fq 'vibe-propose:' "$$tmp/Makefile"; \
	printf '\nlocal-command:\n\t@true\n' >> "$$tmp/Makefile"; \
	printf "\nDurable local fact.\n" >> "$$tmp/BUSINESS.md"; \
	mkdir -p "$$tmp/.vibe/kernel/examples"; \
	printf "obsolete\n" > "$$tmp/.vibe/kernel/LEGACY.md"; \
	printf "obsolete\n" > "$$tmp/.vibe/kernel/examples/OLD.md"; \
	(cd "$$tmp" && make vibe-pull >/dev/null); \
	grep -q "Durable local fact" "$$tmp/BUSINESS.md"; \
	grep -Fq 'local-command:' "$$tmp/Makefile"; \
	test "$$(grep -Fc '# VIBE:KERNEL_MAKE_START' "$$tmp/Makefile")" = "1"; \
	test ! -e "$$tmp/.vibe/kernel/LEGACY.md"; \
	test ! -e "$$tmp/.vibe/kernel/examples"; \
	count="$$(find "$$tmp/.vibe/kernel" -maxdepth 1 -type f | wc -l | tr -d ' ')"; \
	expected="$$(find core -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"; \
	test "$$count" = "$$((expected + 1))"; \
	fake="$$tmp/fake-kernel"; \
	mkdir -p "$$fake/core" "$$fake/templates" "$$fake/tools"; \
	cp core/*.md "$$fake/core/"; \
	cp VERSION "$$fake/VERSION"; \
	cp templates/kernel-routing.md "$$fake/templates/kernel-routing.md"; \
	cp templates/kernel-make.mk "$$fake/templates/kernel-make.mk"; \
	cp tools/vibe-pull "$$fake/tools/vibe-pull"; \
	printf "# Future Contract\n" > "$$fake/core/FUTURE.md"; \
	python3 "$$fake/tools/vibe-pull" "$$tmp" >/dev/null; \
	test -f "$$tmp/.vibe/kernel/FUTURE.md"; \
	legacy="$$tmp/legacy-project"; \
	mkdir -p "$$legacy"; \
	cp templates/project-skeleton/AGENTS.md "$$legacy/AGENTS.md"; \
	printf 'check:\n\t@true  \n# exact local tail  ' > "$$legacy/Makefile"; \
	cp "$$legacy/Makefile" "$$legacy/Makefile.before"; \
	python3 tools/vibe-pull "$$legacy" >/dev/null; \
	python3 -c "from pathlib import Path; import sys; before=Path(sys.argv[1]).read_bytes(); after=Path(sys.argv[2]).read_bytes(); assert after.startswith(before + b'\\n\\n# VIBE:KERNEL_MAKE_START\\n')" "$$legacy/Makefile.before" "$$legacy/Makefile"; \
	grep -Fq 'check:' "$$legacy/Makefile"; \
	grep -Fq 'vibe-propose:' "$$legacy/Makefile"; \
	cp "$$legacy/Makefile" "$$legacy/Makefile.after-first-pull"; \
	python3 tools/vibe-pull "$$legacy" >/dev/null; \
	cmp "$$legacy/Makefile.after-first-pull" "$$legacy/Makefile"; \
	fresh="$$tmp/fresh-project"; \
	GIT_AUTHOR_NAME=smoke GIT_AUTHOR_EMAIL=smoke@example.invalid GIT_COMMITTER_NAME=smoke GIT_COMMITTER_EMAIL=smoke@example.invalid \
		$(MAKE) new-project TARGET="$$fresh" NAME=fresh-project >/dev/null; \
	test "$$(git -C "$$fresh" branch --show-current)" = "main"; \
	test "$$(git -C "$$fresh" log -1 --format=%s)" = "Initial commit"; \
	echo "OK"

smoke-propose:
	@set -eu; \
	tmp="$$(mktemp -d "$${TMPDIR:-/tmp}/vibe-propose.XXXXXX")"; \
	case "$$tmp" in /|"") echo "ERROR: unsafe temporary path." >&2; exit 1;; esac; \
	trap 'rm -rf "$$tmp"' EXIT INT TERM; \
	kernel="$$tmp/kernel"; child="$$tmp/child"; \
	mkdir -p "$$kernel/tools" "$$child/.vibe"; \
	cp tools/vibe-propose "$$kernel/tools/vibe-propose"; \
	printf '# Kernel Feedback\n\n## Active feedback\n\nNone.\n' > "$$kernel/FEEDBACK.md"; \
	cp templates/project-skeleton/Makefile "$$child/Makefile"; \
	cp templates/project-skeleton/AGENTS.md "$$child/AGENTS.md"; \
	python3 tools/vibe-pull "$$child" >/dev/null; \
	printf '%s\n' "$$kernel" > "$$child/.vibe/KERNEL_SOURCE"; \
	printf '%s\n' "Useful title" "Repeated trigger" "Shared action" "Prevents recurrence" "Two observed tasks" "Shared workflow only" "No repeated failure" "Remove if harmful" | $(MAKE) -s -C "$$child" vibe-propose >/dev/null; \
	today="$$(date +%F)"; \
	grep -Fq "### $$today — Useful title" "$$kernel/FEEDBACK.md"; \
	grep -Fq -- '- Source project: `child`' "$$kernel/FEEDBACK.md"; \
	grep -Fq -- '- Status: `proposed`' "$$kernel/FEEDBACK.md"; \
	! grep -Fxq 'None.' "$$kernel/FEEDBACK.md"; \
	echo "OK"

smoke-release:
	@set -eu; \
	tmp="$$(mktemp -d "$${TMPDIR:-/tmp}/vibe-release.XXXXXX")"; \
	case "$$tmp" in /|"") echo "ERROR: unsafe temporary path." >&2; exit 1;; esac; \
	trap 'rm -rf "$$tmp"' EXIT INT TERM; \
	cp tools/release "$$tmp/release"; \
	printf "1.0.0\n" > "$$tmp/VERSION"; \
	printf '# Changelog\n\n## [Unreleased]\n\n- Test release.\n' > "$$tmp/CHANGELOG.md"; \
	printf 'check:\n\t@true\n' > "$$tmp/Makefile"; \
	git -C "$$tmp" init -q -b main; \
	git -C "$$tmp" config user.name smoke; \
	git -C "$$tmp" config user.email smoke@example.invalid; \
	git -C "$$tmp" add VERSION CHANGELOG.md Makefile release; \
	git -C "$$tmp" commit -qm initial; \
	if (cd "$$tmp" && python3 release 1.1.0 >/dev/null 2>&1); then \
		echo "ERROR: release accepted a version argument." >&2; exit 1; \
	fi; \
	(cd "$$tmp" && printf '1.1.0\n' | python3 release >/dev/null); \
	test "$$(cat "$$tmp/VERSION")" = "1.1.0"; \
	git -C "$$tmp" rev-parse -q --verify refs/tags/v1.1.0 >/dev/null; \
	grep -Fq '## [1.1.0] -' "$$tmp/CHANGELOG.md"; \
	test -z "$$(git -C "$$tmp" status --short)"; \
	echo "OK"

release:
	@python3 tools/release

release-push:
	@set -eu; \
	branch="$$(git branch --show-current)"; \
	test "$$branch" = "main" || { echo "ERROR: releases must be pushed from main, not $$branch." >&2; exit 1; }; \
	version="$$(cat VERSION)"; \
	tag="v$$version"; \
	git rev-parse -q --verify "refs/tags/$$tag" >/dev/null || { echo "ERROR: missing $$tag. Run make release." >&2; exit 1; }; \
	git push origin main --follow-tags
