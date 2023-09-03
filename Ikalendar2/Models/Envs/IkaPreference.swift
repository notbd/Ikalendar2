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

  /// Default Game Mode (initial value already set during App init, so init value here does not matter)
  @AppStorage(Constants.Keys.AppStorage.DEFAULT_GAME_MODE)
  var defaultGameMode: GameMode = .battle { willSet { objectWillChange.send() }}

  /// Default Battle Mode (initial value already set during App init, so init value here does not matter)
  @AppStorage(Constants.Keys.AppStorage.DEFAULT_BATTLE_MODE)
  var defaultBattleMode: BattleMode = .regular { willSet { objectWillChange.send() }}

  /// Color Scheme
  @AppStorage(Constants.Keys.AppStorage.APP_PREFERRED_COLOR_SCHEME)
  var appPreferredColorScheme: IkaColorSchemeManager.AppPreferredColorScheme = .dark {
    willSet { objectWillChange.send() }
  }

  /// if Using Alt Stage Images
  @AppStorage(Constants.Keys.AppStorage.IF_USE_ALT_STAGE_IMAGES)
  var ifUseAltStageImages = false { willSet { objectWillChange.send() }}

  /// Bottom Toolbar Picker Positioning
  @AppStorage(Constants.Keys.AppStorage.IF_SWAP_BOTTOM_TOOLBAR_PICKERS)
  var ifSwapBottomToolbarPickers = false { willSet { objectWillChange.send() }}

  // MARK: Lifecycle

  init() { }

}
