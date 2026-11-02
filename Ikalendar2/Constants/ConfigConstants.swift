//
//  ConfigConstants.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SwiftUI

/// Constant data holding `config`s for the app.
extension Constants.Config {
  enum Catalog {
    static let loadTimeout: TimeInterval = 5

    static let autoLoadCheckInterval: TimeInterval = 5

    static let loadStatusLoadedDelay: TimeInterval = 0.2
    static let loadStatusErrorDelay: TimeInterval = 1

    static let autoLoadAttemptInterval: TimeInterval = 2

    static let autoLoadBattleMaxAttempts: Int = 8
    static let autoLoadSalmonMaxAttempts: Int = 8

    static let appActiveStateCheckInterval: TimeInterval = 1
    static let autoLoadedLingerLength: TimeInterval = 2
    static let idleAndNonIdleStatusUpdateInterval: TimeInterval = 1
  }
}
