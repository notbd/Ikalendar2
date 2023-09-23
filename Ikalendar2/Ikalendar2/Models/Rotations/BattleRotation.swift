//
//  BattleRotation.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - BattleRotation

/// Data model for the battle rotation.
struct BattleRotation: Rotation, Hashable {
  let startTime: Date
  let endTime: Date

  let mode: BattleMode
  let rule: BattleRule
  let stageA: BattleStage
  let stageB: BattleStage
}

extension BattleRotation {
  var id: String { "\(startTime)-\(endTime)-\(mode)" }

  var description: String {
    id +
      "-" +
      "\(rule)-\(stageA)-\(stageB)"
  }
}

extension BattleRotation {
  var stageAltImageNameA: String {
    let generator = SeededRandomGenerator(seed: description)
    let numOfAltImagesA = AssetImageCounter.countImagesWithPrefix(stageA.imgFiln + "_Alt")
    let randomChoiceA = generator.nextInt(bound: numOfAltImagesA)
    return stageA.imgFiln + "_Alt_\(randomChoiceA)"
  }

  var stageAltImageNameB: String {
    let generator = SeededRandomGenerator(seed: description)
    let numOfAltImagesB = AssetImageCounter.countImagesWithPrefix(stageB.imgFiln + "_Alt")
    let randomChoiceB = generator.nextInt(bound: numOfAltImagesB)
    return stageB.imgFiln + "_Alt_\(randomChoiceB)"
  }
}

extension BattleRotation {
  /// Determines whether the rotation is coming up next.
  var isNext: Bool {
    let twoHoursLater =
      Calendar.current.date(
        byAdding: .hour,
        value: 2,
        to: IkaTimePublisher.shared.currentTime)!
    return startTime < twoHoursLater && twoHoursLater < endTime
  }
}
