//
//  IkaPreference.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - IkaPreference

/// An observable data store shared across views, holding the app preferences.
/// Values persist to `UserDefaults` under the same keys previously used by `@AppStorage`.
@MainActor
@Observable
final class IkaPreference {
  typealias Scoped = Constants.Key.AppStorage

  @ObservationIgnored private let userDefaults: UserDefaults
  @ObservationIgnored private var isSyncing = false

  /// Preferred Default FlatMode
  var preferredDefaultFlatMode: FlatMode {
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
    }

    didSet {
      // Persistence must NOT be gated on `isSyncing`: synced assignments still need to hit disk.
      guard oldValue != preferredDefaultFlatMode else { return }

      userDefaults.set(preferredDefaultFlatMode.rawValue, forKey: Scoped.preferredDefaultFlatMode)
    }
  }

  /// Preferred Default GameMode
  var preferredDefaultGameMode: GameMode {
    willSet {
      guard newValue != preferredDefaultGameMode, !isSyncing else { return }

      isSyncing = true
      defer { isSyncing = false }

      switch newValue {
        case .battle:
          preferredDefaultFlatMode = .init(rawValue: preferredDefaultBattleMode.rawValue) ?? .default

        case .salmon:
          preferredDefaultFlatMode = .salmon
      }
    }

    didSet {
      guard oldValue != preferredDefaultGameMode else { return }

      userDefaults.set(preferredDefaultGameMode.rawValue, forKey: Scoped.preferredDefaultGameMode)
    }
  }

  /// Preferred Default BattleMode
  var preferredDefaultBattleMode: BattleMode {
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
    }

    didSet {
      guard oldValue != preferredDefaultBattleMode else { return }

      userDefaults.set(preferredDefaultBattleMode.rawValue, forKey: Scoped.preferredDefaultBattleMode)
    }
  }

  /// Preferred color scheme
  var preferredAppColorScheme: IkaColorSchemeManager.PreferredColorScheme {
    willSet {
      guard newValue != preferredAppColorScheme else { return }

      SimpleHaptics.generateTask(.selection)
    }

    didSet {
      guard oldValue != preferredAppColorScheme else { return }

      userDefaults.set(preferredAppColorScheme.rawValue, forKey: Scoped.preferredAppColorScheme)
    }
  }

  /// Preferred app icon
  var preferredAppIcon: IkaAppIcon {
    willSet {
      guard newValue != preferredAppIcon else { return }

      SimpleHaptics.generateTask(.success)
    }

    didSet {
      guard oldValue != preferredAppIcon else { return }

      userDefaults.set(preferredAppIcon.rawValue, forKey: Scoped.preferredAppIcon)
      UIApplication.shared.setAlternateIconName(preferredAppIcon.alternateIconName)
    }
  }

  /// Whether Tab Bar should minimized
  var shouldMinimizeTabBar: Bool {
    didSet {
      guard oldValue != shouldMinimizeTabBar else { return }

      userDefaults.set(shouldMinimizeTabBar, forKey: Scoped.shouldMinimizeTabBar)
    }
  }

  /// Bottom toolbar picker positioning
  var shouldSwapBottomToolbarPickers: Bool {
    didSet {
      guard oldValue != shouldSwapBottomToolbarPickers else { return }

      userDefaults.set(shouldSwapBottomToolbarPickers, forKey: Scoped.shouldSwapBottomToolbarPickers)
    }
  }

  /// If should be using alt stage images
  var shouldUseAltStageImages: Bool {
    didSet {
      guard oldValue != shouldUseAltStageImages else { return }

      userDefaults.set(shouldUseAltStageImages, forKey: Scoped.shouldUseAltStageImages)
    }
  }

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
    preferredDefaultFlatMode = userDefaults.ikaLoadEnum(
      forKey: Scoped.preferredDefaultFlatMode, default: .default)
    preferredDefaultGameMode = userDefaults.ikaLoadEnum(
      forKey: Scoped.preferredDefaultGameMode, default: .default)
    preferredDefaultBattleMode = userDefaults.ikaLoadEnum(
      forKey: Scoped.preferredDefaultBattleMode, default: .default)
    preferredAppColorScheme = userDefaults.ikaLoadEnum(
      forKey: Scoped.preferredAppColorScheme, default: .default)
    preferredAppIcon = userDefaults.ikaLoadEnum(
      forKey: Scoped.preferredAppIcon, default: .default)
    shouldMinimizeTabBar = userDefaults.ikaLoadBool(
      forKey: Scoped.shouldMinimizeTabBar, default: false)
    shouldSwapBottomToolbarPickers = userDefaults.ikaLoadBool(
      forKey: Scoped.shouldSwapBottomToolbarPickers, default: false)
    shouldUseAltStageImages = userDefaults.ikaLoadBool(
      forKey: Scoped.shouldUseAltStageImages, default: false)
  }

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

// MARK: - UserDefaults + Typed Loading

extension UserDefaults {
  /// Reads a String-raw-representable value, preserving the on-disk encoding `@AppStorage` used.
  func ikaLoadEnum<T: RawRepresentable>(forKey key: String, default defaultValue: T) -> T
    where T.RawValue == String
  {
    string(forKey: key).flatMap(T.init(rawValue:)) ?? defaultValue
  }

  /// Reads a Bool with an explicit fallback.
  /// - Important: `bool(forKey:)` returns `false` for missing keys, which would silently break
  ///   preferences whose default is `true` (e.g. onboarding). Always check key presence first.
  func ikaLoadBool(forKey key: String, default defaultValue: Bool) -> Bool {
    object(forKey: key) as? Bool ?? defaultValue
  }
}
