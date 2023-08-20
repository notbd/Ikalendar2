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

  /// Default Modes: Init value already set by UserDefaults, so init value here does not matter.
  @AppStorage(Constants.Keys.AppStorage.DEFAULT_GAME_MODE)
  var defaultGameMode: GameMode = .battle { willSet { objectWillChange.send() }}

  @AppStorage(Constants.Keys.AppStorage.DEFAULT_BATTLE_MODE)
  var defaultBattleMode: BattleMode = .regular { willSet { objectWillChange.send() }}

  /// Color Scheme
  @AppStorage(Constants.Keys.AppStorage.COLOR_SCHEME)
  var appPreferredColorScheme: IkaColorSchemeManager.AppColorScheme =
    .system { willSet { objectWillChange.send() }}

  /// Bottom Toolbar Picker Positioning
  @AppStorage(Constants.Keys.AppStorage.IF_REVERSE_TOOLBAR_PICKERS)
  var ifReverseToolbarPickers = false { willSet { objectWillChange.send() }}

  // MARK: Lifecycle

  private init() { }

}
