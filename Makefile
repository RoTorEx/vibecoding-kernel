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
	@grep -Fq 'in local Git.' core/OPERATING.md
	@grep -Fq 'Push only with authorization for the destination and scope' core/OPERATING.md
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
	python3 tools/vibe-pull --new-project="$$name" -- "$$target"

smoke-new-project:
	@set -eu; \
	test_root="$$(mktemp -d "$${TMPDIR:-/tmp}/vibe-stage1.XXXXXX")"; \
	case "$$test_root" in /|"") echo "ERROR: unsafe temporary path." >&2; exit 1;; esac; \
	trap 'rm -rf "$$test_root"' EXIT INT TERM; \
	export GIT_AUTHOR_NAME=smoke GIT_AUTHOR_EMAIL=smoke@example.invalid GIT_COMMITTER_NAME=smoke GIT_COMMITTER_EMAIL=smoke@example.invalid; \
	export GIT_CONFIG_COUNT=3 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false \
		GIT_CONFIG_KEY_1=tag.gpgsign GIT_CONFIG_VALUE_1=false GIT_CONFIG_KEY_2=core.hooksPath GIT_CONFIG_VALUE_2=/dev/null; \
	kernel="$$test_root/kernel"; \
	tmp="$$test_root/initial"; \
	mkdir -p "$$kernel/tools" "$$tmp"; \
	cp Makefile VERSION "$$kernel/"; \
	cp -R core templates "$$kernel/"; \
	cp tools/vibe-pull "$$kernel/tools/"; \
	git -C "$$kernel" init -q -b main; \
	git -C "$$kernel" add -- Makefile VERSION core templates tools/vibe-pull; \
	git -C "$$kernel" commit -qm 'Fixture release'; \
	tag="v$$(cat VERSION)"; \
	git -C "$$kernel" tag "$$tag"; \
	printf '99.99.99\n' > "$$kernel/VERSION"; \
	printf '# Unreleased changes\n' > "$$kernel/core/OPERATING.md"; \
	printf '# Future contract\n' > "$$kernel/core/FUTURE.md"; \
	printf '# Unreleased scaffold\n' > "$$kernel/templates/project-skeleton/README.md"; \
	git -C "$$tmp" init -q; \
	$(MAKE) -C "$$kernel" new-project TARGET="$$tmp" NAME=stage-one-smoke >/dev/null; \
	test "$$(git -C "$$tmp" branch --show-current)" = "main"; \
	test "$$(git -C "$$tmp" log -1 --format=%s)" = "Initial commit"; \
	test "$$(git -C "$$tmp" rev-list --count HEAD)" = "1"; \
	test -z "$$(git -C "$$tmp" status --porcelain)"; \
	cmp core/OPERATING.md "$$tmp/.vibe/kernel/OPERATING.md"; \
	test ! -e "$$tmp/.vibe/kernel/FUTURE.md"; \
	grep -Fq '# stage-one-smoke' "$$tmp/README.md"; \
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
	grep -Fq 'Audits stay read-only.' "$$tmp/.vibe/kernel/OPERATING.md"; \
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
	printf 'old content\n' > "$$tmp/.vibe/kernel/OPERATING.md"; \
	(cd "$$tmp" && make vibe-pull >/dev/null); \
	cmp core/OPERATING.md "$$tmp/.vibe/kernel/OPERATING.md"; \
	test ! -e "$$tmp/.vibe/kernel/FUTURE.md"; \
	grep -q "Durable local fact" "$$tmp/BUSINESS.md"; \
	grep -Fq 'local-command:' "$$tmp/Makefile"; \
	test "$$(grep -Fc '# VIBE:KERNEL_MAKE_START' "$$tmp/Makefile")" = "1"; \
	test ! -e "$$tmp/.vibe/kernel/LEGACY.md"; \
	test ! -e "$$tmp/.vibe/kernel/examples"; \
	count="$$(find "$$tmp/.vibe/kernel" -maxdepth 1 -type f | wc -l | tr -d ' ')"; \
	expected="$$(find core -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"; \
	test "$$count" = "$$((expected + 1))"; \
	legacy="$$test_root/legacy-project"; \
	mkdir -p "$$legacy"; \
	cp templates/project-skeleton/AGENTS.md "$$legacy/AGENTS.md"; \
	printf 'check:\n\t@true  \n# exact local tail  ' > "$$legacy/Makefile"; \
	cp "$$legacy/Makefile" "$$legacy/Makefile.before"; \
	python3 "$$kernel/tools/vibe-pull" "$$legacy" >/dev/null; \
	python3 -c "from pathlib import Path; import sys; before=Path(sys.argv[1]).read_bytes(); after=Path(sys.argv[2]).read_bytes(); assert after.startswith(before + b'\\n\\n# VIBE:KERNEL_MAKE_START\\n')" "$$legacy/Makefile.before" "$$legacy/Makefile"; \
	grep -Fq 'check:' "$$legacy/Makefile"; \
	grep -Fq 'vibe-propose:' "$$legacy/Makefile"; \
	cp "$$legacy/Makefile" "$$legacy/Makefile.after-first-pull"; \
	python3 "$$kernel/tools/vibe-pull" "$$legacy" >/dev/null; \
	cmp "$$legacy/Makefile.after-first-pull" "$$legacy/Makefile"; \
	fresh="$$test_root/fresh-project"; \
	$(MAKE) -C "$$kernel" new-project TARGET="$$fresh" NAME=fresh-project >/dev/null; \
	test "$$(git -C "$$fresh" branch --show-current)" = "main"; \
	test "$$(git -C "$$fresh" log -1 --format=%s)" = "Initial commit"; \
	test -z "$$(git -C "$$fresh" status --porcelain)"; \
	staged="$$test_root/staged-project"; \
	git init -q "$$staged"; \
	printf 'keep\n' > "$$staged/keep.txt"; \
	git -C "$$staged" add -- keep.txt; \
	rm "$$staged/keep.txt"; \
	! python3 "$$kernel/tools/vibe-pull" --new-project=staged-project "$$staged" > "$$test_root/staged.out" 2>&1; \
	grep -Fq 'Git index must be empty' "$$test_root/staged.out"; \
	test ! -e "$$staged/README.md"; \
	test "$$(git -C "$$staged" ls-files)" = "keep.txt"; \
	git -C "$$kernel" tag -d "$$tag" >/dev/null; \
	! (cd "$$fresh" && make vibe-pull > "$$test_root/missing-tag.out" 2>&1); \
	grep -Fq "Kernel release $$tag is missing" "$$test_root/missing-tag.out"; \
	test -z "$$(git -C "$$fresh" status --porcelain)"; \
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
