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
  var stageAAltImageName: String { altImageName(for: stageA) }
  var stageBAltImageName: String { altImageName(for: stageB) }

  /// Picks one of the stage's general or rule-specific alt images, seeded by `description`
  /// so the same rotation always resolves to the same image.
  private func altImageName(for stage: BattleStage) -> String {
    let generator: SeededRandomGenerator = .init(seed: description)

    let generalPrefix = stage.imageName + "_Alt_"
    let ruleSpecificPrefix = stage.imageName + "_Alt+\(rule.abbreviation)_"

    let numOfAltImagesGeneral: Int = AssetImageCounter.countImagesWithPrefix(generalPrefix)
    let numOfAltImagesRuleSpecific: Int = AssetImageCounter.countImagesWithPrefix(ruleSpecificPrefix)

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
    let twoHoursLater = currentTime.addingTimeInterval(2 * 60 * 60)
    return startTime < twoHoursLater && twoHoursLater < endTime
  }
}
