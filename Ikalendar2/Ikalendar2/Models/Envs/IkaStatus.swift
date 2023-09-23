//
//  IkaStatus.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SimpleHaptics

/// An EnvObj class that is shared among all the views.
/// Contains the app status.
@MainActor
@Observable
final class IkaStatus {

  static let shared = IkaStatus()

  var isSettingsPresented = false
  {
    willSet {
      guard newValue != isSettingsPresented else { return }
      SimpleHaptics.generateTask(.rigid)
    }
  }

  var currentGameMode =
    GameMode(
      rawValue: UserDefaults.standard.string(
        forKey: Constants.Key.AppStorage.DEFAULT_GAME_MODE)!)!
  {
    willSet {
      guard newValue != currentGameMode else { return }
      SimpleHaptics.generateTask(.warning)
    }
  }

  var currentBattleMode =
    BattleMode(
      rawValue: UserDefaults.standard.string(
        forKey: Constants.Key.AppStorage.DEFAULT_BATTLE_MODE)!)!
  {
    willSet {
      guard newValue != currentBattleMode else { return }
      SimpleHaptics.generateTask(.soft)
    }
  }

  // MARK: Lifecycle

  init() { }

}
