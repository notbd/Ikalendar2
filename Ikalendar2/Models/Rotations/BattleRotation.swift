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
  /// Includes the mode: the three battle feeds share start times, so the protocol's default id
  /// would collide.
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
  /// so the same rotation always resolves to the same image. A stage without any alt image
  /// (Shifty Station) keeps its standard image (a0b8cef, d635200; pinned by AltStageImageTests).
  private func altImageName(for stage: BattleStage) -> String {
    let generator: SeededRandomGenerator = .init(seed: description)

    let generalPrefix = stage.imageName + "_Alt_"
    let ruleSpecificPrefix = stage.imageName + "_Alt+\(rule.abbreviation)_"

    let numOfAltImagesGeneral: Int = AssetImageCounter.countImagesWithPrefix(generalPrefix)
    let numOfAltImagesRuleSpecific: Int = AssetImageCounter.countImagesWithPrefix(ruleSpecificPrefix)
    let numOfAltImages = numOfAltImagesGeneral + numOfAltImagesRuleSpecific

    guard numOfAltImages > 0
    else { return stage.imageName }

    let randomChoice = generator.nextInt(bound: numOfAltImages)

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
