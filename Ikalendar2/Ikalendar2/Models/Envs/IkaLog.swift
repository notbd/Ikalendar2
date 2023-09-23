//
//  IkaLog.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

/// An EnvObj class that is shared among all the views.
/// Contains the user action log.
@MainActor
final class IkaLog: ObservableObject {

  static let shared = IkaLog()

  /// Record if user has tapped and discovered the rating button.
  @AppStorage(Constants.Key.AppStorage.IF_HAS_DISCOVERED_RATING)
  var ifHasDiscoveredRating: Bool = false
  {
    willSet {
      objectWillChange.send()
    }
  }

  /// Record if user has tapped and discovered the alt app icon settings.
  @AppStorage(Constants.Key.AppStorage.IF_HAS_DISCOVERED_ALT_APP_ICON)
  var ifHasDiscoveredAltAppIcon: Bool = false
  {
    willSet {
      objectWillChange.send()
    }
  }
}
