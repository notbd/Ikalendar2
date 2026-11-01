//
//  AltStageImageTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - AltStageImageTests

/// How the battle alt stage image is picked. The test bundle is hosted by the app, so
/// `AssetImageCounter` counts the real asset catalog. Whether every pick resolves to an
/// existing asset is covered by AssetAlignmentTests.
@Suite("Alt stage images")
struct AltStageImageTests {
  static private let anchor: Date = .init(timeIntervalSince1970: 1_700_000_000)

  private func battleRotation(rule: BattleRule, stageA: BattleStage, stageB: BattleStage) -> BattleRotation {
    .init(
      startTime: Self.anchor,
      endTime: Self.anchor.addingTimeInterval(2 * 60 * 60),
      mode: rule == .turfWar ? .regular : .gachi,
      rule: rule,
      stageA: stageA,
      stageB: stageB)
  }

  @Test(arguments: BattleRule.allCases)
  func `Stage without alt images falls back to its standard image`(rule: BattleRule) {
    // Shifty Station ships no alt images; it used to resolve to a missing asset (blank card).
    let rotation: BattleRotation = battleRotation(rule: rule, stageA: .shiftyStation, stageB: .shiftyStation)
    #expect(rotation.stageAAltImageName == BattleStage.shiftyStation.imageName)
    #expect(rotation.stageBAltImageName == BattleStage.shiftyStation.imageName)
  }

  @Test
  func `Alt image pick stays the same for a fixed rotation`() {
    // The pick is seeded by `description`, so a rotation keeps its image across launches and
    // releases. The literals follow from that seed and The Reef's alt image counts; adding or
    // removing The Reef alt images legitimately changes them.
    let rainmaker: BattleRotation = battleRotation(rule: .rainmaker, stageA: .theReef, stageB: .theReef)
    let clamBlitz: BattleRotation = battleRotation(rule: .clamBlitz, stageA: .theReef, stageB: .theReef)
    #expect(rainmaker.stageAAltImageName == "The_Reef_Alt_0")
    #expect(clamBlitz.stageAAltImageName == "The_Reef_Alt_2") // nonzero: an always-0 pick fails
  }
}
