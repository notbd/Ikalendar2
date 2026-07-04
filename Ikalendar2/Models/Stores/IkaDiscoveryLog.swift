//
//  IkaDiscoveryLog.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// An observable data store shared across views, recording which app features
/// the user has already discovered (onboarding, rating, alt icons, easter egg).
/// Values persist to `UserDefaults` under the same keys previously used by `@AppStorage`.
@MainActor
@Observable
final class IkaDiscoveryLog {
  typealias Scoped = Constants.Key.AppStorage

  @ObservationIgnored private let userDefaults: UserDefaults

  /// Record if app should display onboarding screen to the user.
  var shouldShowOnboarding: Bool {
    didSet {
      guard oldValue != shouldShowOnboarding else { return }

      userDefaults.set(shouldShowOnboarding, forKey: Scoped.SHOULD_SHOW_ONBOARDING)
    }
  }

  /// Record if user has tapped and discovered the rating button.
  var hasDiscoveredRating: Bool {
    didSet {
      guard oldValue != hasDiscoveredRating else { return }

      userDefaults.set(hasDiscoveredRating, forKey: Scoped.HAS_DISCOVERED_RATING)
    }
  }

  /// Record if user has tapped and discovered the alt app icon settings.
  var hasDiscoveredAltAppIcon: Bool {
    didSet {
      guard oldValue != hasDiscoveredAltAppIcon else { return }

      userDefaults.set(hasDiscoveredAltAppIcon, forKey: Scoped.HAS_DISCOVERED_ALT_APP_ICON)
    }
  }

  /// Record if user has tapped and discovered the easter egg.
  var hasDiscoveredEasterEgg: Bool {
    didSet {
      guard oldValue != hasDiscoveredEasterEgg else { return }

      userDefaults.set(hasDiscoveredEasterEgg, forKey: Scoped.HAS_DISCOVERED_EASTER_EGG)
    }
  }

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
    shouldShowOnboarding = userDefaults.ikaLoadBool(
      forKey: Scoped.SHOULD_SHOW_ONBOARDING, default: true)
    hasDiscoveredRating = userDefaults.ikaLoadBool(
      forKey: Scoped.HAS_DISCOVERED_RATING, default: false)
    hasDiscoveredAltAppIcon = userDefaults.ikaLoadBool(
      forKey: Scoped.HAS_DISCOVERED_ALT_APP_ICON, default: false)
    hasDiscoveredEasterEgg = userDefaults.ikaLoadBool(
      forKey: Scoped.HAS_DISCOVERED_EASTER_EGG, default: false)
  }

  func resetStates(shouldResetOnboarding: Bool = false) {
    hasDiscoveredRating = false
    hasDiscoveredAltAppIcon = false
    hasDiscoveredEasterEgg = false
    if shouldResetOnboarding {
      shouldShowOnboarding = true
    }
  }
}
