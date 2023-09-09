//
//  ConfigConstants.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Constant data holding `config`s for the app.
extension Constants.Configs {
  enum Catalog {
    /// Time Intervals are measured in second(s).
    static let loadStatusLoadedDelay: TimeInterval = 0.2
    static let loadStatusErrorDelay: TimeInterval = 1

    static let autoLoadCheckInterval: TimeInterval = 4
    static let autoLoadAttemptInterval: TimeInterval = 2

    static let autoLoadBattleMaxAttempts: Int = 8
    static let autoLoadSalmonMaxAttempts: Int = 8

    static let activeStateCheckInterval: TimeInterval = 1
    static let autoLoadedLingerLength: TimeInterval = 2
  }

}
