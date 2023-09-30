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

  static let shared: IkaPreference = .init()

  /// Preferred Default GameMode
  @AppStorage(Constants.Key.AppStorage.PREFERRED_DEFAULT_GAME_MODE)
  var preferredDefaultGameMode: GameMode = .default
  {
    willSet {
      guard newValue != preferredDefaultGameMode else { return }
      SimpleHaptics.generateTask(.selection)
      objectWillChange.send()
    }
  }

  /// Preferred Default BattleMode
  @AppStorage(Constants.Key.AppStorage.PREFERRED_DEFAULT_BATTLE_MODE)
  var preferredDefaultBattleMode: BattleMode = .default
  {
    willSet {
      guard newValue != preferredDefaultBattleMode else { return }
      SimpleHaptics.generateTask(.selection)
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

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  func resetPreferences() {
    preferredDefaultGameMode = .default
    preferredDefaultBattleMode = .default
    preferredAppColorScheme = .default
    preferredAppIcon = .default
    shouldSwapBottomToolbarPickers = false
    shouldUseAltStageImages = false
  }

  func revertEasterEggAppIcon() {
    if preferredAppIcon.isEasterEgg { preferredAppIcon = .default }
  }

}
