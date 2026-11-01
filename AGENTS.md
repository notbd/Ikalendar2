# ikalendar2

iOS/SwiftUI app that tracks Splatoon 2 rotation schedules. See `README.md` for the overview.

## Working agreements

- Commit messages and PR text are in English, conventional commits (`fix`, `feat`, `refactor`, `chore`, `docs`, `test`, `style`). Stated by the owner during the v2.4.x quality-overhaul session (2026-07).
- Never change core business logic or redesign the UI without explicit approval. Propose the change instead.
- Formatting follows the project's `.swiftformat` and `.swiftlint.yml`. The owner re-runs the linters on their own, so minor lint issues are acceptable.
- Git commits are SSH-signed through 1Password. If signing fails (a timeout means the owner is away), stop and ask the owner to authorize, then retry. Never bypass with `commit.gpgsign=false` or `--no-gpg-sign` (global rule in `~/.claude/docs/work-rules.md`).

## Architecture after the 2026-07 quality overhaul

State as of the overhaul (branch `claude/clever-hamilton-6e120a`, 13 commits on top of v2.4.0, later merged through PR #30 `refactor/quality-overhaul`):

- Swift 6 language mode plus `SWIFT_APPROACHABLE_CONCURRENCY` on all targets. There is no default MainActor isolation: the decode path is deliberately `nonisolated` via `@concurrent`.
- Zero singletons. `Ikalendar2App` is the composition root. Stores are `@Observable @MainActor` classes in `Models/Stores` (`IkaCatalog`, `IkaStatus`, `IkaPreference`, `IkaDiscoveryLog`) and `Models/Monitors` (`IkaClock`, `IkaDeviceMotionMonitor`, `IkaOrientationMonitor`, `IkaConnectivityChecker`).
- The `IkaNetworkService` protocol plus an `@Entry` environment key enable test mocks. The app injects an `InertNetworkService` when it runs as a unit-test host, which prevents main-actor contention flakiness.
- `IkaDecoder` was rewritten on native Codable with a private wire-DTO layer (`FlexibleIntID` handles string-or-int ids). The SwiftyJSON dependency is gone; only SimpleHaptics and AlertKit remain.
- OSLog loggers (network, decode, store) are wired at the places that used to swallow errors. `IkaNetworkManager` has a dedicated session with 10 s and 30 s timeouts. `AssetImageCounter` memoizes behind `OSAllocatedUnfairLock` (the Kit targets iOS 17, so no `Mutex`).
- CI pins SwiftFormat 0.61.1 and SwiftLint 0.63.3 from release binaries, caches SPM with `-clonedSourcePackagesDirPath SourcePackages` (gitignored), and Dependabot watches swift and actions.
- Owner decisions: no product extensions yet (the Widget is the agreed next candidate), no snapshot tests, Live Activity permanently skipped.

## Deliberate designs that must not be cleaned up

These were verified by git archaeology. Violating them reintroduces bugs that took expensive investigation to fix. Read this list before refactoring state management, timers or tests.

- View-local `Timer.publish` plus `.onReceive` nudge and pulse timers in `SettingsAboutView`, `SettingsMainView` and `SettingsDebugOptionsView`. Hoisting them into shared state caused cross-view pulsing bugs (commits `a5bfe35` then `20a3489`).
- `IkaOrientationMonitor` defers reads by one main-actor turn (`Task { }`) because `effectiveGeometry` lags the orientation notification on iPadOS (commit `00fe4e4`).
- The `loadResultStatus` dedupe check in `IkaCatalog.loadStatus.didSet` is load-bearing (commit `fbc49af`).
- UserDefaults keys and raw-value encodings must stay byte-identical for upgrade safety. Bool reads must use `object(forKey:)` presence checks, because onboarding defaults to true.
- `BattleRotationDict.isOutdated` consults `.gachi` only, since all modes rotate together. Tests pin this.

## Testing

- 162 Swift Testing tests across `IkalendarKitTests` and `Ikalendar2Tests` (hosted). Run with `xcodebuild test -scheme Ikalendar2`.
- SwiftFormat's `propertyTypes` rule mangles `let x = TestData.factory(...)` into wrong type annotations. Always write explicit, correct types for factory-returned lets in tests.
- Known accepted warnings: two `keyframeAnimator` metatype captures (SwiftUI SDK friction).
