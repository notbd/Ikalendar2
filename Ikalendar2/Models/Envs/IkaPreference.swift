//
//  IkaPreference.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Combine
import SimpleHaptics
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the app preferences.
@MainActor
final class IkaPreference: ObservableObject {
  static let shared: IkaPreference = .init()

  private var isSyncing = false

  /// Preferred Default FlatMode
  @AppStorage(Constants.Key.AppStorage.PREFERRED_DEFAULT_FLAT_MODE)
  var preferredDefaultFlatMode: FlatMode = .default {
    willSet {
      guard newValue != preferredDefaultFlatMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .regular:
          preferredDefaultGameMode = .battle
          preferredDefaultBattleMode = .regular

        case .gachi:
          preferredDefaultGameMode = .battle
          preferredDefaultBattleMode = .gachi

        case .league:
          preferredDefaultGameMode = .battle
          preferredDefaultBattleMode = .league

        case .salmon:
          preferredDefaultGameMode = .salmon
      }

      SimpleHaptics.generateTask(.selection)
      objectWillChange.send()
    }
  }

  /// Preferred Default GameMode
  @AppStorage(Constants.Key.AppStorage.PREFERRED_DEFAULT_GAME_MODE)
  var preferredDefaultGameMode: GameMode = .default {
    willSet {
      guard newValue != preferredDefaultGameMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .battle:
          preferredDefaultFlatMode = .init(
            rawValue: preferredDefaultBattleMode.rawValue)!

        case .salmon:
          preferredDefaultFlatMode = .salmon
      }

      objectWillChange.send()
    }
  }

  /// Preferred Default BattleMode
  @AppStorage(Constants.Key.AppStorage.PREFERRED_DEFAULT_BATTLE_MODE)
  var preferredDefaultBattleMode: BattleMode = .default {
    willSet {
      guard newValue != preferredDefaultBattleMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .regular:
          preferredDefaultFlatMode = .regular
        case .gachi:
          preferredDefaultFlatMode = .gachi
        case .league:
          preferredDefaultFlatMode = .league
      }

      objectWillChange.send()
    }
  }

  /// Preferred color scheme
  @AppStorage(Constants.Key.AppStorage.PREFERRED_APP_COLOR_SCHEME)
  var preferredAppColorScheme: IkaColorSchemeManager.PreferredColorScheme = .default
  {
    willSet {
      guard newValue != preferredAppColorScheme else { return }

      SimpleHaptics.generateTask(.selection)
      objectWillChange.send()
    }
  }

  /// Preferred app icon
  @AppStorage(Constants.Key.AppStorage.PREFERRED_APP_ICON)
  var preferredAppIcon: IkaAppIcon = .default {
    willSet {
      guard newValue != preferredAppIcon else { return }

      SimpleHaptics.generateTask(.success)
      objectWillChange.send()
    }

    didSet {
      guard oldValue != preferredAppIcon else { return }

      UIApplication.shared.setAlternateIconName(preferredAppIcon.alternateIconName)
    }
  }

  /// Whether Tab Bar should minimized
  @AppStorage(Constants.Key.AppStorage.SHOULD_MINIMIZE_TAB_BAR)
  var shouldMinimizeTabBar = false
  {
    willSet {
      guard newValue != shouldMinimizeTabBar else { return }

      SimpleHaptics.generateTask(.selection)
      objectWillChange.send()
    }
  }

  /// Bottom toolbar picker positioning
  @AppStorage(Constants.Key.AppStorage.SHOULD_SWAP_BOTTOM_TOOLBAR_PICKERS)
  var shouldSwapBottomToolbarPickers = false
  {
    willSet {
      guard newValue != shouldSwapBottomToolbarPickers else { return }

      SimpleHaptics.generateTask(.selection)
      objectWillChange.send()
    }
  }

  /// If should be using alt stage images
  @AppStorage(Constants.Key.AppStorage.SHOULD_USE_ALT_STAGE_IMAGES)
  var shouldUseAltStageImages = false
  {
    willSet {
      guard newValue != shouldUseAltStageImages else { return }

      SimpleHaptics.generateTask(.selection)
      objectWillChange.send()
    }
  }

  private init() { }

  func resetPreferences() {
    preferredDefaultFlatMode = .default
    preferredDefaultGameMode = .default
    preferredDefaultBattleMode = .default
    preferredAppColorScheme = .default
    preferredAppIcon = .default
    shouldMinimizeTabBar = false
    shouldSwapBottomToolbarPickers = false
    shouldUseAltStageImages = false
  }

  func revertEasterEggAppIcon() {
    if preferredAppIcon.isEasterEgg { preferredAppIcon = .default }
  }
}
