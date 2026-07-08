//
//  ModeConsistencyTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - ModeConsistencyTests

/// Static invariants across the mode/stage/weapon enums. Several of these guard
/// raw-value alignments that production code relies on via `?? .default` fallbacks -
/// if one of these tests fails, a silent fallback would be masking a real modeling bug.
@Suite("Mode consistency")
struct ModeConsistencyTests {
  // MARK: - FlatMode <-> BattleMode/GameMode alignment

  @Test(arguments: BattleMode.allCases)
  func `Every battle mode raw value maps to a flat mode`(mode: BattleMode) {
    // Guards IkaPreference/IkaStatus: FlatMode(rawValue: battleMode.rawValue) ?? .default
    // - the fallback must never actually engage.
    #expect(FlatMode(rawValue: mode.rawValue) != nil)
  }

  @Test
  func `Flat mode cases are exactly battle modes plus salmon`() {
    #expect(FlatMode.allCases.count == BattleMode.allCases.count + 1)
    #expect(FlatMode.salmon.rawValue == GameMode.salmon.rawValue)
    for flatMode in FlatMode.allCases where flatMode != .salmon {
      #expect(BattleMode(rawValue: flatMode.rawValue) != nil)
    }
  }

  @Test
  func `Default modes are mutually consistent`() {
    #expect(FlatMode.default == .regular)
    #expect(GameMode.default == .battle)
    #expect(BattleMode.default == .regular)
    #expect(FlatMode.default.rawValue == BattleMode.default.rawValue)
  }

  // MARK: - Identifiable uniqueness

  @Test
  func `All case-iterable ids are unique`() {
    expectUniqueIDs(BattleMode.allCases)
    expectUniqueIDs(GameMode.allCases)
    expectUniqueIDs(FlatMode.allCases)
    expectUniqueIDs(BattleRule.allCases)
    expectUniqueIDs(BattleStage.allCases)
    expectUniqueIDs(SalmonStage.allCases)
    expectUniqueIDs(IkaWeapon.allCases)
    expectUniqueIDs(MysteryWeapon.allCases)
    expectUniqueIDs(GrizzcoWeapon.allCases)
    expectUniqueIDs(HeadApparel.allCases)
    expectUniqueIDs(BodyApparel.allCases)
    expectUniqueIDs(FootApparel.allCases)
    expectUniqueIDs(IkaAppIcon.allCases)
  }

  private func expectUniqueIDs<T: Identifiable>(_ cases: [T]) {
    let ids = cases.map(\.id)
    #expect(Set(ids).count == ids.count, "duplicate ids in \(T.self)")
  }

  // MARK: - Image name derivations (pure string logic, no UIImage)

  @Test(arguments: BattleStage.allCases)
  func `Battle stage image names have no spaces`(stage: BattleStage) {
    #expect(!stage.imageName.isEmpty)
    #expect(!stage.imageName.contains(" "))
  }

  @Test(arguments: SalmonStage.allCases)
  func `Salmon stage large image name extends the base name`(stage: SalmonStage) {
    #expect(!stage.imageName.isEmpty)
    #expect(stage.imageNameLarge == stage.imageName + "_Large")
  }

  @Test(arguments: BattleRule.allCases)
  func `Battle rule image names are non-empty`(rule: BattleRule) {
    #expect(!rule.imageNameMid.isEmpty)
    #expect(!rule.imageNameLarge.isEmpty)
  }

  @Test(arguments: IkaWeapon.allCases)
  func `Weapon image names are non-empty`(weapon: IkaWeapon) {
    #expect(!weapon.imageName.isEmpty)
    #expect(!weapon.imageNameSmall.isEmpty)
  }

  // MARK: - Fail-able initializer round-trips

  @Test(arguments: SalmonStage.allCases)
  func `Salmon stage name round-trips through the fail-able initializer`(stage: SalmonStage) {
    #expect(SalmonStage(name: stage.name) == stage)
  }

  @Test
  func `Unknown salmon stage name returns nil`() {
    #expect(SalmonStage(name: "Atlantis") == nil)
  }

  @Test(arguments: IkaWeapon.allCases)
  func `Every vanilla weapon id constructs a salmon weapon`(weapon: IkaWeapon) {
    #expect(SalmonWeapon(weapon.rawValue) == .vanilla(weapon))
  }

  @Test
  func `Mystery and invalid weapon ids resolve correctly`() {
    #expect(SalmonWeapon(-1) == .mystery(.green))
    #expect(SalmonWeapon(-2) == .mystery(.gold))
    #expect(SalmonWeapon(99999) == nil)
    #expect(SalmonWeapon(20000) == nil) // grizzco ids are not salmon weapons
  }
}
