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

  var currentFlatMode: FlatMode
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

  var currentGameMode: GameMode
  {
    willSet {
      guard newValue != currentGameMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .battle:
          currentFlatMode = .init(rawValue: currentBattleMode.rawValue) ?? .default
        case .salmon:
          currentFlatMode = .salmon
      }
    }
  }

  var currentBattleMode: BattleMode
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

  func resetStatuses(shouldExitSettings: Bool = false) {
    currentFlatMode = ikaPreference.preferredDefaultFlatMode
    currentGameMode = ikaPreference.preferredDefaultGameMode
    currentBattleMode = ikaPreference.preferredDefaultBattleMode
    if shouldExitSettings {
      isSettingsPresented = false
    }
  }
}
