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
