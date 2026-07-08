//
//  IkaDecoderTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaDecoderTests

@Suite("IkaDecoder")
struct IkaDecoderTests {
  // MARK: - parseText

  @Suite("Parse Text")
  struct ParseTextTests {
    @Test
    func `Valid UTF-8 data round-trips`() throws {
      let text = "Hello, Inkopolis! 🦑"
      let parsed = try IkaDecoder.parseText(from: Data(text.utf8))
      #expect(parsed == text)
    }

    @Test
    func `Empty data decodes to empty string`() throws {
      let parsed = try IkaDecoder.parseText(from: Data())
      #expect(parsed.isEmpty)
    }

    @Test
    func `Invalid UTF-8 bytes throw badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseText(from: Data([0xFF, 0xFE, 0xFD]))
      }
    }
  }

  // MARK: - parseBattleRotationDict

  @Suite("Parse Battle Rotation Dict")
  struct ParseBattleRotationDictTests {
    @Test
    func `Valid payload decodes two rotations per mode`() throws {
      let dict = try IkaDecoder.parseBattleRotationDict(from: Fixtures.data(Fixtures.battleRotationsValid))

      for mode in BattleMode.allCases {
        #expect(dict[mode]?.count == 2)
      }
      #expect(!dict.hasEmptyMode)

      let firstGachi = try #require(dict[.gachi]?.first)
      #expect(firstGachi.mode == .gachi)
      #expect(firstGachi.rule == .splatZones)
      #expect(firstGachi.stageA == .theReef)
      #expect(firstGachi.stageB == .arowanaMall)
      #expect(firstGachi.startTime == Date(timeIntervalSince1970: 1_700_000_000))
      #expect(firstGachi.endTime == Date(timeIntervalSince1970: 1_700_007_200))
    }

    @Test
    func `Missing mode key throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseBattleRotationDict(from: Fixtures.data(Fixtures.battleRotationsMissingMode))
      }
    }

    @Test
    func `Empty mode array throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseBattleRotationDict(from: Fixtures.data(Fixtures.battleRotationsEmptyModeArray))
      }
    }

    @Test
    func `Unknown stage name throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseBattleRotationDict(from: Fixtures.data(Fixtures.battleRotationsUnknownStage))
      }
    }

    @Test
    func `Unknown rule name throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseBattleRotationDict(from: Fixtures.data(Fixtures.battleRotationsUnknownRule))
      }
    }

    @Test
    func `Structurally wrong time type throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseBattleRotationDict(from: Fixtures.data(Fixtures.battleRotationsWrongTimeType))
      }
    }

    @Test
    func `Malformed JSON throws`() {
      #expect(throws: (any Error).self) {
        try IkaDecoder.parseBattleRotationDict(from: Fixtures.data(Fixtures.battleRotationsMalformed))
      }
    }
  }

  // MARK: - parseSalmonRotations

  @Suite("Parse Salmon Rotations")
  struct ParseSalmonRotationsTests {
    @Test
    func `Valid payload merges details and trailing schedules`() throws {
      let rotations = try IkaDecoder.parseSalmonRotations(from: Fixtures.data(Fixtures.salmonRotationsValid))

      #expect(rotations.count == 5)

      // details[0]: full info, weapon ids in string + int + mystery forms
      #expect(rotations[0].stage == .spawningGrounds)
      #expect(rotations[0].weapons == [
        .vanilla(.splooshOMatic),
        .vanilla(.splattershotJr),
        .vanilla(.classicSquiffer),
        .mystery(.green),
      ])

      // details[1]: gold mystery weapon
      #expect(rotations[1].stage == .maroonerSBay)
      #expect(rotations[1].weapons?.contains(.mystery(.gold)) == true)

      // schedules-only tail: times set, no stage/weapons
      for rotation in rotations[2...] {
        #expect(rotation.stage == nil)
        #expect(rotation.weapons == nil)
      }
      #expect(rotations[2].startTime == Date(timeIntervalSince1970: 1_700_128_000))
    }

    @Test
    func `Missing schedules returns details only`() throws {
      let rotations = try IkaDecoder
        .parseSalmonRotations(from: Fixtures.data(Fixtures.salmonRotationsNoSchedules))
      #expect(rotations.count == 2)
    }

    @Test
    func `Details exceeding schedules does not trap`() throws {
      // Pre-fix, this fixture constructed Range(2..<1) and crashed the process.
      let rotations = try IkaDecoder
        .parseSalmonRotations(from: Fixtures.data(Fixtures.salmonRotationsDetailsExceedSchedules))
      #expect(rotations.count == 2)
    }

    @Test
    func `Minimal details decode with nil stage and weapons`() throws {
      let rotations = try IkaDecoder
        .parseSalmonRotations(from: Fixtures.data(Fixtures.salmonRotationsMinimalDetails))
      let first = try #require(rotations.first)
      #expect(first.stage == nil)
      #expect(first.weapons == nil)
    }

    @Test
    func `Unknown weapon id throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseSalmonRotations(from: Fixtures.data(Fixtures.salmonRotationsBadWeaponID))
      }
    }

    @Test
    func `Grizzco weapon id is rejected`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseSalmonRotations(from: Fixtures.data(Fixtures.salmonRotationsGrizzcoWeaponID))
      }
    }

    @Test
    func `Empty details throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseSalmonRotations(from: Fixtures.data(Fixtures.salmonRotationsEmptyDetails))
      }
    }
  }

  // MARK: - parseSalmonRewardApparelInfo

  @Suite("Parse Salmon Reward Apparel Info")
  struct ParseSalmonRewardApparelInfoTests {
    @Test
    func `Integer gear id decodes`() throws {
      let info = try IkaDecoder
        .parseSalmonRewardApparelInfo(from: Fixtures.data(Fixtures.timelineValidIntID))
      #expect(info.apparel == .head(.oceanicHardHat))
      #expect(info.availableTime == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test
    func `String gear id decodes`() throws {
      let info = try IkaDecoder
        .parseSalmonRewardApparelInfo(from: Fixtures.data(Fixtures.timelineValidStringID))
      #expect(info.apparel == .head(.oceanicHardHat))
    }

    @Test
    func `Clothes kind maps to body apparel`() throws {
      let info = try IkaDecoder
        .parseSalmonRewardApparelInfo(from: Fixtures.data(Fixtures.timelineBodyKind))
      if case .body = info.apparel { } else {
        Issue.record("expected .body apparel, got \(info.apparel)")
      }
    }

    @Test
    func `Shoes kind maps to foot apparel`() throws {
      let info = try IkaDecoder
        .parseSalmonRewardApparelInfo(from: Fixtures.data(Fixtures.timelineFootKind))
      if case .foot = info.apparel { } else {
        Issue.record("expected .foot apparel, got \(info.apparel)")
      }
    }

    @Test
    func `Unknown kind throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseSalmonRewardApparelInfo(from: Fixtures.data(Fixtures.timelineInvalidKind))
      }
    }

    @Test
    func `Valid kind with invalid id for that kind throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseSalmonRewardApparelInfo(from: Fixtures.data(Fixtures.timelineInvalidIDForKind))
      }
    }

    @Test
    func `Missing available time throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder
          .parseSalmonRewardApparelInfo(from: Fixtures.data(Fixtures.timelineMissingAvailableTime))
      }
    }
  }

  // MARK: - parseLicenseFromGithubAPI

  @Suite("Parse License")
  struct ParseLicenseTests {
    @Test
    func `Valid payload decodes all fields and strips the base64 newline`() throws {
      let license = try IkaDecoder.parseLicenseFromGithubAPI(from: Fixtures.data(Fixtures.licenseValid))
      #expect(license.repoURL == "https://github.com/SwiftyJSON/SwiftyJSON")
      #expect(license.type == "MIT")
      #expect(license.typeDescription == "MIT License")
      #expect(license.content == "MIT License")
    }

    @Test
    func `Invalid base64 content throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseLicenseFromGithubAPI(from: Fixtures.data(Fixtures.licenseBadBase64))
      }
    }

    @Test
    func `Non-GitHub-API url throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseLicenseFromGithubAPI(from: Fixtures.data(Fixtures.licenseBadURL))
      }
    }

    @Test
    func `Missing spdx id throws badData`() {
      #expect(throws: IkaError.serverError(.badData)) {
        try IkaDecoder.parseLicenseFromGithubAPI(from: Fixtures.data(Fixtures.licenseMissingSPDX))
      }
    }
  }
}
