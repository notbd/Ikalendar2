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

  var currentGameMode = IkaPreference.shared.defaultGameMode
  {
    willSet {
      guard newValue != currentGameMode else { return }
      SimpleHaptics.generateTask(.warning)
    }
  }

  var currentBattleMode = IkaPreference.shared.defaultBattleMode
  {
    willSet {
      guard newValue != currentBattleMode else { return }
      SimpleHaptics.generateTask(.soft)
    }
  }

  // MARK: Lifecycle

  init() { }

}
