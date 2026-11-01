//
//  IkaCatalogAutoLoadTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaCatalogAutoLoadTests

/// Auto-load state machine tests on injected millisecond intervals.
///
/// Every state a test inspects is held in place rather than caught in passing: a held battle
/// request keeps a cycle in `.autoLoading`, and an inactive app keeps a finished cycle in
/// `.autoLoaded`. Waits poll with a generous deadline, so a slow runner only makes them slower.
///
/// Each test ends with `settle`: fresh data and an idle machine, so no auto-load task outlives
/// the test and competes with later suites for the main actor.
@MainActor
@Suite("IkaCatalog auto-load")
struct IkaCatalogAutoLoadTests {
  /// Short intervals so a whole cycle takes milliseconds. The load timeout stays generous so
  /// a slow runner cannot turn a mocked success into a timeout.
  static private let timing: IkaCatalog.Timing = .init(
    loadTimeout: 60,
    loadStatusLoadedDelay: 0,
    loadStatusErrorDelay: 0,
    autoLoadCheckInterval: 0.02,
    autoLoadAttemptInterval: 0.01,
    autoLoadBattleMaxAttempts: 3,
    autoLoadSalmonMaxAttempts: 3,
    appActiveStateCheckInterval: 0.01,
    autoLoadedLingerLength: 0.02,
    idleAndNonIdleStatusUpdateInterval: 0.02)

  /// Battle rotations whose current slot ended two hours ago, as after sleeping through a
  /// rotation boundary.
  private func makeStaleBattleDict() -> BattleRotationDict {
    TestData.battleDict(reference: .init(timeIntervalSinceNow: -3 * 3600))
  }

  private func makeCatalog(
    _ scenario: AutoLoadScenario,
    timing: IkaCatalog.Timing)
    -> IkaCatalog
  {
    let apparelInfo: SalmonApparelInfo = .init(apparel: .head(.oceanicHardHat), availableTime: TestData.anchor)
    return IkaCatalog(
      ikaNetworkService: MockIkaNetworkService(
        battleRotationDictHandler: { try await scenario.fetchBattleRotationDict() },
        salmonRotationsHandler: { await scenario.fetchSalmonRotations() },
        salmonRewardApparelInfoHandler: { apparelInfo }),
      ikaClock: IkaClock(),
      timing: timing,
      isAppActive: { scenario.isAppActive })
  }

  /// Serves fresh data and lets every pending step run, then waits for the machine to idle.
  private func settle(_ catalog: IkaCatalog, _ scenario: AutoLoadScenario) async {
    scenario.battleRotationDict = TestData.battleDict()
    scenario.isBattleFetchHeld = false
    scenario.battleFetchError = nil
    scenario.isAppActive = true
    await waitUntil {
      !catalog.battleRotationDict.isOutdated(.init()) &&
        catalog.autoLoadStatus == .idle &&
        catalog.autoLoadDisplayStatus == .idle
    }
  }

  // MARK: - Tests

  @Test(.timeLimit(.minutes(1)))
  func `Stale data auto-loads fresh data and falls back to idle`() async {
    let scenario: AutoLoadScenario = .init(battleRotationDict: makeStaleBattleDict())
    scenario.isAppActive = false // holds the finished cycle in `.autoLoaded` until released
    let catalog = makeCatalog(scenario, timing: Self.timing)

    await catalog.refresh()
    #expect(catalog.loadStatus == .loaded)

    // The server has the next rotations now; hold the request to see the cycle in flight.
    let freshDict: BattleRotationDict = TestData.battleDict()
    scenario.battleRotationDict = freshDict
    scenario.isBattleFetchHeld = true
    await waitUntil { catalog.autoLoadStatus == .autoLoading }
    #expect(catalog.autoLoadDisplayStatus == .autoLoading)

    scenario.isBattleFetchHeld = false
    await waitUntil { catalog.autoLoadStatus == .autoLoaded(.success) }
    #expect(catalog.battleRotationDict == freshDict)
    #expect(catalog.loadStatus == .loaded)
    #expect(catalog.autoLoadDisplayStatus == .autoLoaded(.success))

    // The result lingers until the app is active, then both statuses fall back to idle.
    scenario.isAppActive = true
    await waitUntil { catalog.autoLoadStatus == .idle }
    await waitUntil { catalog.autoLoadDisplayStatus == .idle }

    await settle(catalog, scenario)
  }

  @Test(.timeLimit(.minutes(1)))
  func `Server stuck on stale data fails the cycle after the max attempts`() async {
    let staleDict: BattleRotationDict = makeStaleBattleDict()
    let scenario: AutoLoadScenario = .init(battleRotationDict: staleDict)
    scenario.isAppActive = false // holds the finished cycle in `.autoLoaded`
    let catalog = makeCatalog(scenario, timing: Self.timing)

    await catalog.refresh()
    await waitUntil { catalog.autoLoadStatus == .autoLoaded(.failure) }

    // One fetch for the refresh, then one per attempt. The failure is held, so no new
    // cycle has started.
    #expect(scenario.battleFetchCount == 1 + Self.timing.autoLoadBattleMaxAttempts)
    #expect(catalog.loadStatus == .loaded)
    #expect(catalog.loadResultStatus == .loaded)
    #expect(catalog.battleRotationDict == staleDict)

    await settle(catalog, scenario)
  }

  @Test(.timeLimit(.minutes(1)))
  func `A new cycle is not reset by the linger of the previous cycle`() async {
    // A long idle delay opens a window after the failed cycle falls back to `.idle`, in
    // which the next check starts a new cycle while the old linger still sleeps.
    var timing: IkaCatalog.Timing = Self.timing
    timing.idleAndNonIdleStatusUpdateInterval = 0.5
    let scenario: AutoLoadScenario = .init(battleRotationDict: makeStaleBattleDict())
    scenario.isAppActive = false // holds the failed cycle in `.autoLoaded` until released
    let catalog = makeCatalog(scenario, timing: timing)

    await catalog.refresh()
    await waitUntil { catalog.autoLoadStatus == .autoLoaded(.failure) }

    // Hold the next cycle's request, then let the failed cycle's linger run.
    scenario.isBattleFetchHeld = true
    scenario.isAppActive = true
    await waitUntil { catalog.autoLoadStatus == .autoLoading }
    #expect(catalog.autoLoadDisplayStatus == .autoLoading)

    // Outlast the old linger's idle delay; a linger that was not cancelled would reset
    // the delayed status of the running cycle to `.idle` here.
    try? await Task.sleep(for: .seconds(1.5))
    #expect(catalog.autoLoadStatus == .autoLoading)
    #expect(catalog.autoLoadDisplayStatus == .autoLoading)

    await settle(catalog, scenario)
  }

  @Test(.timeLimit(.minutes(1)))
  func `Salmon exhausting its attempts does not fail a successful battle auto-load`() async {
    // The shift ended an hour ago and the server keeps serving it, as when the salmon feed
    // updates later than the battle feed at a shared rotation boundary.
    let staleSalmonRotations: [SalmonRotation] = [
      TestData.salmonRotation(startOffset: -3 * 3600, endOffset: -3600, from: .init()),
    ]
    let scenario: AutoLoadScenario = .init(battleRotationDict: makeStaleBattleDict())
    scenario.salmonRotations = staleSalmonRotations
    scenario.isAppActive = false // holds the finished cycle in `.autoLoaded`
    let catalog = makeCatalog(scenario, timing: Self.timing)

    await catalog.refresh()
    let freshDict: BattleRotationDict = TestData.battleDict()
    scenario.battleRotationDict = freshDict
    let finished: [IkaCatalog.AutoLoadStatus] = [.autoLoaded(.success), .autoLoaded(.failure)]
    await waitUntil { finished.contains(catalog.autoLoadStatus) }

    #expect(catalog.autoLoadStatus == .autoLoaded(.success))
    #expect(catalog.autoLoadDisplayStatus == .autoLoaded(.success))
    #expect(catalog.battleRotationDict == freshDict)
    #expect(catalog.salmonRotations == staleSalmonRotations)
    // One fetch for the refresh, then one per attempt.
    #expect(scenario.salmonFetchCount == 1 + Self.timing.autoLoadSalmonMaxAttempts)

    await settle(catalog, scenario)
  }

  @Test(.timeLimit(.minutes(1)))
  func `A connection error during auto-load keeps the loaded rotations visible`() async {
    let staleDict: BattleRotationDict = makeStaleBattleDict()
    let scenario: AutoLoadScenario = .init(battleRotationDict: staleDict)
    scenario.isAppActive = false // holds the finished cycle in `.autoLoaded`
    let catalog = makeCatalog(scenario, timing: Self.timing)

    await catalog.refresh()
    scenario.battleFetchError = .connectionError
    let finished: [IkaCatalog.AutoLoadStatus] = [.autoLoaded(.success), .autoLoaded(.failure)]
    await waitUntil { finished.contains(catalog.autoLoadStatus) }

    #expect(catalog.autoLoadStatus == .autoLoaded(.failure))
    #expect(catalog.autoLoadDisplayStatus == .autoLoaded(.failure))
    #expect(catalog.loadStatus == .loaded)
    #expect(catalog.loadResultStatus == .loaded)
    #expect(catalog.battleRotationDict == staleDict)

    await settle(catalog, scenario)
  }
}

// MARK: - AutoLoadScenario

/// The outside world of one test's catalog: what the battle and salmon endpoints serve,
/// whether battle requests are held, and whether the app is active.
@MainActor
final private class AutoLoadScenario {
  var battleRotationDict: BattleRotationDict
  /// By default the next shift starts in an hour, so salmon data never needs an auto-load
  /// and only the battle path runs.
  var salmonRotations: [SalmonRotation] = [
    TestData.salmonRotation(startOffset: 3600, endOffset: 43 * 3600, from: .init()),
  ]
  /// While true, battle requests wait (cooperatively, so they stay cancellable).
  var isBattleFetchHeld: Bool = false
  /// While set, battle requests throw it.
  var battleFetchError: IkaError?
  var isAppActive: Bool = true
  private(set) var battleFetchCount: Int = 0
  private(set) var salmonFetchCount: Int = 0

  init(battleRotationDict: BattleRotationDict) {
    self.battleRotationDict = battleRotationDict
  }

  func fetchBattleRotationDict() async throws -> BattleRotationDict {
    battleFetchCount += 1
    while isBattleFetchHeld {
      try await Task.sleep(for: .milliseconds(10))
    }
    if let battleFetchError { throw battleFetchError }
    return battleRotationDict
  }

  func fetchSalmonRotations() -> [SalmonRotation] {
    salmonFetchCount += 1
    return salmonRotations
  }
}
