//
//  Fixtures.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// JSON fixtures for decoder tests, embedded as string constants (zero bundle-resource
/// plumbing, compile-time checked, parallel-safe). Values mirror the real splatoon2.ink
/// response shapes; all stage/rule names and weapon/gear ids are valid enum raw values.
enum Fixtures {
  static func data(_ fixture: String) -> Data {
    Data(fixture.utf8)
  }

  // MARK: - Battle Rotations (schedules.json shape)

  static let battleRotationsValid = """
    {
      "regular": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Turf War" },
          "stage_a": { "name": "The Reef" }, "stage_b": { "name": "MakoMart" } },
        { "start_time": 1700007200, "end_time": 1700014400,
          "rule": { "name": "Turf War" },
          "stage_a": { "name": "Kelp Dome" }, "stage_b": { "name": "Port Mackerel" } }
      ],
      "gachi": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Splat Zones" },
          "stage_a": { "name": "The Reef" }, "stage_b": { "name": "Arowana Mall" } },
        { "start_time": 1700007200, "end_time": 1700014400,
          "rule": { "name": "Rainmaker" },
          "stage_a": { "name": "MakoMart" }, "stage_b": { "name": "Kelp Dome" } }
      ],
      "league": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Clam Blitz" },
          "stage_a": { "name": "Port Mackerel" }, "stage_b": { "name": "The Reef" } },
        { "start_time": 1700007200, "end_time": 1700014400,
          "rule": { "name": "Tower Control" },
          "stage_a": { "name": "Arowana Mall" }, "stage_b": { "name": "MakoMart" } }
      ]
    }
    """

  /// The "league" key is missing entirely.
  static let battleRotationsMissingMode = """
    {
      "regular": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Turf War" },
          "stage_a": { "name": "The Reef" }, "stage_b": { "name": "MakoMart" } }
      ],
      "gachi": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Splat Zones" },
          "stage_a": { "name": "The Reef" }, "stage_b": { "name": "Arowana Mall" } }
      ]
    }
    """

  /// "regular" is present but empty - the parser promises non-empty arrays.
  static let battleRotationsEmptyModeArray = """
    {
      "regular": [],
      "gachi": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Splat Zones" },
          "stage_a": { "name": "The Reef" }, "stage_b": { "name": "Arowana Mall" } }
      ],
      "league": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Clam Blitz" },
          "stage_a": { "name": "Port Mackerel" }, "stage_b": { "name": "The Reef" } }
      ]
    }
    """

  static let battleRotationsUnknownStage = """
    {
      "regular": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Turf War" },
          "stage_a": { "name": "Humpback Pump Trick" }, "stage_b": { "name": "MakoMart" } }
      ],
      "gachi": [], "league": []
    }
    """

  static let battleRotationsUnknownRule = """
    {
      "regular": [
        { "start_time": 1700000000, "end_time": 1700007200,
          "rule": { "name": "Splat Zone" },
          "stage_a": { "name": "The Reef" }, "stage_b": { "name": "MakoMart" } }
      ],
      "gachi": [], "league": []
    }
    """

  /// start_time is an object - a structurally incompatible probe (historically kept
  /// non-string because the pre-Codable parser coerced numeric strings).
  static let battleRotationsWrongTimeType = """
    {
      "regular": [
        { "start_time": {}, "end_time": 1700007200,
          "rule": { "name": "Turf War" },
          "stage_a": { "name": "The Reef" }, "stage_b": { "name": "MakoMart" } }
      ],
      "gachi": [], "league": []
    }
    """

  static let battleRotationsMalformed = "{ not json"

  // MARK: - Salmon Rotations (coop-schedules.json shape)

  /// details x2 (full info, weapon ids in both string and number form, incl. mystery
  /// weapons) + schedules x5 (the 3 extra become time-only rotations).
  static let salmonRotationsValid = """
    {
      "details": [
        { "start_time": 1700000000, "end_time": 1700064000,
          "stage": { "name": "Spawning Grounds" },
          "weapons": [ { "id": "0" }, { "id": 10 }, { "id": "2000" }, { "id": -1 } ] },
        { "start_time": 1700064000, "end_time": 1700128000,
          "stage": { "name": "Marooner's Bay" },
          "weapons": [ { "id": 1000 }, { "id": "1010" }, { "id": -2 }, { "id": 1020 } ] }
      ],
      "schedules": [
        { "start_time": 1700000000, "end_time": 1700064000 },
        { "start_time": 1700064000, "end_time": 1700128000 },
        { "start_time": 1700128000, "end_time": 1700192000 },
        { "start_time": 1700192000, "end_time": 1700256000 },
        { "start_time": 1700256000, "end_time": 1700320000 }
      ]
    }
    """

  static let salmonRotationsNoSchedules = """
    {
      "details": [
        { "start_time": 1700000000, "end_time": 1700064000,
          "stage": { "name": "Spawning Grounds" },
          "weapons": [ { "id": 0 } ] },
        { "start_time": 1700064000, "end_time": 1700128000,
          "stage": { "name": "Lost Outpost" },
          "weapons": [ { "id": 10 } ] }
      ]
    }
    """

  /// details x2 but schedules x1: before the range-hardening fix this fixture
  /// TRAPPED the decoder (invalid Range lowerBound > upperBound).
  static let salmonRotationsDetailsExceedSchedules = """
    {
      "details": [
        { "start_time": 1700000000, "end_time": 1700064000,
          "stage": { "name": "Spawning Grounds" },
          "weapons": [ { "id": 0 } ] },
        { "start_time": 1700064000, "end_time": 1700128000,
          "stage": { "name": "Lost Outpost" },
          "weapons": [ { "id": 10 } ] }
      ],
      "schedules": [
        { "start_time": 1700000000, "end_time": 1700064000 }
      ]
    }
    """

  /// Times only - stage and weapons stay nil.
  static let salmonRotationsMinimalDetails = """
    {
      "details": [
        { "start_time": 1700000000, "end_time": 1700064000 }
      ]
    }
    """

  static let salmonRotationsBadWeaponID = """
    {
      "details": [
        { "start_time": 1700000000, "end_time": 1700064000,
          "stage": { "name": "Spawning Grounds" },
          "weapons": [ { "id": 99999 } ] }
      ]
    }
    """

  /// Grizzco weapon ids (20000+) are deliberately NOT valid SalmonWeapon inputs.
  static let salmonRotationsGrizzcoWeaponID = """
    {
      "details": [
        { "start_time": 1700000000, "end_time": 1700064000,
          "stage": { "name": "Spawning Grounds" },
          "weapons": [ { "id": 20000 } ] }
      ]
    }
    """

  static let salmonRotationsEmptyDetails = """
    { "details": [] }
    """

  // MARK: - Salmon Reward Apparel (timeline.json shape)

  /// head/21006 -> HeadApparel.oceanicHardHat
  static let timelineValidIntID = """
    { "coop": { "reward_gear": { "available_time": 1700000000,
      "gear": { "kind": "head", "id": 21006 } } } }
    """

  static let timelineValidStringID = """
    { "coop": { "reward_gear": { "available_time": 1700000000,
      "gear": { "kind": "head", "id": "21006" } } } }
    """

  static let timelineBodyKind = """
    { "coop": { "reward_gear": { "available_time": 1700000000,
      "gear": { "kind": "clothes", "id": 21005 } } } }
    """

  static let timelineFootKind = """
    { "coop": { "reward_gear": { "available_time": 1700000000,
      "gear": { "kind": "shoes", "id": 21006 } } } }
    """

  static let timelineInvalidKind = """
    { "coop": { "reward_gear": { "available_time": 1700000000,
      "gear": { "kind": "gloves", "id": 21006 } } } }
    """

  /// BodyApparel deliberately skips id 21006 - valid kind, invalid id for that kind.
  static let timelineInvalidIDForKind = """
    { "coop": { "reward_gear": { "available_time": 1700000000,
      "gear": { "kind": "clothes", "id": 21006 } } } }
    """

  static let timelineMissingAvailableTime = """
    { "coop": { "reward_gear": { "gear": { "kind": "head", "id": 21006 } } } }
    """

  // MARK: - GitHub License API

  /// content is base64 of "MIT License" with GitHub's trailing newline inside the value.
  static let licenseValid = """
    { "url": "https://api.github.com/repos/SwiftyJSON/SwiftyJSON",
      "license": { "spdx_id": "MIT", "name": "MIT License" },
      "content": "TUlUIExpY2Vuc2U=\\n" }
    """

  static let licenseBadBase64 = """
    { "url": "https://api.github.com/repos/SwiftyJSON/SwiftyJSON",
      "license": { "spdx_id": "MIT", "name": "MIT License" },
      "content": "!!!not-base64!!!" }
    """

  static let licenseBadURL = """
    { "url": "https://example.com/no-repos-here",
      "license": { "spdx_id": "MIT", "name": "MIT License" },
      "content": "TUlUIExpY2Vuc2U=" }
    """

  static let licenseMissingSPDX = """
    { "url": "https://api.github.com/repos/SwiftyJSON/SwiftyJSON",
      "license": { "name": "MIT License" },
      "content": "TUlUIExpY2Vuc2U=" }
    """
}
