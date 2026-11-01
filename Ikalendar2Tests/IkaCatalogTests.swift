//
//  IkaCatalogTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaCatalogTests

/// State-machine tests against MockIkaNetworkService.
///
/// Assertion strategy: only assert AFTER `await catalog.refresh()` returns - the
/// status-transition delays (0.2s loaded / 1s error) complete inside refresh(), so
/// final-state assertions are deterministic. Do not poll for intermediate `.loading`,
/// except in the cancellation tests: they wait for it to know a hanging load is in flight.
///
/// The load timeout is injected: a generous one for every test except the dedicated
/// timeout test, so a congested CI runner can never turn a mocked success into a
/// spurious `connectionError`.
///
/// Test data uses future end times so `isOutdated` stays false and the catalog's
/// internal 5s auto-load loop can never interfere mid-test. The auto-load state
/// machine has its own suite (IkaCatalogAutoLoadTests) on injected short intervals.
@MainActor
@Suite("IkaCatalog")
struct IkaCatalogTests {
  static private let apparelInfo: SalmonApparelInfo = .init(
    apparel: .head(.oceanicHardHat),
    availableTime: TestData.anchor)

  private func makeCatalog(
    battle: @escaping @Sendable () async throws -> BattleRotationDict,
    salmon: @escaping @Sendable () async throws -> [SalmonRotation],
    apparel: @escaping @Sendable () async throws -> SalmonApparelInfo = { apparelInfo },
    loadTimeout: TimeInterval = 60)
    -> IkaCatalog
  {
    var timing: IkaCatalog.Timing = .standard
    timing.loadTimeout = loadTimeout
    return IkaCatalog(
      ikaNetworkService: MockIkaNetworkService(
        battleRotationDictHandler: battle,
        salmonRotationsHandler: salmon,
        salmonRewardApparelInfoHandler: apparel),
      ikaClock: IkaClock(),
      timing: timing)
  }

  // MARK: - Success

  @Test
  func `Successful refresh loads data and reaches loaded state`() async {
    let dict: BattleRotationDict = TestData.battleDict()
    let salmon = [
      TestData.salmonRotation(startOffset: -3600, endOffset: 41 * 3600, from: .init()),
      TestData.salmonRotation(startOffset: 41 * 3600, endOffset: 83 * 3600, from: .init()),
    ]
    let catalog = makeCatalog(battle: { dict }, salmon: { salmon })

    await catalog.refresh()

    #expect(catalog.loadStatus == .loaded)
    #expect(catalog.loadResultStatus == .loaded)
    #expect(catalog.battleRotationDict == dict)
    #expect(catalog.salmonRotations.count == 2)
    // Apparel availableTime (anchor) matches no rotation start above.
    #expect(catalog.salmonRotations.allSatisfy { $0.rewardApparel == nil })
  }

  @Test
  func `Reward apparel attaches to the rotation with matching start time`() async {
    let matching: SalmonRotation = TestData.salmonRotation(startOffset: 0, endOffset: 42 * 3600) // starts at anchor
    let other: SalmonRotation = TestData.salmonRotation(startOffset: 42 * 3600, endOffset: 84 * 3600)
    let catalog = makeCatalog(
      battle: { TestData.battleDict() },
      salmon: { [matching, other] })

    await catalog.refresh()

    #expect(catalog.salmonRotations.first?.rewardApparel == .head(.oceanicHardHat))
    #expect(catalog.salmonRotations.last?.rewardApparel == nil)
  }

  // MARK: - Failure

  @Test
  func `Battle fetch failure surfaces the server error`() async {
    let catalog = makeCatalog(
      battle: { throw IkaError.serverError(.badData) },
      salmon: { [] })

    await catalog.refresh()

    #expect(catalog.loadStatus == .error(.serverError(.badData)))
    #expect(catalog.loadResultStatus == .error(.serverError(.badData)))
    #expect(catalog.battleRotationDict.hasEmptyMode) // data untouched on failure
  }

  @Test
  func `Connection failure surfaces connectionError`() async {
    let catalog = makeCatalog(
      battle: { throw IkaError.connectionError },
      salmon: { throw IkaError.connectionError })

    await catalog.refresh()

    #expect(catalog.loadStatus == .error(.connectionError))
  }

  @Test
  func `Partial failure discards the whole batch`() async {
    // loadData only assigns after ALL fetches succeed - a salmon failure must not
    // leave half-updated battle data behind.
    let catalog = makeCatalog(
      battle: { TestData.battleDict() },
      salmon: { throw IkaError.serverError(.badResponse) })

    await catalog.refresh()

    #expect(catalog.loadStatus == .error(.serverError(.badResponse)))
    #expect(catalog.battleRotationDict.hasEmptyMode)
    #expect(catalog.salmonRotations.isEmpty)
  }

  @Test
  func `Unrecognized error maps to unknownError`() async {
    struct DummyError: Error { }
    let catalog = makeCatalog(
      battle: { throw DummyError() },
      salmon: { [] })

    await catalog.refresh()

    #expect(catalog.loadStatus == .error(.unknownError))
  }

  @Test
  func `Refresh after an error recovers`() async {
    let succeed: FlipFlag = .init()
    let catalog = makeCatalog(
      battle: {
        if await succeed.value {
          return TestData.battleDict()
        }
        await succeed.set()
        throw IkaError.connectionError
      },
      salmon: { [] })

    await catalog.refresh()
    #expect(catalog.loadStatus == .error(.connectionError))

    await catalog.refresh()
    #expect(catalog.loadStatus == .loaded)
    #expect(!catalog.battleRotationDict.hasEmptyMode)
  }

  // MARK: - Timeout

  @Test(.timeLimit(.minutes(1)))
  func `Hanging fetch times out into connectionError`() async {
    // Exercises the catalog's withTimeout wiring end to end with a short injected
    // timeout; finer-grained timeout coverage lives in AsyncUtilsTests.
    let catalog = makeCatalog(
      battle: { try await hangingForever() },
      salmon: { [] },
      loadTimeout: 1)

    await catalog.refresh()

    #expect(catalog.loadStatus == .error(.connectionError))
  }

  // MARK: - Cancellation

  @Test(.timeLimit(.minutes(1)))
  func `Cancelled refresh restores the last result instead of staying in loading`() async {
    // The second refresh hangs until it is cancelled, like a pull-to-refresh whose view
    // leaves the hierarchy mid-load. A catalog left in `.loading` would stay disabled.
    let hasLoadedOnce: FlipFlag = .init()
    let catalog = makeCatalog(
      battle: {
        if await hasLoadedOnce.value {
          return try await hangingForever()
        }
        await hasLoadedOnce.set()
        return TestData.battleDict()
      },
      salmon: { [] })

    await catalog.refresh()
    #expect(catalog.loadStatus == .loaded)

    let secondRefresh = Task { await catalog.refresh() }
    await waitUntil { catalog.loadStatus == .loading }
    secondRefresh.cancel()
    await secondRefresh.value

    #expect(catalog.loadStatus == .loaded)
    #expect(catalog.loadResultStatus == .loaded)
    #expect(!catalog.battleRotationDict.hasEmptyMode) // the first result is kept
  }

  @Test(.timeLimit(.minutes(1)))
  func `Cancelled refresh keeps loading while another load is in flight`() async {
    // Two overlapping refreshes, e.g. a pull-to-refresh during an onboarding load. Only the
    // last load in flight may restore the result, whichever of the two is cancelled first.
    let hasLoadedOnce: FlipFlag = .init()
    let catalog = makeCatalog(
      battle: {
        if await hasLoadedOnce.value {
          return try await hangingForever()
        }
        await hasLoadedOnce.set()
        return TestData.battleDict()
      },
      salmon: { [] })

    await catalog.refresh()
    #expect(catalog.loadStatus == .loaded)

    let older = Task { await catalog.refresh() }
    await waitUntil { catalog.loadStatus == .loading }

    let newer = Task { await catalog.refresh() }
    newer.cancel()
    await newer.value
    #expect(catalog.loadStatus == .loading) // the older load still owns the status

    older.cancel()
    await older.value
    #expect(catalog.loadStatus == .loaded)
    #expect(catalog.loadResultStatus == .loaded)
  }

  @Test(.timeLimit(.minutes(1)))
  func `Cancelling the older refresh first keeps loading while the newer one is in flight`() async {
    // The mirror case of the test above. Both hanging fetches must have started before the
    // older load is cancelled, so the newer load is known to be in flight.
    let hasLoadedOnce: FlipFlag = .init()
    let hangingFetches: CallCounter = .init()
    let catalog = makeCatalog(
      battle: {
        if await hasLoadedOnce.value {
          await hangingFetches.increment()
          return try await hangingForever()
        }
        await hasLoadedOnce.set()
        return TestData.battleDict()
      },
      salmon: { [] })

    await catalog.refresh()
    #expect(catalog.loadStatus == .loaded)

    let older = Task { await catalog.refresh() }
    await waitUntil { hangingFetches.count == 1 }
    let newer = Task { await catalog.refresh() }
    await waitUntil { hangingFetches.count == 2 }

    older.cancel()
    await older.value
    #expect(catalog.loadStatus == .loading) // the newer load still owns the status

    newer.cancel()
    await newer.value
    #expect(catalog.loadStatus == .loaded)
    #expect(catalog.loadResultStatus == .loaded)
  }
}

// MARK: - FlipFlag

/// Minimal async-safe boolean for call-sequencing in @Sendable mock closures.
private actor FlipFlag {
  private(set) var value = false

  func set() {
    value = true
  }
}

// MARK: - CallCounter

/// Counts calls from @Sendable mock closures; main-actor tests read it synchronously.
@MainActor
private final class CallCounter {
  private(set) var count = 0

  func increment() {
    count += 1
  }
}
