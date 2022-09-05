//
//  IkaPreference.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the app preferences.
final class IkaPreference: ObservableObject {
  // Default Modes: Init value already set by UserDefaults, so init value here does not matter.
  @AppStorage(Constants.Keys.AppStorage.DEFAULT_GAME_MODE)
  var defaultGameMode: GameMode = .battle { willSet { objectWillChange.send() }}

  @AppStorage(Constants.Keys.AppStorage.DEFAULT_BATTLE_MODE)
  var defaultBattleMode: BattleMode = .regular { willSet { objectWillChange.send() }}

  // Color Scheme
  @AppStorage(Constants.Keys.AppStorage.COLOR_SCHEME)
  var appColorScheme: ColorSchemeManager.AppColorScheme =
    .system { willSet { objectWillChange.send() }}

}
