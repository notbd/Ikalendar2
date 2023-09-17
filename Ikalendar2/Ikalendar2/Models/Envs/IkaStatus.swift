//
//  IkaStatus.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SimpleHaptics
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the app status.
@MainActor
final class IkaStatus: ObservableObject {

  static let shared = IkaStatus()

  @Published var isSettingsPresented = false
  {
    willSet {
      guard newValue != isSettingsPresented else { return }
      SimpleHaptics.generateTask(.rigid)
    }
  }

  @Published var currentGameMode = GameMode(
    rawValue: UserDefaults.standard.string(
      forKey: Constants.Key.AppStorage.DEFAULT_GAME_MODE)!)!
  {
    willSet {
      guard newValue != currentGameMode else { return }
      SimpleHaptics.generateTask(.warning)
    }
  }

  @Published var currentBattleMode = BattleMode(
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
