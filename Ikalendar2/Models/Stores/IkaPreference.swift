//
//  IkaPreference.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import OSLog
import SimpleHaptics
import UIKit

// MARK: - IkaPreference

/// An observable data store shared across views, holding the app preferences.
/// Values persist to `UserDefaults` under the same keys previously used by `@AppStorage`.
@MainActor
@Observable
final class IkaPreference {
  typealias Scoped = Constants.Key.AppStorage

  @ObservationIgnored private let userDefaults: UserDefaults
  @ObservationIgnored private var isSyncing = false

  /// Three views of one selection (FlatMode = GameMode x BattleMode). Each willSet mirrors the
  /// change into the other two; `isSyncing` stops the cascade after one hop, so setting battle
  /// mode alone leaves game mode untouched (pinned by IkaPreferenceTests). Persistence happens in
  /// didSet and is deliberately not gated on `isSyncing`.
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
      // Persistence must NOT be gated on `isSyncing`: synced assignments still need to hit disk
      // (501a63e; pinned by IkaPreferenceTests "Synced side-effect assignments are persisted too").
      guard oldValue != preferredDefaultFlatMode else { return }

      userDefaults.set(preferredDefaultFlatMode.rawValue, forKey: Scoped.preferredDefaultFlatMode)
    }
  }

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

  var preferredAppColorScheme: IkaPreferredColorScheme {
    willSet {
      guard newValue != preferredAppColorScheme else { return }

      SimpleHaptics.generateTask(.selection)
    }

    didSet {
      guard oldValue != preferredAppColorScheme else { return }

      userDefaults.set(preferredAppColorScheme.rawValue, forKey: Scoped.preferredAppColorScheme)
    }
  }

  var preferredAppIcon: IkaAppIcon {
    willSet {
      guard newValue != preferredAppIcon else { return }

      SimpleHaptics.generateTask(.success)
    }

    didSet {
      guard oldValue != preferredAppIcon else { return }

      userDefaults.set(preferredAppIcon.rawValue, forKey: Scoped.preferredAppIcon)
      UIApplication.shared.setAlternateIconName(preferredAppIcon.alternateIconName) { error in
        if let error {
          Logger.store.error("alternate app icon switch failed: \(error, privacy: .public)")
        }
      }
    }
  }

  var shouldMinimizeTabBar: Bool {
    didSet {
      guard oldValue != shouldMinimizeTabBar else { return }

      userDefaults.set(shouldMinimizeTabBar, forKey: Scoped.shouldMinimizeTabBar)
    }
  }

  /// Unused by any UI since the Tab View layout (76c1355; the last readers went in 964a5c2 and
  /// dff7a9d). Kept so the on-disk key keeps round-tripping for upgrading users; remove only
  /// with a migration.
  var shouldSwapBottomToolbarPickers: Bool {
    didSet {
      guard oldValue != shouldSwapBottomToolbarPickers else { return }

      userDefaults.set(shouldSwapBottomToolbarPickers, forKey: Scoped.shouldSwapBottomToolbarPickers)
    }
  }

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

  func reset() {
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
