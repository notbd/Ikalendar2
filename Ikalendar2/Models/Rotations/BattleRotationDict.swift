//
//  BattleRotationDict.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import Foundation

typealias BattleRotationDict = [BattleMode: [BattleRotation]]

extension BattleRotationDict {
  var numOfRounds: Int { self[.gachi]!.count }

  // MARK: Lifecycle

  init() {
    self = [
      .regular: [] as [BattleRotation],
      .gachi: [] as [BattleRotation],
      .league: [] as [BattleRotation],
    ]
  }

  // MARK: Internal

  /// Check if any battle mode has an empty array.
  /// - Returns: The boolean val.
  func isEmpty() -> Bool {
    self[.regular]!.isEmpty || self[.gachi]!.isEmpty || self[.league]!.isEmpty
  }

  /// Check if the dict needs to refresh.
  /// - Parameter currentTime: The current time.
  /// - Returns: The boolean val.
  func doesNeedToRefresh(currentTime: Date) -> Bool {
    if isEmpty() {
      return false
    }
    else {
      return currentTime > self[.gachi]![0].endTime
    }
  }
}
