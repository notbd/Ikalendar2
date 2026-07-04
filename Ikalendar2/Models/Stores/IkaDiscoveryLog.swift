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

      userDefaults.set(shouldShowOnboarding, forKey: Scoped.shouldShowOnboarding)
    }
  }

  /// Record if user has tapped and discovered the rating button.
  var hasDiscoveredRating: Bool {
    didSet {
      guard oldValue != hasDiscoveredRating else { return }

      userDefaults.set(hasDiscoveredRating, forKey: Scoped.hasDiscoveredRating)
    }
  }

  /// Record if user has tapped and discovered the alt app icon settings.
  var hasDiscoveredAltAppIcon: Bool {
    didSet {
      guard oldValue != hasDiscoveredAltAppIcon else { return }

      userDefaults.set(hasDiscoveredAltAppIcon, forKey: Scoped.hasDiscoveredAltAppIcon)
    }
  }

  /// Record if user has tapped and discovered the easter egg.
  var hasDiscoveredEasterEgg: Bool {
    didSet {
      guard oldValue != hasDiscoveredEasterEgg else { return }

      userDefaults.set(hasDiscoveredEasterEgg, forKey: Scoped.hasDiscoveredEasterEgg)
    }
  }

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
    shouldShowOnboarding = userDefaults.ikaLoadBool(
      forKey: Scoped.shouldShowOnboarding, default: true)
    hasDiscoveredRating = userDefaults.ikaLoadBool(
      forKey: Scoped.hasDiscoveredRating, default: false)
    hasDiscoveredAltAppIcon = userDefaults.ikaLoadBool(
      forKey: Scoped.hasDiscoveredAltAppIcon, default: false)
    hasDiscoveredEasterEgg = userDefaults.ikaLoadBool(
      forKey: Scoped.hasDiscoveredEasterEgg, default: false)
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
