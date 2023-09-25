//
//  IkaPreference.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SimpleHaptics
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the app preferences.
@MainActor
final class IkaPreference: ObservableObject {

  static let shared = IkaPreference()

  /// Default GameMode (initial value already set during App init, so init value here does not matter)
  @AppStorage(Constants.Key.AppStorage.DEFAULT_GAME_MODE)
  var defaultGameMode: GameMode = .battle
  {
    willSet {
      if newValue != defaultGameMode { SimpleHaptics.generateTask(.selection) }
      objectWillChange.send()
    }
  }

  /// Default BattleMode (initial value already set during App init, so init value here does not matter)
  @AppStorage(Constants.Key.AppStorage.DEFAULT_BATTLE_MODE)
  var defaultBattleMode: BattleMode = .league
  {
    willSet {
      if newValue != defaultBattleMode { SimpleHaptics.generateTask(.selection) }
      objectWillChange.send()
    }
  }

  /// User preferred color scheme
  @AppStorage(Constants.Key.AppStorage.PREFERRED_APP_COLOR_SCHEME)
  var preferredAppColorScheme: IkaColorSchemeManager.PreferredColorScheme = .dark
  {
    willSet {
      if newValue != preferredAppColorScheme { SimpleHaptics.generateTask(.selection) }
      objectWillChange.send()
    }
  }

  /// User preferred app icon
  @AppStorage(Constants.Key.AppStorage.PREFERRED_APP_ICON)
  var preferredAppIcon: IkaAppIcon = .modernDark {
    didSet { UIApplication.shared.setAlternateIconName(preferredAppIcon.alternateIconName) }
    willSet {
      if newValue != preferredAppIcon { SimpleHaptics.generateTask(.success) }
      objectWillChange.send()
    }
  }

  /// If should be using alt stage images
  @AppStorage(Constants.Key.AppStorage.SHOULD_USE_ALT_STAGE_IMAGES)
  var shouldUseAltStageImages = false
  {
    willSet {
      if newValue != shouldUseAltStageImages { SimpleHaptics.generateTask(.selection) }
      objectWillChange.send()
    }
  }

  /// Bottom toolbar picker positioning
  @AppStorage(Constants.Key.AppStorage.SHOULD_SWAP_BOTTOM_TOOLBAR_PICKERS)
  var shouldSwapBottomToolbarPickers = false
  {
    willSet {
      if newValue != shouldSwapBottomToolbarPickers { SimpleHaptics.generateTask(.selection) }
      objectWillChange.send()
    }
  }

  // MARK: Lifecycle

  init() { }

}
