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

  /// Default GameMode (initial value already set during App init, so init value here does not matter)
  @AppStorage(Constants.Key.AppStorage.IF_HAS_RATED)
  var ifHasRated: Bool = false
  {
    willSet {
      if newValue { SimpleHaptics.generateTask(.selection) }
      objectWillChange.send()
    }
  }
}
