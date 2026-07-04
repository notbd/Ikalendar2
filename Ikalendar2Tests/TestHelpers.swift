//
//  TestHelpers.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - UserDefaults Isolation

/// Creates a fresh, isolated UserDefaults suite for one test.
/// Unique suite names keep parallel tests from sharing state; the simulator
/// container is ephemeral so no cleanup is needed. Never touch `.standard` in tests.
func makeTestDefaults() throws -> UserDefaults {
  try #require(UserDefaults(suiteName: "ikalendar2-tests-\(UUID().uuidString)"))
}

// MARK: - TestData

/// Deterministic model factories (IkaMockData is intentionally random - unusable in tests).
enum TestData {
  /// Anchor for offset-based rotations; using a fixed epoch keeps assertions reproducible.
  static let anchor: Date = .init(timeIntervalSince1970: 1_700_000_000)

  static func battleRotation(
    mode: BattleMode = .gachi,
    startOffset: TimeInterval,
    endOffset: TimeInterval,
    from reference: Date = anchor,
    rule: BattleRule = .splatZones,
    stageA: BattleStage = .theReef,
    stageB: BattleStage = .makoMart)
    -> BattleRotation
  {
    .init(
      startTime: reference.addingTimeInterval(startOffset),
      endTime: reference.addingTimeInterval(endOffset),
      mode: mode,
      rule: rule,
      stageA: stageA,
      stageB: stageB)
  }

  /// Two rotations per mode: one current ([-1h, +1h]) and one future ([+1h, +3h]) relative
  /// to `reference`. Future end times keep `isOutdated` false, so IkaCatalog's auto-load
  /// loop can never fire mid-test.
  static func battleDict(reference: Date = .init()) -> BattleRotationDict {
    var dict: BattleRotationDict = .init()
    for mode in BattleMode.allCases {
      dict[mode] = [
        battleRotation(mode: mode, startOffset: -3600, endOffset: 3600, from: reference),
        battleRotation(
          mode: mode,
          startOffset: 3600,
          endOffset: 3 * 3600,
          from: reference,
          rule: .rainmaker,
          stageA: .kelpDome,
          stageB: .portMackerel),
      ]
    }
    return dict
  }

  static func salmonRotation(
    startOffset: TimeInterval,
    endOffset: TimeInterval,
    from reference: Date = anchor,
    stage: SalmonStage? = .spawningGrounds,
    weapons: [SalmonWeapon]? = [.vanilla(.splooshOMatic)])
    -> SalmonRotation
  {
    .init(
      startTime: reference.addingTimeInterval(startOffset),
      endTime: reference.addingTimeInterval(endOffset),
      stage: stage,
      weapons: weapons)
  }
}

// MARK: - MockIkaNetworkService

/// Configurable mock: each endpoint is a @Sendable closure so tests can inject
/// results, failures, hangs, and call counting.
struct MockIkaNetworkService: IkaNetworkService {
  var battleRotationDictHandler: @Sendable () async throws -> BattleRotationDict
  var salmonRotationsHandler: @Sendable () async throws -> [SalmonRotation]
  var salmonRewardApparelInfoHandler: @Sendable () async throws -> SalmonApparelInfo
  var licenseHandler: @Sendable (String) async throws -> IkaOpenSourceLicense = { _ in
    IkaOpenSourceLicense(repoURL: "", type: "", typeDescription: "", content: "")
  }

  func getBattleRotationDict() async throws -> BattleRotationDict {
    try await battleRotationDictHandler()
  }

  func getSalmonRotations() async throws -> [SalmonRotation] {
    try await salmonRotationsHandler()
  }

  func getSalmonRewardApparelInfo() async throws -> SalmonApparelInfo {
    try await salmonRewardApparelInfoHandler()
  }

  func fetchLicense(from githubRepoURLString: String) async throws -> IkaOpenSourceLicense {
    try await licenseHandler(githubRepoURLString)
  }
}

/// A cancellable never-returning operation for timeout tests: sleeps cooperatively so
/// the enclosing task group can cancel it (no leaked work after the test).
func hangingForever<T>() async throws -> T {
  try await Task.sleep(for: .seconds(3600))
  throw CancellationError()
}
