//
//  IkaMockData.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import IkalendarKit

/// Random mock rotations for SwiftUI previews and debug tooling. `makeBattleRotation()` and
/// `makeSalmonRotation()` also run in production, feeding the Alternative Stage Images
/// preview in Settings > Advanced Options. Unit tests use deterministic factories instead.
/// - Note: Force-unwraps in this file are acceptable by convention: all inputs are
///   compile-time-known values (non-empty CaseIterable enums, valid calendar math).
enum IkaMockData {
  /// Generate a mock SalmonRotation data.
  /// - Parameters:
  ///   - rawStartTime: Any time inside the hour the rotation starts at (minutes are dropped).
  ///                   The rotation lasts 42 h.
  ///   - hasStageAndWeapons: If the rotation has stage and weapon information.
  ///   - mysteryWeaponType: The type of mystery weapon for the rotation. (nil, green, gold)
  /// - Returns: The SalmonRotation data.
  static func makeSalmonRotation(
    rawStartTime: Date = Date(),
    hasStageAndWeapons: Bool = true,
    mysteryWeaponType: MysteryWeapon? = nil)
    -> SalmonRotation
  {
    let startTime = rawStartTime.removeMinutes()!
    let endTime = Calendar.current.date(
      byAdding: .hour,
      value: 42,
      to: startTime)!

    var stage: SalmonStage?
    var weapons: [SalmonWeapon]?

    if hasStageAndWeapons {
      stage = SalmonStage.allCases.randomElement()!
      weapons = []
      if mysteryWeaponType == nil {
        for _ in 0 ..< 4 {
          var randomIkaWeapon = IkaWeapon.allCases.randomElement()!
          while weapons!.contains(.vanilla(randomIkaWeapon)) {
            randomIkaWeapon = IkaWeapon.allCases.randomElement()!
          }
          weapons!.append(SalmonWeapon(randomIkaWeapon.id)!)
        }
      }
      else {
        switch mysteryWeaponType! {
          case .green:
            for _ in 0 ..< 3 {
              var randomIkaWeapon = IkaWeapon.allCases.randomElement()!
              while weapons!.contains(.vanilla(randomIkaWeapon)) {
                randomIkaWeapon = IkaWeapon.allCases.randomElement()!
              }
              weapons!.append(SalmonWeapon(randomIkaWeapon.id)!)
            }
            let mysteryWeapon: MysteryWeapon = .green
            weapons!.append(SalmonWeapon(mysteryWeapon.id)!)

          case .gold:
            for _ in 0 ..< 4 {
              let mysteryWeapon: MysteryWeapon = .gold
              weapons!.append(SalmonWeapon(mysteryWeapon.id)!)
            }
        }
      }
    }

    let rewardApparel = [
      SalmonApparel.head(.allCases.randomElement()!),
      SalmonApparel.body(.allCases.randomElement()!),
      SalmonApparel.foot(.allCases.randomElement()!),
    ].randomElement()

    return
      SalmonRotation(
        startTime: startTime,
        endTime: endTime,
        stage: stage,
        weapons: weapons,
        rewardApparel: rewardApparel)
  }

  /// Generate a mock SalmonRotation array data.
  /// - Returns: The loaded SalmonRotation array.
  static func makeSalmonRotations() -> [SalmonRotation] {
    var salmonRotations: [SalmonRotation] = []
    var startTimeArray: [Date] = []
    for index in 0 ..< 5 {
      startTimeArray.append(Calendar.current.date(
        byAdding: .hour,
        value: index * 48,
        to: Date())!)
    }

    salmonRotations.append(
      makeSalmonRotation(
        rawStartTime: startTimeArray[0],
        hasStageAndWeapons: true,
        mysteryWeaponType: nil))
    salmonRotations.append(
      makeSalmonRotation(
        rawStartTime: startTimeArray[1],
        hasStageAndWeapons: true,
        mysteryWeaponType: .green))
    salmonRotations.append(
      makeSalmonRotation(
        rawStartTime: startTimeArray[2],
        hasStageAndWeapons: false))
    salmonRotations.append(
      makeSalmonRotation(
        rawStartTime: startTimeArray[3],
        hasStageAndWeapons: false))
    salmonRotations.append(
      makeSalmonRotation(
        rawStartTime: startTimeArray[4],
        hasStageAndWeapons: false))

    return salmonRotations
  }

  /// Generate a battle rotation starting at the top of the hour of `rawStartTime`, lasting 2 h,
  /// with two distinct random stages (never Shifty Station).
  ///
  /// Regular always gets Turf War. For the other modes, `preferredRule` is used when given,
  /// otherwise a random rule other than Turf War. An unspecified `preferredMode` is random.
  static func makeBattleRotation(
    preferredMode: BattleMode? = nil,
    preferredRule: BattleRule? = nil,
    rawStartTime: Date = Date())
    -> BattleRotation
  {
    let startTime = rawStartTime.removeMinutes()!
    let endTime = startTime.addingTimeInterval(BattleRotation.rotationLength)

    func makeRandomBattleStage() -> BattleStage {
      var stage = BattleStage.allCases.randomElement()!
      while stage == .shiftyStation {
        stage = BattleStage.allCases.randomElement()!
      }
      return stage
    }

    let randomStageA = makeRandomBattleStage()
    var randomStageB = makeRandomBattleStage()
    while randomStageB == randomStageA {
      randomStageB = makeRandomBattleStage()
    }

    var mode = BattleMode.allCases.randomElement()!
    var rule = BattleRule.allCases.randomElement()!

    if let preferredMode { mode = preferredMode }

    if mode == .regular { rule = .turfWar }
    else if let preferredRule { rule = preferredRule }
    else {
      while rule == .turfWar {
        rule = BattleRule.allCases.randomElement()!
      }
    }

    return BattleRotation(
      startTime: startTime,
      endTime: endTime,
      mode: mode,
      rule: rule,
      stageA: randomStageA,
      stageB: randomStageB)
  }

  /// Generate a mock BattleRotationDict data.
  /// - Returns: The loaded BattleRotationDict.
  static func makeBattleRotations() -> BattleRotationDict {
    var battleRotationDict: BattleRotationDict = .init()
    var startTimeArray: [Date] = []
    for index in 0 ..< 8 {
      // two hours apart like the real feed, so every rotation gets a distinct `id` (84d9261)
      startTimeArray.append(Calendar.current.date(
        byAdding: .hour,
        value: index * 2,
        to: Date())!)
    }

    battleRotationDict[.regular] = [
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[0]),
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[1]),
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[2]),
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[3]),
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[4]),
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[5]),
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[6]),
      makeBattleRotation(preferredMode: .regular, preferredRule: .turfWar, rawStartTime: startTimeArray[7]),
    ]

    battleRotationDict[.gachi] = [
      makeBattleRotation(preferredMode: .gachi, preferredRule: .towerControl, rawStartTime: startTimeArray[0]),
      makeBattleRotation(preferredMode: .gachi, preferredRule: .splatZones, rawStartTime: startTimeArray[1]),
      makeBattleRotation(preferredMode: .gachi, preferredRule: .clamBlitz, rawStartTime: startTimeArray[2]),
      makeBattleRotation(preferredMode: .gachi, preferredRule: .rainmaker, rawStartTime: startTimeArray[3]),
    ]

    battleRotationDict[.league] =
      [
        makeBattleRotation(
          preferredMode: .league,
          preferredRule: .towerControl,
          rawStartTime: startTimeArray[0]),
        makeBattleRotation(
          preferredMode: .league,
          preferredRule: .splatZones,
          rawStartTime: startTimeArray[1]),
        makeBattleRotation(preferredMode: .league, preferredRule: .clamBlitz, rawStartTime: startTimeArray[2]),
        makeBattleRotation(preferredMode: .league, preferredRule: .rainmaker, rawStartTime: startTimeArray[3]),
      ]

    return battleRotationDict
  }
}
