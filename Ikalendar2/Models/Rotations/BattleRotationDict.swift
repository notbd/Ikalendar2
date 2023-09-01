//
//  BattleRotationDict.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

typealias BattleRotationDict = [BattleMode: [BattleRotation]]

extension BattleRotationDict {
  var numOfRounds: Int { self[.gachi]!.count }

  /// True if any battle mode has an empty array.
  var isEmpty: Bool {
    self[.regular]!.isEmpty || self[.gachi]!.isEmpty || self[.league]!.isEmpty
  }

  /// True if the dict is outdated and needs to reload at the moment.
  /// Embodies isEmpty() check internally.
  var isOutdated: Bool {
    !isEmpty &&
      IkaTimePublisher.shared.currentTime > self[.gachi]![0].endTime
  }

  // MARK: Lifecycle

  init() {
    self = [
      .regular: [] as [BattleRotation],
      .gachi: [] as [BattleRotation],
      .league: [] as [BattleRotation],
    ]
  }

}
