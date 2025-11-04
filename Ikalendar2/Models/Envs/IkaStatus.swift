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

  private var isSyncing = false

  var isSettingsPresented: Bool = false
  {
    willSet {
      guard newValue != isSettingsPresented else { return }

      SimpleHaptics.generateTask(.rigid)
    }
  }

  var currentFlatMode: FlatMode = IkaPreference.shared.preferredDefaultFlatMode
  {
    willSet {
      guard newValue != currentFlatMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .regular:
          currentGameMode = .battle
          currentBattleMode = .regular

        case .gachi:
          currentGameMode = .battle
          currentBattleMode = .gachi

        case .league:
          currentGameMode = .battle
          currentBattleMode = .league

        case .salmon:
          currentGameMode = .salmon
      }

      SimpleHaptics.generateTask(.soft)
    }
  }

  var currentGameMode: GameMode = IkaPreference.shared.preferredDefaultGameMode
  {
    willSet {
      guard newValue != currentGameMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .battle:
          currentFlatMode = .init(rawValue: currentBattleMode.rawValue)!
        case .salmon:
          currentFlatMode = .salmon
      }
    }
  }

  var currentBattleMode: BattleMode = IkaPreference.shared.preferredDefaultBattleMode
  {
    willSet {
      guard newValue != currentBattleMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .regular:
          currentFlatMode = .regular
        case .gachi:
          currentFlatMode = .gachi
        case .league:
          currentFlatMode = .league
      }
//      SimpleHaptics.generateTask(.soft)
    }
  }

  private init() { }

  func resetStatuses(shouldExitSettings: Bool = false) {
    currentFlatMode = IkaPreference.shared.preferredDefaultFlatMode
    currentGameMode = IkaPreference.shared.preferredDefaultGameMode
    currentBattleMode = IkaPreference.shared.preferredDefaultBattleMode
    if shouldExitSettings {
      isSettingsPresented = false
    }
  }
}
