//
//  SalmonRotation.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

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

    let generator = SeededRandomGenerator(seed: description)

    let prefix = stage.imgFiln + "_Alt_"
    // does not need to divide by 2, can safely ignore large copies
    let numOfAltImages = AssetImageCounter.countImagesWithPrefix(prefix)
    let randomChoice = generator.nextInt(bound: numOfAltImages)

    return stage.imgFiln + "_Alt_\(randomChoice)"
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
