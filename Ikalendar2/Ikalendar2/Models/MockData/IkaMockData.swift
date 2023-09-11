//
//  IkaMockData.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Struct providing mock data for testing purpose.
struct IkaMockData {
  /// Generate a mock SalmonRotation data.
  /// - Parameters:
  ///   - rawStartTime: The raw start time (rotation will start at the next
  ///                       rounded hour of this time).
  ///   - hasStageAndWeapons: If the rotation has stage and weapon information.
  ///   - mysteryWeaponType: The type of mystery weapon for the rotation. (nil, green, gold)
  /// - Returns: The SalmonRotation data.
  static func getSalmonRotation(
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
      // Has stage and weapons
      stage = SalmonStage.allCases.randomElement()!
      weapons = []
      if mysteryWeaponType == nil {
        // No mystery weapons
        for _ in 0 ..< 4 {
          // no duplicates
          var randomIkaWeapon = IkaWeapon.allCases.randomElement()!
          while weapons!.contains(.vanilla(randomIkaWeapon)) {
            randomIkaWeapon = IkaWeapon.allCases.randomElement()!
          }
          weapons!.append(SalmonWeapon(randomIkaWeapon.id)!)
        }
      }
      else {
        // Has mystery weapons
        switch mysteryWeaponType! {
        case .green:
          /// Green question mark
          for _ in 0 ..< 3 {
            // no duplicates
            var randomIkaWeapon = IkaWeapon.allCases.randomElement()!
            while weapons!.contains(.vanilla(randomIkaWeapon)) {
              randomIkaWeapon = IkaWeapon.allCases.randomElement()!
            }
            weapons!.append(SalmonWeapon(randomIkaWeapon.id)!)
          }
          let mysteryWeapon = MysteryWeapon.green
          weapons!.append(SalmonWeapon(mysteryWeapon.id)!)
        case .gold:
          // Gold question mark
          for _ in 0 ..< 4 {
            let mysteryWeapon = MysteryWeapon.gold
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
  static func getSalmonRotations() -> [SalmonRotation] {
    var salmonRotations: [SalmonRotation] = []
    var startTimeArray: [Date] = []
    for index in 0 ..< 5 {
      startTimeArray.append(Calendar.current.date(
        byAdding: .hour,
        value: index * 48,
        to: Date())!)
    }

    salmonRotations.append(
      getSalmonRotation(
        rawStartTime: startTimeArray[0],
        hasStageAndWeapons: true,
        mysteryWeaponType: nil))
    salmonRotations.append(
      getSalmonRotation(
        rawStartTime: startTimeArray[1],
        hasStageAndWeapons: true,
        mysteryWeaponType: .green))
    salmonRotations.append(
      getSalmonRotation(
        rawStartTime: startTimeArray[2],
        hasStageAndWeapons: false))
    salmonRotations.append(
      getSalmonRotation(
        rawStartTime: startTimeArray[3],
        hasStageAndWeapons: false))
    salmonRotations.append(
      getSalmonRotation(
        rawStartTime: startTimeArray[4],
        hasStageAndWeapons: false))

    return salmonRotations
  }

  /// Generate a battle rotation with random stages for a specified rule and raw start time.
  ///
  /// The battle stage `Shifty Station` is explicitly excluded from the random stage selection.
  ///
  /// - Parameters:
  ///   - rule: The battle rule for the rotation. Defaults to be random.
  ///   - rawStartTime: The raw start time for the battle rotation. Generated rotation will have started at
  ///                   the previous rounded hour.
  ///
  /// - Returns: The `BattleRotation` object.
  static func getBattleRotation(
    mode: BattleMode = BattleMode.allCases.randomElement()!,
    rule: BattleRule = BattleRule.allCases.randomElement()!,
    rawStartTime: Date = Date())
    -> BattleRotation
  {
    let startTime = rawStartTime.removeMinutes()!
    let endTime =
      Calendar.current.date(
        byAdding: .hour,
        value: 2,
        to: startTime)!

    func getRandomBattleStage() -> BattleStage {
      var stage = BattleStage.allCases.randomElement()!
      while stage == .shiftyStation {
        // exclude shifty station
        stage = BattleStage.allCases.randomElement()!
      }
      return stage
    }

    let randomStageA = getRandomBattleStage()
    var randomStageB = getRandomBattleStage()
    while randomStageB == randomStageA {
      // avoid duplicate
      randomStageB = getRandomBattleStage()
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
  static func getBattleRotations() -> BattleRotationDict {
    var battleRotationDict = BattleRotationDict()
    var startTimeArray: [Date] = []
    for index in 0 ..< 8 {
      startTimeArray.append(Calendar.current.date(
        byAdding: .hour,
        value: index * 2,
        to: Date())!)
    }

    battleRotationDict[.regular] = [
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[0]),
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[1]),
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[2]),
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[3]),
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[4]),
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[5]),
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[6]),
      getBattleRotation(rule: .turfWar, rawStartTime: startTimeArray[7]),
    ]

    battleRotationDict[.gachi] = [
      getBattleRotation(rule: .towerControl, rawStartTime: startTimeArray[0]),
      getBattleRotation(rule: .splatZones, rawStartTime: startTimeArray[1]),
      getBattleRotation(rule: .clamBlitz, rawStartTime: startTimeArray[2]),
      getBattleRotation(rule: .rainmaker, rawStartTime: startTimeArray[3]),
      getBattleRotation(rule: .towerControl, rawStartTime: startTimeArray[4]),
      getBattleRotation(rule: .splatZones, rawStartTime: startTimeArray[5]),
      getBattleRotation(rule: .clamBlitz, rawStartTime: startTimeArray[6]),
      getBattleRotation(rule: .rainmaker, rawStartTime: startTimeArray[7]),
    ]

    battleRotationDict[.league] =
      [
        getBattleRotation(rule: .rainmaker, rawStartTime: startTimeArray[0]),
        getBattleRotation(rule: .clamBlitz, rawStartTime: startTimeArray[1]),
        getBattleRotation(rule: .towerControl, rawStartTime: startTimeArray[2]),
        getBattleRotation(rule: .splatZones, rawStartTime: startTimeArray[3]),
        getBattleRotation(rule: .clamBlitz, rawStartTime: startTimeArray[4]),
        getBattleRotation(rule: .towerControl, rawStartTime: startTimeArray[5]),
        getBattleRotation(rule: .rainmaker, rawStartTime: startTimeArray[6]),
        getBattleRotation(rule: .splatZones, rawStartTime: startTimeArray[7]),
      ]

    return battleRotationDict
  }
}
