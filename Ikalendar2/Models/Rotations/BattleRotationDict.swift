//
//  BattleRotationDict.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

typealias BattleRotationDict = [BattleMode: [BattleRotation]]

extension BattleRotationDict {
  /// Returns true if any `BattleMode`s contain empty rotations.
  var isEmpty: Bool {
    values.contains { $0.isEmpty }
  }

  /// Returns true if the dict is outdated.
  var isOutdated: Bool {
    !isEmpty && self[.gachi]!.first!.endTime < IkaTimePublisher.shared.currentTime
  }

  init() {
    self = [:]
    for mode in BattleMode.allCases {
      self[mode] = []
    }
  }
}
