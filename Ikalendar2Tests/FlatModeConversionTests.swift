//
//  FlatModeConversionTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - FlatModeConversionTests

/// Pins the FlatMode <-> GameMode / BattleMode mapping that IkaStatus, IkaPreference,
/// RotationsTabView and ModeIconStamp share.
@Suite("FlatMode conversions")
struct FlatModeConversionTests {
  @Test(arguments: FlatMode.allCases)
  func `Every flat mode round-trips through its game and battle modes`(flatMode: FlatMode) {
    let rebuilt: FlatMode = .init(gameMode: flatMode.gameMode, battleMode: flatMode.battleMode ?? .default)
    #expect(rebuilt == flatMode)
  }

  @Test(arguments: BattleMode.allCases)
  func `Every battle mode round-trips through its flat mode`(battleMode: BattleMode) {
    let flatMode: FlatMode = .init(battleMode)
    #expect(flatMode.battleMode == battleMode)
    #expect(flatMode.gameMode == .battle)
    #expect(flatMode.rawValue == battleMode.rawValue)
  }

  @Test
  func `Salmon has no battle mode`() {
    #expect(FlatMode.salmon.battleMode == nil)
    #expect(FlatMode.salmon.gameMode == .salmon)
  }

  @Test(arguments: GameMode.allCases, BattleMode.allCases)
  func `Game and battle mode pick the flat mode`(gameMode: GameMode, battleMode: BattleMode) {
    let flatMode: FlatMode = .init(gameMode: gameMode, battleMode: battleMode)

    switch gameMode {
      case .battle:
        #expect(flatMode == FlatMode(battleMode))
      case .salmon:
        #expect(flatMode == .salmon)
    }
    #expect(flatMode.gameMode == gameMode)
  }
}
