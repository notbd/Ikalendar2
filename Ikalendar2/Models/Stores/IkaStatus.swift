//
//  IkaStatus.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SimpleHaptics

/// An observable data store shared across views, holding the in-session app status
/// (current mode selection and settings presentation).
@MainActor
@Observable
final class IkaStatus {
  @ObservationIgnored private let ikaPreference: IkaPreference
  @ObservationIgnored private var isSyncing = false

  var isSettingsPresented: Bool = false
  {
    willSet {
      guard newValue != isSettingsPresented else { return }

      SimpleHaptics.generateTask(.rigid)
    }
  }

  /// Three views of one selection (FlatMode = GameMode x BattleMode). Setting the flat mode
  /// mirrors it into game and battle mode; setting game or battle mode rebuilds the flat mode.
  /// `isSyncing` stops the cascade after one hop, so setting battle
  /// mode alone leaves game mode untouched (the same topology IkaPreferenceTests pins for
  /// IkaPreference).
  var currentFlatMode: FlatMode
  {
    willSet {
      guard newValue != currentFlatMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      currentGameMode = newValue.gameMode
      if let battleMode = newValue.battleMode {
        currentBattleMode = battleMode
      }

      SimpleHaptics.generateTask(.soft)
    }
  }

  var currentGameMode: GameMode
  {
    willSet {
      guard newValue != currentGameMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      currentFlatMode = FlatMode(gameMode: newValue, battleMode: currentBattleMode)
    }
  }

  var currentBattleMode: BattleMode
  {
    willSet {
      guard newValue != currentBattleMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      currentFlatMode = FlatMode(newValue)
    }
  }

  init(ikaPreference: IkaPreference) {
    self.ikaPreference = ikaPreference
    // Direct init assignments skip willSet/didSet: no sync cascade, no launch haptics -
    // same as the previous stored-property-default behavior.
    currentFlatMode = ikaPreference.preferredDefaultFlatMode
    currentGameMode = ikaPreference.preferredDefaultGameMode
    currentBattleMode = ikaPreference.preferredDefaultBattleMode
  }

  func reset(dismissingSettings: Bool = false) {
    currentFlatMode = ikaPreference.preferredDefaultFlatMode
    currentGameMode = ikaPreference.preferredDefaultGameMode
    currentBattleMode = ikaPreference.preferredDefaultBattleMode
    if dismissingSettings {
      isSettingsPresented = false
    }
  }
}
