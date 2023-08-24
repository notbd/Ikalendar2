//
//  BattleRotation.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Data model for the battle rotation.
struct BattleRotation: Rotation {
  var id: String { description }

  var description: String

  let startTime: Date
  let endTime: Date

  let rule: BattleRule
  let stageA: BattleStage
  let stageB: BattleStage

  var stageAltImageNameA: String
  var stageAltImageNameB: String

  // MARK: Lifecycle

  init(
    startTime: Date,
    endTime: Date,
    rule: BattleRule,
    stageA: BattleStage,
    stageB: BattleStage)
  {
    self.startTime = startTime
    self.endTime = endTime
    self.rule = rule
    self.stageA = stageA
    self.stageB = stageB

    description = "\(startTime.timeIntervalSince1970)-\(endTime.timeIntervalSince1970)-" +
      "\(rule.name)-\(stageA.name)-\(stageB.name)"

    let generator = SeededRandomGenerator(seed: description)
    let numOfAltImagesA = AssetImageCounter.countImagesWithPrefix(stageA.imgFiln + "_Alt")
    let numOfAltImagesB = AssetImageCounter.countImagesWithPrefix(stageB.imgFiln + "_Alt")
    let randomChoiceA = generator.nextInt(bound: numOfAltImagesA)
    let randomChoiceB = generator.nextInt(bound: numOfAltImagesB)

    stageAltImageNameA = stageA.imgFiln + "_Alt_\(randomChoiceA)"
    stageAltImageNameB = stageB.imgFiln + "_Alt_\(randomChoiceB)"
  }

  // MARK: Internal

  /// The equal comparison operator for the SalmonRotation struct.
  /// - Parameters:
  ///   - lhs: The left hand side.
  ///   - rhs: The right hand side.
  /// - Returns: The comparison result.
  static func == (
    lhs: BattleRotation,
    rhs: BattleRotation)
    -> Bool
  {
    lhs.startTime == rhs.startTime &&
      lhs.endTime == rhs.endTime &&
      lhs.rule == rhs.rule &&
      lhs.stageA == rhs.stageA &&
      lhs.stageB == rhs.stageB
  }

  /// Check if rotation is coming next according to the current time.
  /// - Parameter currentTime: The current time.
  /// - Returns: The boolean val.
  func isNext(currentTime: Date) -> Bool {
    let twoHoursLater =
      Calendar.current.date(
        byAdding: .hour,
        value: 2,
        to: currentTime)!
    return twoHoursLater > startTime && twoHoursLater < endTime
  }
}
