//
//  BattleRotation.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import IkalendarKit

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
  var id: String { "\(mode)-\(startTime)-\(endTime)" }

  var description: String {
    id +
      "-" +
      "\(rule)-\(stageA)-\(stageB)"
  }
}

extension BattleRotation {
  var stageAAltImageName: String {
    let generator = SeededRandomGenerator(seed: description)

    let generalPrefix = stageA.imgFiln + "_Alt_"
    let ruleSpecificPrefix = stageA.imgFiln + "_Alt+\(rule.abbreviation)_"

    let numOfAltImagesGeneral = AssetImageCounter.countImagesWithPrefix(generalPrefix)
    let numOfAltImagesRuleSpecific = AssetImageCounter.countImagesWithPrefix(ruleSpecificPrefix)

    let randomChoice = generator.nextInt(bound: numOfAltImagesGeneral + numOfAltImagesRuleSpecific)

    return if randomChoice < numOfAltImagesGeneral {
      "\(generalPrefix)\(randomChoice)"
    }
    else {
      "\(ruleSpecificPrefix)\(randomChoice - numOfAltImagesGeneral)"
    }
  }

  var stageBAltImageName: String {
    let generator = SeededRandomGenerator(seed: description)

    let generalPrefix = stageB.imgFiln + "_Alt_"
    let ruleSpecificPrefix = stageB.imgFiln + "_Alt+\(rule.abbreviation)_"

    let numOfAltImagesGeneral = AssetImageCounter.countImagesWithPrefix(generalPrefix)
    let numOfAltImagesRuleSpecific = AssetImageCounter.countImagesWithPrefix(ruleSpecificPrefix)

    let randomChoice = generator.nextInt(bound: numOfAltImagesGeneral + numOfAltImagesRuleSpecific)

    return if randomChoice < numOfAltImagesGeneral {
      "\(generalPrefix)\(randomChoice)"
    }
    else {
      "\(ruleSpecificPrefix)\(randomChoice - numOfAltImagesGeneral)"
    }
  }
}

extension BattleRotation {
  /// Determines whether the rotation is coming up next.
  func isNext(_ currentTime: Date) -> Bool {
    let twoHoursLater =
      Calendar.current.date(
        byAdding: .hour,
        value: 2,
        to: currentTime)!
    return startTime < twoHoursLater && twoHoursLater < endTime
  }
}
