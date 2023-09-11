//
//  IkaStatus.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the app status.
@MainActor
final class IkaStatus: ObservableObject {

  static let shared = IkaStatus()

  @Published var isSettingsPresented = false

  @Published var gameModeSelection = GameMode(
    rawValue: UserDefaults.standard.string(
      forKey: Constants.Key.AppStorage.DEFAULT_GAME_MODE)!)!

  @Published var battleModeSelection = BattleMode(
    rawValue: UserDefaults.standard.string(
      forKey: Constants.Key.AppStorage.DEFAULT_BATTLE_MODE)!)!

  // MARK: Lifecycle

  init() { }

}