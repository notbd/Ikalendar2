//
//  BattleRotationDict.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

typealias BattleRotationDict = [BattleMode: [BattleRotation]]

extension BattleRotationDict {
  /// True if ANY battle mode has no rotations loaded (or is missing entirely).
  /// - Note: Named to avoid shadowing `Dictionary.isEmpty`, whose semantics differ.
  var hasEmptyMode: Bool {
    count < BattleMode.allCases.count || values.contains { $0.isEmpty }
  }

  /// Whether the currently loaded rotations are already stale at `currentTime`.
  /// All three battle modes rotate on the same schedule, so checking `.gachi` suffices.
  func isOutdated(_ currentTime: Date) -> Bool {
    guard let firstGachiRotation = self[.gachi]?.first else { return false }

    return firstGachiRotation.endTime < currentTime
  }

  init() {
    self = [:]
    for mode in BattleMode.allCases {
      self[mode] = []
    }
  }
}
