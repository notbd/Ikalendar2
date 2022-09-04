//
//  IkaStatus.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the app status.
final class IkaStatus: ObservableObject {
  @Published var isSettingsPresented = false

  @Published var gameModeSelection = GameMode(
    rawValue: UserDefaults.standard.string(
      forKey: Constants.Keys.AppStorage.DEFAULT_GAME_MODE)!)!
  @Published var battleModeSelection = BattleMode(
    rawValue: UserDefaults.standard.string(
      forKey: Constants.Keys.AppStorage.DEFAULT_BATTLE_MODE)!)!
}
