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
/// final-state assertions are deterministic. Never poll for intermediate `.loading`.
///
/// Test data uses future end times so `isOutdated` stays false and the catalog's
/// internal 5s auto-load loop can never interfere mid-test. The auto-load state
/// machine itself (autoLoadStatus) is intentionally untested for now: it depends on
/// real timer ticks and UIApplication.applicationState - flaky by construction.
/// Testing it would need an injectable check-signal source (future work).
@MainActor
@Suite("IkaCatalog")
struct IkaCatalogTests {
  static private let apparelInfo: SalmonApparelInfo = .init(
    apparel: .head(.oceanicHardHat),
    availableTime: TestData.anchor)

  private func makeCatalog(
    battle: @escaping @Sendable () async throws -> BattleRotationDict,
    salmon: @escaping @Sendable () async throws -> [SalmonRotation],
    apparel: @escaping @Sendable () async throws -> SalmonApparelInfo = { apparelInfo })
    -> IkaCatalog
  {
    IkaCatalog(
      ikaNetworkService: MockIkaNetworkService(
        battleRotationDictHandler: battle,
        salmonRotationsHandler: salmon,
        salmonRewardApparelInfoHandler: apparel),
      ikaClock: IkaClock())
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
    // Deliberately slow (~6s): exercises the REAL hardcoded 5s withTimeout wrapper.
    // Kept as the single slow test; fast timeout coverage lives in AsyncUtilsTests.
    let catalog = makeCatalog(
      battle: { try await hangingForever() },
      salmon: { [] })

    await catalog.refresh()

    #expect(catalog.loadStatus == .error(.connectionError))
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
