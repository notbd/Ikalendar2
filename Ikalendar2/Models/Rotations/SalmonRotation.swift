//
//  SalmonRotation.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Data model for the salmon run rotation.
struct SalmonRotation: Rotation {
  var id: String { description }

  var description: String

  let startTime: Date
  let endTime: Date
  let stage: SalmonStage?
  let weapons: [SalmonWeapon]?
  var rewardApparel: SalmonApparel?
  let grizzcoWeapon: GrizzcoWeapon?

  var stageAltImageName: String?
  var ifActiveWhenLoaded: Bool

  // MARK: Lifecycle

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

    description = "\(startTime.timeIntervalSince1970)-\(endTime.timeIntervalSince1970)-" +
      "\(stage?.name ?? "nil")-\(weapons?.description ?? "nil")-" +
      "\(rewardApparel?.name ?? "nil")-\(grizzcoWeapon?.name ?? "nil")"

    ifActiveWhenLoaded = IkaTimePublisher.shared.currentTime > startTime && IkaTimePublisher.shared
      .currentTime < endTime

    guard let stage else { return }
    let generator = SeededRandomGenerator(seed: description)
    let numOfAltImages = AssetImageCounter.countImagesWithPrefix(stage.imgFiln + "_Alt")
    let randomChoice = generator.nextInt(bound: numOfAltImages)

    stageAltImageName = stage.imgFiln + "_Alt_\(randomChoice)"
  }

  // MARK: Internal

  /// The equal comparison operator for the SalmonRotation struct.
  /// - Parameters:
  ///   - lhs: The left hand side.
  ///   - rhs: The right hand side.
  /// - Returns: The comparison result.
  static func == (
    lhs: SalmonRotation,
    rhs: SalmonRotation)
    -> Bool
  {
    lhs.startTime == rhs.startTime &&
      lhs.endTime == rhs.endTime &&
      lhs.stage == rhs.stage &&
      lhs.weapons == rhs.weapons &&
      lhs.rewardApparel == rhs.rewardApparel &&
      lhs.grizzcoWeapon == rhs.grizzcoWeapon
  }
}
