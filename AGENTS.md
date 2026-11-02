# ikalendar2

iOS/SwiftUI app that tracks Splatoon 2 rotation schedules. See `README.md` for the overview.

## Working agreements

- Commit messages and PR text are in English, conventional commits (`fix`, `feat`, `refactor`, `chore`, `docs`, `test`, `style`). Stated by the owner during the v2.4.x quality-overhaul session (2026-07).
- Never change core business logic or redesign the UI without explicit approval. Propose the change instead.
- Formatting follows the project's `.swiftformat` and `.swiftlint.yml`. The owner re-runs the linters on their own, so minor lint issues are acceptable.

## Architecture after the 2026-07 quality overhaul

State as of the overhaul (branch `claude/clever-hamilton-6e120a`, 13 commits on top of v2.4.0, later merged through PR #30 `refactor/quality-overhaul`):

- Swift 6 language mode plus `SWIFT_APPROACHABLE_CONCURRENCY` on all targets. There is no default MainActor isolation: the decode path is deliberately `nonisolated` via `@concurrent`.
- Zero singletons. `Ikalendar2App` is the composition root. Stores are `@Observable @MainActor` classes in `Models/Stores` (`IkaCatalog`, `IkaStatus`, `IkaPreference`, `IkaDiscoveryLog`) and `Models/Monitors` (`IkaClock`, `IkaDeviceMotionMonitor`, `IkaOrientationMonitor`, `IkaConnectivityChecker`).
- The `IkaNetworkService` protocol plus an `@Entry` environment key enable test mocks. The app injects an `InertNetworkService` when it runs as a unit-test host, which prevents main-actor contention flakiness.
- `IkaDecoder` was rewritten on native Codable with a private wire-DTO layer (`FlexibleIntID` handles string-or-int ids). The SwiftyJSON dependency is gone; only SimpleHaptics and AlertKit remain.
- OSLog loggers (network, decode, store) are wired at the places that used to swallow errors. `IkaNetworkManager` has a dedicated session with 10 s and 30 s timeouts. `AssetImageCounter` memoizes behind `OSAllocatedUnfairLock` (the Kit targets iOS 17, so no `Mutex`).
- CI pins SwiftFormat 0.64.5 and SwiftLint 0.65.1 from release binaries (`.github/workflows/build-and-test.yml`), clones SPM packages into `SourcePackages` (gitignored, not cached: restoring the cache took longer than cloning), runs lint, the tests and the Release build as three parallel jobs, and boots the simulator during the build. Dependabot watches swift and actions.
- Owner decisions: no product extensions yet (the Widget is the agreed next candidate), no snapshot tests, Live Activity permanently skipped.

## Deliberate designs that must not be cleaned up

These were verified by git archaeology. Violating them reintroduces bugs that took expensive investigation to fix. Read this list before refactoring state management, timers or tests.

- Nudge and pulse timers stay owned by the view that shows them: `IconNudge` and `PeriodicPulse` keep their trigger in their own `@State` and loop in that view's `.task`. Hoisting them into shared state caused cross-view pulsing bugs (commits `a5bfe35` then `20a3489`). No `Timer.publish` is left; the last one was replaced in `2f132c3`, whose message explains why the original cause no longer applies.
- `IkaOrientationMonitor` defers reads by one main-actor turn (`Task { }`) because `effectiveGeometry` lags the orientation notification on iPadOS (commit `00fe4e4`).
- The `loadResultStatus` dedupe check in `IkaCatalog.loadStatus.didSet` is load-bearing (commit `fbc49af`).
- UserDefaults keys and raw-value encodings must stay byte-identical for upgrade safety. Bool reads must use `object(forKey:)` presence checks, because onboarding defaults to true.
- `BattleRotationDict.isOutdated` consults `.gachi` only, since all modes rotate together. Tests pin this.
- In `BattleRotationCell` the featured primary variant is the matched-geometry source and the compact secondary uses `isSource: false`. The source must be the variant that stays at a rotation flip: with the roles reversed (`ebf2438`), the new Now card kept the removed card's frames and lost its rule and stages (fixed in `05f96cb`).
- The mode stamp's dock progress (`RotationsTabView`) is measured from the list's resting position (`contentOffset.y` plus the first layout's top inset), not from the current inset: under a finger drag the inset shrinks while the large title collapses, and it stays shrunk when rows above are removed while scrolled (`f1f1ce7`).
- `IkaClock` publishes snapped whole seconds, so rotation boundaries are hit exactly; `isNext(t)` is `isCurrent(t + 2h)` so Now and Next flip on the same tick (`d416deb`).

## Testing

- 231 Swift Testing tests (181 in `Ikalendar2Tests`, hosted; 50 in `IkalendarKitTests`) as of 2026-11-01. Run with `xcodebuild test -scheme Ikalendar2`.
- SwiftFormat's `propertyTypes` rule mangles `let x = TestData.factory(...)` into wrong type annotations. Always write explicit, correct types for factory-returned lets in tests.
- The Debug and Release builds compile with zero warnings (Xcode 27.2, 2026-11-01); a new warning is a regression.
