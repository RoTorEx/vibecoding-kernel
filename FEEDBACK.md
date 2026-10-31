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

### 2026-08-28 — Use .noindex for macOS app build directories

- Source project: `better-better-capture`
- Trigger: When a macOS GUI application routes Xcode DerivedData or other build output under construction_side, Spotlight can index nested .app bundles and present Debug builds as installed applications.
- Proposed action: For macOS app projects, place Xcode DerivedData and any directories containing generated .app bundles under a path ending in .noindex. When migrating an existing path, remove or unregister old indexed app artifacts and verify the new build is absent from Spotlight metadata.
- Reason: Spotlight otherwise treats generated Debug bundles as launchable installed apps, polluting search results and making users likely to open the wrong build.
- Evidence: A macOS child project showed Debug app results from both the default Xcode DerivedData and the kernel-directed construction_side path. After changing the project path to DerivedData.noindex and removing the old caches, mdls reported no metadata for the generated app and mdfind returned no matching build result.
- Scope and exceptions: Apply to macOS application projects and other Apple builds that generate .app bundles on Spotlight-indexed volumes. It is unnecessary for non-macOS projects or build locations already excluded from Spotlight; explicit user-provided paths may remain authoritative.
- Verification: Build the app, confirm the generated bundle path is inside a .noindex directory, confirm mdls has no record for that bundle, and confirm mdfind does not return it.
- Removal condition: Remove or narrow the rule if macOS reliably excludes all Xcode build products from Spotlight regardless of directory name, or if the kernel routes macOS build output into another location that is verifiably non-indexed by default.
- Status: `proposed`

### 2026-08-30 — Preserve macOS signing identity during local installs

- Source project: `better-better-capture`
- Trigger: A macOS app with TCC-managed permissions is rebuilt and replaced by a local install workflow.
- Proposed action: Build the installed configuration with a stable signing identity, verify its designated requirement before replacement, and fail installation instead of deploying an unsigned or changing ad-hoc-signed app.
- Reason: macOS binds privacy grants to the app's code-signing requirement; changing that identity can leave Settings showing permission enabled while the replacement process is denied.
- Evidence: A local install reused unsigned test-build flags, producing a linker-signed app identified only by a changing cdhash. An existing Screen Recording toggle remained enabled, but CGPreflightScreenCaptureAccess returned denied until the Apple Development-signed build with the original bundle identifier and team identity was restored.
- Scope and exceptions: Applies to macOS apps whose local install replaces an app using Screen Recording, Accessibility, Automation, microphone, camera, or similar TCC permissions. Unsigned builds remain acceptable for non-installed test/build artifacts that are never used as the authorized application.
- Verification: Run codesign --verify --deep --strict on the install source and inspect its designated requirement, bundle identifier, and team identity; reinstall twice and confirm the existing TCC permission remains effective after relaunch.
- Removal condition: Remove or narrow the rule if macOS stops binding these grants to code-signing requirements or the install workflow no longer replaces an app that uses TCC-managed permissions.
- Status: `proposed`

### 2026-09-06 — Preserve neighboring invariants during scoped changes

- Source project: `docket`
- Trigger: A task changes one stage of an established production workflow whose adjacent stages already have user-validated behavior or data ownership.
- Proposed action: Before editing, identify the current end-to-end happy path and its neighboring invariants. After editing, compare the full workflow diff and run focused checks for those invariants. Treat any unrelated behavior change as a regression to remove or explicitly justify in product truth.
- Reason: A locally plausible change can silently remove ordering, add a second decision authority, or insert new failure states into a previously working path. Unit success in the edited component does not show that the user's machine still works end to end.
- Evidence: One production repair found a removed user-owned sort, four independently writable fields for one decision, network enrichment placed before durable storage, and an extra browser control page. Each arose while implementing narrower requested features; the component checks passed while the daily workflow regressed.
- Scope and exceptions: Apply to maintenance and feature changes in an existing workflow with persisted data or user-validated behavior. Skip exhaustive end-to-end tracing for isolated new code that has no callers, stored state, or neighboring product contract.
- Verification: The final review names the happy path and preserved invariants, shows no unexplained adjacent diff, and includes at least one focused real or retained strong check for each data-owning boundary touched.
- Removal condition: Narrow or remove the rule if repeated audits show the normal task workflow already performs equivalent invariant mapping and end-to-end verification without regressions or added process burden.
- Status: `proposed`

### 2026-10-23 — Require committed, versioned delivery before declaring implementation complete

- Source project: `dacha`
- Trigger: Trigger: an implementation, fix, installation or deployment task reaches its intended delivery point, especially in a project with an established release workflow. Problem: the kernel specifies how to create a release and separately requires commits, but leaves room to call a checked snapshot deployment finished without entering the release workflow. An agent can treat permission to test or deploy as permission to leave an intermediate snapshot as the final product, or stop with working source changes that were never committed.
- Proposed action: Clarify OPERATING.md completion rules and connect them to RELEASE.md. Tests, builds and authorized temporary deployments may use working state or snapshots for intermediate verification. They are never final delivery. Verify behavior and commit completed implementation. If the project has a release process, ship changed product source only through a new version and that process's required commit/tag, artifacts and installation/deployment. Never finish with uncommitted code, a deployed snapshot, or new source under an unchanged version. Use existing authorization; if release approval is genuinely missing or release is explicitly deferred, report awaiting release rather than completed delivery. Restore or retire temporary deployments after checks unless explicitly retained as experiments. Rollback may restore a known previous release.
- Reason: A successful test or deployed snapshot proves behavior at one revision, not completed delivery. Leaving source uncommitted prevents durable recovery; leaving a new deployed revision under an old UI version makes the visible version cease to identify the running product and bypasses changelog/tag/artifact provenance. Temporary deployment permission must not silently redefine the completion criteria. The change closes the gap between the existing commit requirement and the release mechanics while preserving experimentation and explicit authorization boundaries.
- Evidence: Dacha's bfbbb83 added a local Reviewed prototype snapshots exception despite an existing release workflow. After a chart-dot fix, the agent treated the user's ordinary deploy request as authorization for that path and left committed snapshot 4e48838 deployed while VERSION and the footer still said 0.3.4, with no new tag or GitHub Release. The user asked whether there was a new patch and rejected this completion state. Correction 58104f6 removed the exception; release commit 0f90d4e produced v0.3.5, published artifacts and a matching deployment; 6a9f790 records live readback. The observed incident was snapshot-as-final-delivery, not uncommitted code; the user explicitly extends the proposed general rule to forbid either final state. The agent was responsible for applying the exception without explicit prototype intent.
- Scope and exceptions: Applies to completed implementation and changed-product delivery across kernel child projects. Keep tests, exploratory runs and temporary test deployments available within their existing permissions. Read-only audits, research and proposal-only tasks do not require commits or releases. Pure operation of an unchanged existing release does not need a new version. Do not invent a release system for projects without one. An explicit stop, experiment-only request, release deferral or missing required approval can leave unfinished work, but the report must identify that state and remaining steps instead of declaring delivery complete. Preserve unrelated local changes and do not force-push or commit failing work to satisfy this rule. Product-specific release commands and version increments remain locally owned.
- Verification: Review completion claims against the actual repository and intended destination. Task changes must belong to a verified commit. For release-backed delivery, confirm the native version sources, release commit/tag, required published artifacts and any installed/deployed version and revision agree. Test scenarios should include temporary snapshot verification followed by release; a deploy request with existing release authority; missing authority reported as awaiting release; explicit experiment-only work; rollback; and a project with no release system. Reject scenarios that claim completed delivery with only uncommitted changes or an unreleased snapshot, even when tests and health checks passed. Verify temporary state is restored or explicitly retained and labeled as experimental.
- Removal condition: Merge or narrow this wording if existing canonical completion and release rules are revised to enforce the same distinction, or evidence shows a project has another explicitly user-approved durable delivery process with equivalent provenance. Do not remove it merely because snapshots pass checks. Keep the user's separation between intermediate experimentation and final committed, versioned delivery. This submission proposes a kernel change only; it does not itself change active rules or authorize a kernel release.
- Status: `proposed`
