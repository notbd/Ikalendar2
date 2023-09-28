//
//  ConfigConstants.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SwiftUI

/// Constant data holding `config`s for the app.
extension Constants.Config {
  enum Timer {
    static let autoLoadCheckSignalInterval: TimeInterval = 5
    static let bounceSignalInterval: TimeInterval = 7
  }

  enum Catalog {
    /// Time Intervals are measured in second(s).
    static let loadStatusLoadedDelay: TimeInterval = 0.2
    static let loadStatusErrorDelay: TimeInterval = 1

    static let autoLoadAttemptInterval: TimeInterval = 2

    static let autoLoadBattleMaxAttempts: Int = 8
    static let autoLoadSalmonMaxAttempts: Int = 8

    static let appActiveStateCheckInterval: TimeInterval = 1
    static let autoLoadedLingerLength: TimeInterval = 2
    static let idleAndNonIdleStatusUpdateInterval: TimeInterval = 1
  }

  enum Settings {
    static let aboutRatingsBounceInterval: TimeInterval = 7
  }

  enum License {
    static let licenseLoadedDelay: TimeInterval = 0.2
  }
}
