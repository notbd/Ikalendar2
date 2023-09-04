//
//  IkaPreference.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the app preferences.
@MainActor
final class IkaPreference: ObservableObject {

  static let shared = IkaPreference()

  /// Default GameMode (initial value already set during App init, so init value here does not matter)
  @AppStorage(Constants.Keys.AppStorage.DEFAULT_GAME_MODE)
  var defaultGameMode: GameMode = .battle { willSet { objectWillChange.send() }}

  /// Default BattleMode (initial value already set during App init, so init value here does not matter)
  @AppStorage(Constants.Keys.AppStorage.DEFAULT_BATTLE_MODE)
  var defaultBattleMode: BattleMode = .regular { willSet { objectWillChange.send() }}

  /// User preferred color scheme
  @AppStorage(Constants.Keys.AppStorage.PREFERRED_APP_COLOR_SCHEME)
  var preferredAppColorScheme: IkaColorSchemeManager.PreferredAppColorScheme = .dark {
    willSet { objectWillChange.send() }
  }

  /// User preferred app icon
  @AppStorage(Constants.Keys.AppStorage.PREFERRED_APP_ICON)
  var preferredAppIcon: IkaAppIcon = .modernDark {
    didSet { UIApplication.shared.setAlternateIconName(preferredAppIcon.alternateIconName) }
    willSet { objectWillChange.send() }
  }

  /// If using alt stage images
  @AppStorage(Constants.Keys.AppStorage.IF_USE_ALT_STAGE_IMAGES)
  var ifUseAltStageImages = false { willSet { objectWillChange.send() }}

  /// Bottom toolbar picker positioning
  @AppStorage(Constants.Keys.AppStorage.IF_SWAP_BOTTOM_TOOLBAR_PICKERS)
  var ifSwapBottomToolbarPickers = false { willSet { objectWillChange.send() }}

  // MARK: Lifecycle

  init() { }

}
