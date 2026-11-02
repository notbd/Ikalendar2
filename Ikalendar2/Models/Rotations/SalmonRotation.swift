//
//  SalmonRotation.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import IkalendarKit

// MARK: - SalmonRotation

/// Data model for the salmon run rotation.
struct SalmonRotation: Rotation {
  let startTime: Date
  let endTime: Date

  let stage: SalmonStage?
  let weapons: [SalmonWeapon]?
  var rewardApparel: SalmonApparel?
  let grizzcoWeapon: GrizzcoWeapon?

  init(
    startTime: Date,
    endTime: Date,
    stage: SalmonStage? = nil,
    weapons: [SalmonWeapon]? = nil,
    rewardApparel: SalmonApparel? = nil,
    grizzcoWeapon: GrizzcoWeapon? = nil)
  {
    self.startTime = startTime
    self.endTime = endTime
    self.stage = stage
    self.weapons = weapons
    self.rewardApparel = rewardApparel
    self.grizzcoWeapon = grizzcoWeapon
  }
}

extension SalmonRotation {
  var description: String {
    id +
      "-" +
      "\(stage?.name ?? "nil")-\(weapons?.description ?? "nil")" +
      "-" +
      "\(rewardApparel?.name ?? "nil")-\(grizzcoWeapon?.name ?? "nil")"
  }
}

extension SalmonRotation {
  var stageAltImageName: String? {
    guard let stage else { return nil }

    let generator: SeededRandomGenerator = .init(seed: description)

    let prefix = stage.imageName + "_Alt_"
    // Counts only `<stage>_Alt_<n>`; the `_Large` copies have a different name and are not double-counted.
    let numOfAltImages: Int = AssetImageCounter.countImagesWithPrefix(prefix)

    // a stage without any alt image keeps its standard image
    guard numOfAltImages > 0
    else { return stage.imageName }

    let randomChoice = generator.nextInt(bound: numOfAltImages)

    return stage.imageName + "_Alt_\(randomChoice)"
  }

  var stageAltImageNameLarge: String? {
    if let stageAltImageName {
      stageAltImageName + "_Large"
    }
    else {
      nil
    }
  }
}
