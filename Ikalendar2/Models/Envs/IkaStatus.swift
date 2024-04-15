//
//  IkaStatus.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SimpleHaptics

/// An EnvObj class that is shared among all the views.
/// Contains the app status.
@MainActor
@Observable
final class IkaStatus {
  static let shared: IkaStatus = .init()

  var isSettingsPresented: Bool = false
  {
    willSet {
      guard newValue != isSettingsPresented else { return }
      SimpleHaptics.generateTask(.rigid)
    }
  }

  var currentGameMode: GameMode = IkaPreference.shared.preferredDefaultGameMode
  {
    willSet {
      guard newValue != currentGameMode else { return }
      SimpleHaptics.generateTask(.rigid)
    }
  }

  var currentBattleMode: BattleMode = IkaPreference.shared.preferredDefaultBattleMode
  {
    willSet {
      guard newValue != currentBattleMode else { return }
      SimpleHaptics.generateTask(.soft)
    }
  }

  // MARK: Lifecycle

  private init() { }
}
