//
//  IkaMockData.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import IkalendarKit

/// Struct providing mock data for testing purpose.
/// - Note: Force-unwraps in this file are acceptable by convention: all inputs are
///   compile-time-known values (non-empty CaseIterable enums, valid calendar math),
///   and this type is only ever used from previews and debug tooling.
enum IkaMockData {
  /// Generate a mock SalmonRotation data.
  /// - Parameters:
  ///   - rawStartTime: The raw start time (rotation will start at the next
  ///                       rounded hour of this time).
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
            // Green question mark
            for _ in 0 ..< 3 {
              // no duplicates
              var randomIkaWeapon = IkaWeapon.allCases.randomElement()!
              while weapons!.contains(.vanilla(randomIkaWeapon)) {
                randomIkaWeapon = IkaWeapon.allCases.randomElement()!
              }
              weapons!.append(SalmonWeapon(randomIkaWeapon.id)!)
            }
            let mysteryWeapon: MysteryWeapon = .green
            weapons!.append(SalmonWeapon(mysteryWeapon.id)!)

          case .gold:
            // Gold question mark
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
  static func makeBattleRotation(
    preferredMode: BattleMode? = nil,
    preferredRule: BattleRule? = nil,
    rawStartTime: Date = Date())
    -> BattleRotation
  {
    let startTime = rawStartTime.removeMinutes()!
    let endTime =
      Calendar.current.date(
        byAdding: .hour,
        value: 2,
        to: startTime)!

    func makeRandomBattleStage() -> BattleStage {
      var stage = BattleStage.allCases.randomElement()!
      while stage == .shiftyStation {
        // exclude shifty station
        stage = BattleStage.allCases.randomElement()!
      }
      return stage
    }

    let randomStageA = makeRandomBattleStage()
    var randomStageB = makeRandomBattleStage()
    while randomStageB == randomStageA {
      // avoid duplicate
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
      startTimeArray.append(Calendar.current.date(
        byAdding: .second,
        value: index * 15,
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
