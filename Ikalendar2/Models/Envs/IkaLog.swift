//
//  IkaLog.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the user action log and app state.
@MainActor
final class IkaLog: ObservableObject {
  static let shared: IkaLog = .init()

  /// Record if app should display onboarding screen to the user.
  @AppStorage(Constants.Key.AppStorage.SHOULD_SHOW_ONBOARDING)
  var shouldShowOnboarding: Bool = true
  {
    willSet {
      guard newValue != shouldShowOnboarding else { return }

      objectWillChange.send()
    }
  }

  /// Record if user has tapped and discovered the rating button.
  @AppStorage(Constants.Key.AppStorage.HAS_DISCOVERED_RATING)
  var hasDiscoveredRating: Bool = false
  {
    willSet {
      guard newValue != hasDiscoveredRating else { return }

      objectWillChange.send()
    }
  }

  /// Record if user has tapped and discovered the alt app icon settings.
  @AppStorage(Constants.Key.AppStorage.HAS_DISCOVERED_ALT_APP_ICON)
  var hasDiscoveredAltAppIcon: Bool = false
  {
    willSet {
      guard newValue != hasDiscoveredAltAppIcon else { return }

      objectWillChange.send()
    }
  }

  /// Record if user has tapped and discovered the alt app icon settings.
  @AppStorage(Constants.Key.AppStorage.HAS_DISCOVERED_EASTER_EGG)
  var hasDiscoveredEasterEgg: Bool = false
  {
    willSet {
      guard newValue != hasDiscoveredEasterEgg else { return }

      objectWillChange.send()
    }
  }

  private init() { }

  func resetStates(shouldResetOnboarding: Bool = false) {
    hasDiscoveredRating = false
    hasDiscoveredAltAppIcon = false
    hasDiscoveredEasterEgg = false
    if shouldResetOnboarding {
      shouldShowOnboarding = true
    }
  }
}
