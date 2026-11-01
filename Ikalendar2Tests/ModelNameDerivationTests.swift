//
//  ModelNameDerivationTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - ModelNameDerivationTests

/// Pins the names and keys that used to be hand-written switch tables, so deriving them
/// from `rawValue` / `allCases` can never silently change a rendered name, an asset name
/// or the feed-name lookup. The expected values are copies of the original tables.
@Suite("Model name derivation")
struct ModelNameDerivationTests {
  // MARK: - BattleRule

  static private let battleRuleTable: [BattleRule: (name: String, key: String)] = [
    .turfWar: ("Turf War", "turf_war"),
    .splatZones: ("Splat Zones", "splat_zones"),
    .towerControl: ("Tower Control", "tower_control"),
    .rainmaker: ("Rainmaker", "rainmaker"),
    .clamBlitz: ("Clam Blitz", "clam_blitz"),
  ]

  @Test(arguments: BattleRule.allCases)
  func `Battle rule name and key match the original table`(rule: BattleRule) throws {
    let expected = try #require(Self.battleRuleTable[rule])
    #expect(rule.name == expected.name)
    #expect(rule.key == expected.key)
  }

  // MARK: - BattleStage

  static private let battleStageNameTable: [BattleStage: String] = [
    .anchoVGames: "Ancho-V Games",
    .arowanaMall: "Arowana Mall",
    .blackbellySkatepark: "Blackbelly Skatepark",
    .campTriggerfish: "Camp Triggerfish",
    .gobyArena: "Goby Arena",
    .humpbackPumpTrack: "Humpback Pump Track",
    .inkblotArtAcademy: "Inkblot Art Academy",
    .kelpDome: "Kelp Dome",
    .makoMart: "MakoMart",
    .mantaMaria: "Manta Maria",
    .morayTowers: "Moray Towers",
    .musselforgeFitness: "Musselforge Fitness",
    .newAlbacoreHotel: "New Albacore Hotel",
    .piranhaPit: "Piranha Pit",
    .portMackerel: "Port Mackerel",
    .shellendorfInstitute: "Shellendorf Institute",
    .shiftyStation: "Shifty Station",
    .skipperPavilion: "Skipper Pavilion",
    .snapperCanal: "Snapper Canal",
    .starfishMainstage: "Starfish Mainstage",
    .sturgeonShipyard: "Sturgeon Shipyard",
    .theReef: "The Reef",
    .wahooWorld: "Wahoo World",
    .walleyeWarehouse: "Walleye Warehouse",
  ]

  @Test(arguments: BattleStage.allCases)
  func `Battle stage name matches the original table`(stage: BattleStage) throws {
    let expected = try #require(Self.battleStageNameTable[stage])
    #expect(stage.name == expected)
  }

  // MARK: - SalmonStage

  static private let salmonStageNameTable: [SalmonStage: String] = [
    .spawningGrounds: "Spawning Grounds",
    .maroonerSBay: "Marooner's Bay",
    .lostOutpost: "Lost Outpost",
    .salmonidSmokeyard: "Salmonid Smokeyard",
    .ruinsOfArkPolaris: "Ruins of Ark Polaris",
  ]

  @Test(arguments: SalmonStage.allCases)
  func `Salmon stage name lookup matches the original table`(stage: SalmonStage) throws {
    let expected = try #require(Self.salmonStageNameTable[stage])
    #expect(stage.name == expected)
    #expect(SalmonStage(name: expected) == stage)
  }

  @Test
  func `Salmon stage name lookup is exact`() {
    #expect(SalmonStage(name: "spawning grounds") == nil)
    #expect(SalmonStage(name: "Spawning Grounds ") == nil)
    #expect(SalmonStage(name: "") == nil)
  }
}
