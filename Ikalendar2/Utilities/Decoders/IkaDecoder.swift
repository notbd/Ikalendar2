//
//  IkaDecoder.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import OSLog

// MARK: - IkaDecoder

/// `IkaDecoder` is a utility for parsing raw API response data into domain models.
///
/// Each parser decodes into private Codable DTOs mirroring the wire format, then
/// maps and validates into domain types. Every decoding or validation failure is
/// surfaced uniformly as `IkaError.serverError(.badData)`.
enum IkaDecoder {
  /// Parses and decodes a text string from the given raw data.
  ///
  /// - Parameter data: The raw data to decode.
  /// - Returns: A decoded string if the decoding process is successful.
  /// - Throws: `IkaError.serverError(.badData)`: if the data is not valid UTF-8.
  static func parseText(from data: Data)
    throws -> String
  {
    guard let str = String(data: data, encoding: .utf8) else {
      throw IkaError.serverError(.badData)
    }

    return str
  }

  /// Parse License from the GitHub API response.
  ///
  /// - Throws: `IkaError.serverError(.badData)`: if the payload is malformed, the
  ///   url is not a GitHub API repos url, or the content is not valid base64 UTF-8.
  static func parseLicenseFromGithubAPI(from data: Data)
    throws -> IkaOpenSourceLicense
  {
    let dto = try decodeDTO(GithubLicenseDTO.self, from: data)

    guard
      let licenseInfo = dto.license,
      let licenseType = licenseInfo.spdxID,
      let licenseTypeDescription = licenseInfo.name,
      let githubAPIURLString = dto.url,
      let githubRepoURLString = IkaOpenSourceLicense.parseGithubRepoURLString(from: githubAPIURLString),
      let base64Content = dto.content
    else { throw IkaError.serverError(.badData) }

    // GitHub inserts newline characters into the base64 payload - strip them
    let sanitizedBase64Content = base64Content.replacingOccurrences(of: "\n", with: "")

    guard
      let decodedData = Data(base64Encoded: sanitizedBase64Content),
      let decodedString = String(data: decodedData, encoding: .utf8)
    else { throw IkaError.serverError(.badData) }

    return IkaOpenSourceLicense(
      repoURL: githubRepoURLString,
      type: licenseType,
      typeDescription: licenseTypeDescription,
      content: decodedString)
  }

  /// Decode the data into a battle rotation dictionary.
  ///
  /// - Throws: `IkaError.serverError(.badData)`: if the payload is malformed, any
  ///   battle mode is missing or empty, or a rule/stage name is unrecognized.
  /// - Returns: The parsed dictionary (will NOT be empty).
  static func parseBattleRotationDict(from data: Data)
    throws -> BattleRotationDict
  {
    let dto = try decodeDTO(BattleSchedulesDTO.self, from: data)

    var battleRotationDict: BattleRotationDict = .init()

    for battleMode in BattleMode.allCases {
      guard let rotationDTOs = dto.rotations(for: battleMode), !rotationDTOs.isEmpty
      else { throw IkaError.serverError(.badData) }

      battleRotationDict[battleMode] = try rotationDTOs.map { rotationDTO in
        guard
          let rule = BattleRule(rawValue: rotationDTO.rule.name),
          let stageA = BattleStage(rawValue: rotationDTO.stageA.name),
          let stageB = BattleStage(rawValue: rotationDTO.stageB.name)
        else { throw IkaError.serverError(.badData) }

        return BattleRotation(
          startTime: Date(timeIntervalSince1970: rotationDTO.startTime),
          endTime: Date(timeIntervalSince1970: rotationDTO.endTime),
          mode: battleMode,
          rule: rule,
          stageA: stageA,
          stageB: stageB)
      }
    }

    return battleRotationDict
  }

  /// Parse the data into a salmon rotation array.
  ///
  /// Detailed rotations come from `details`; any extra entries in `schedules`
  /// become time-only rotations. Unknown stage names degrade to a nil stage;
  /// invalid weapon ids are an error.
  ///
  /// - Throws: `IkaError.serverError(.badData)`: if the payload is malformed,
  ///   `details` is missing/empty, or a weapon id is invalid.
  /// - Returns: The parsed array (will NOT be empty).
  static func parseSalmonRotations(from data: Data)
    throws -> [SalmonRotation]
  {
    let dto = try decodeDTO(SalmonSchedulesDTO.self, from: data)

    guard let detailDTOs = dto.details, !detailDTOs.isEmpty
    else { throw IkaError.serverError(.badData) }

    var salmonRotations = try detailDTOs.map { detailDTO in
      let weapons: [SalmonWeapon]? = try detailDTO.weapons.flatMap { weaponDTOs in
        let parsed = try weaponDTOs.map { weaponDTO in
          guard let weapon = SalmonWeapon(weaponDTO.id.value)
          else { throw IkaError.serverError(.badData) }

          return weapon
        }
        return parsed.isEmpty ? nil : parsed
      }

      return SalmonRotation(
        startTime: Date(timeIntervalSince1970: detailDTO.startTime),
        endTime: Date(timeIntervalSince1970: detailDTO.endTime),
        stage: detailDTO.stage.flatMap { SalmonStage(name: $0.name) },
        weapons: weapons)
    }

    // Append any schedules beyond the detailed window as time-only rotations.
    // Guard against `schedules` being shorter than `details`: constructing a Range
    // with lowerBound > upperBound traps at runtime.
    if
      let scheduleDTOs = dto.schedules,
      scheduleDTOs.count > salmonRotations.count
    {
      for scheduleDTO in scheduleDTOs[salmonRotations.count...] {
        // skip entries with missing times instead of failing the whole parse
        guard
          let startTime = scheduleDTO.startTime,
          let endTime = scheduleDTO.endTime
        else { continue }

        salmonRotations.append(SalmonRotation(
          startTime: Date(timeIntervalSince1970: startTime),
          endTime: Date(timeIntervalSince1970: endTime)))
      }
    }

    return salmonRotations
  }

  /// Parse the data into an info wrapper containing the salmon run reward apparel
  /// and its available time.
  ///
  /// - Throws: `IkaError.serverError(.badData)`: if the payload is malformed, the
  ///   gear kind is unknown, or the id is invalid for that kind.
  static func parseSalmonRewardApparelInfo(from data: Data)
    throws -> SalmonApparelInfo
  {
    let dto = try decodeDTO(SalmonTimelineDTO.self, from: data)

    guard
      let rewardGear = dto.coop?.rewardGear,
      let availableTimeDouble = rewardGear.availableTime,
      let gear = rewardGear.gear
    else { throw IkaError.serverError(.badData) }

    let apparelIDInt = gear.id.value

    let rewardApparel: SalmonApparel? =
      switch gear.kind {
        case "head": SalmonApparel(type: .head, id: apparelIDInt)
        case "clothes": SalmonApparel(type: .body, id: apparelIDInt)
        case "shoes": SalmonApparel(type: .foot, id: apparelIDInt)
        default: nil
      }

    guard let rewardApparel
    else { throw IkaError.serverError(.badData) }

    return SalmonApparelInfo(
      apparel: rewardApparel,
      availableTime: Date(timeIntervalSince1970: availableTimeDouble))
  }

  // MARK: - Shared decoding

  /// Decodes a DTO, mapping every `DecodingError` (malformed JSON, missing keys,
  /// type mismatches) uniformly to `IkaError.serverError(.badData)`.
  static private func decodeDTO<T: Decodable>(_: T.Type, from data: Data)
    throws -> T
  {
    do {
      return try JSONDecoder().decode(T.self, from: data)
    }
    catch {
      Logger.decode.error("failed to decode \(T.self, privacy: .public): \(error, privacy: .public)")
      throw IkaError.serverError(.badData)
    }
  }
}

// MARK: - FlexibleIntID

/// An id the API serves as either a JSON number or a numeric string.
private struct FlexibleIntID: Decodable {
  let value: Int

  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let intValue = try? container.decode(Int.self) {
      value = intValue
    }
    else if
      let stringValue = try? container.decode(String.self),
      let intValue = Int(stringValue)
    {
      value = intValue
    }
    else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "id is neither an integer nor a numeric string")
    }
  }
}

// MARK: - NamedEntityDTO

private struct NamedEntityDTO: Decodable {
  let name: String
}

// MARK: - BattleSchedulesDTO

private struct BattleSchedulesDTO: Decodable {
  let regular: [BattleRotationDTO]?
  let gachi: [BattleRotationDTO]?
  let league: [BattleRotationDTO]?

  func rotations(for mode: BattleMode) -> [BattleRotationDTO]? {
    switch mode {
      case .regular: regular
      case .gachi: gachi
      case .league: league
    }
  }
}

// MARK: - BattleRotationDTO

private struct BattleRotationDTO: Decodable {
  let startTime: Double
  let endTime: Double
  let rule: NamedEntityDTO
  let stageA: NamedEntityDTO
  let stageB: NamedEntityDTO

  enum CodingKeys: String, CodingKey {
    case startTime = "start_time"
    case endTime = "end_time"
    case rule
    case stageA = "stage_a"
    case stageB = "stage_b"
  }
}

// MARK: - SalmonSchedulesDTO

private struct SalmonSchedulesDTO: Decodable {
  let details: [SalmonDetailDTO]?
  let schedules: [SalmonScheduleDTO]?
}

// MARK: - SalmonDetailDTO

private struct SalmonDetailDTO: Decodable {
  let startTime: Double
  let endTime: Double
  let stage: NamedEntityDTO?
  let weapons: [SalmonWeaponDTO]?

  enum CodingKeys: String, CodingKey {
    case startTime = "start_time"
    case endTime = "end_time"
    case stage
    case weapons
  }
}

// MARK: - SalmonWeaponDTO

private struct SalmonWeaponDTO: Decodable {
  let id: FlexibleIntID
}

// MARK: - SalmonScheduleDTO

private struct SalmonScheduleDTO: Decodable {
  let startTime: Double?
  let endTime: Double?

  enum CodingKeys: String, CodingKey {
    case startTime = "start_time"
    case endTime = "end_time"
  }
}

// MARK: - SalmonTimelineDTO

private struct SalmonTimelineDTO: Decodable {
  let coop: CoopDTO?

  struct CoopDTO: Decodable {
    let rewardGear: RewardGearDTO?

    enum CodingKeys: String, CodingKey {
      case rewardGear = "reward_gear"
    }
  }

  struct RewardGearDTO: Decodable {
    let availableTime: Double?
    let gear: GearDTO?

    enum CodingKeys: String, CodingKey {
      case availableTime = "available_time"
      case gear
    }
  }

  struct GearDTO: Decodable {
    let kind: String
    let id: FlexibleIntID
  }
}

// MARK: - GithubLicenseDTO

private struct GithubLicenseDTO: Decodable {
  let url: String?
  let license: LicenseInfoDTO?
  let content: String?

  struct LicenseInfoDTO: Decodable {
    let spdxID: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
      case spdxID = "spdx_id"
      case name
    }
  }
}
