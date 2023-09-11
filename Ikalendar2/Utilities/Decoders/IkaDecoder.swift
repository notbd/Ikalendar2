//
//  IkaDecoder.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SwiftyJSON

/// `IkaDecoder` is a utility class designed to handle the parsing and decoding
/// of various data types from raw API response data.
///
/// This class provides a collection of static methods aimed at decoding different
/// kinds of data, such as text, JSON objects and binary data. The methods
/// are designed to be extensible, allowing for the addition of further parsing
/// functions as needed.
///
final class IkaDecoder {
  /// Parses and decodes a text string from the given raw data.
  ///
  /// This function takes `Data` as an input parameter and attempts to decode it
  /// into a `String` using UTF-8 encoding. If the decoding process fails, it throws
  /// a custom error of type `IkaError.serverError(.badData)`.
  ///
  /// - Parameter data: The raw data to decode.
  ///
  /// - Returns: A decoded string if the decoding process is successful.
  ///
  /// - Throws:
  ///   - `IkaError.serverError(.badData)`: If the decoding process fails.
  ///
  static func parseText(from data: Data)
    throws -> String
  {
    guard let text = String(data: data, encoding: .utf8) else {
      throw IkaError.serverError(.badData)
    }
    return text
  }

  /// Parse License from GitHub API.
  static func parseLicenseFromGithubAPI(from data: Data)
    throws -> OpenSourceLicense
  {
    // Will throw SwiftyJSONError if parsing fails
    let rootJSON = try JSON(data: data)

    // Get the GitHub API URL string and Parse into GitHub repo URL string
    guard
      let githubAPIURLString = rootJSON["url"].string,
      let githubRepoURLString = OpenSourceLicense.parseGithubRepoURLString(from: githubAPIURLString)
    else { throw IkaError.serverError(.badData) }

    // Get license info
    guard
      let licenseType = rootJSON["license"]["spdx_id"].string,
      let licenseTypeDescription = rootJSON["license"]["name"].string
    else { throw IkaError.serverError(.badData) }

    // Access 'content' key to get the Base64 encoded string
    guard let base64Content = rootJSON["content"].string
    else { throw IkaError.serverError(.badData) }

    // GitHub adds a new newline character at the end - remove it
    let sanitizedBase64Content = base64Content.replacingOccurrences(of: "\n", with: "")

    // Decode Base64 to Data
    guard
      let decodedData = Data(base64Encoded: sanitizedBase64Content),
      let decodedString = String(data: decodedData, encoding: .utf8)
    else { throw IkaError.serverError(.badData) }

    // Create and return License object
    return OpenSourceLicense(
      repoURL: githubRepoURLString,
      type: licenseType,
      typeDescription: licenseTypeDescription,
      content: decodedString)
  }

  /// Decode the data into a battle rotation dictionary.
  /// - Parameter data: The data to parse from.
  /// - Throws:
  ///   - `SwiftyJSONError`: if failed to parse data into a SwiftyJSON instance.
  ///   - `IkaError.badData`: if JSON is of unsupported format.
  /// - Returns: The parsed dictionary (will NOT be empty).
  ///
  static func parseBattleRotationDict(from data: Data)
    throws -> BattleRotationDict
  {
    var battleRotationDict = BattleRotationDict()

    // Will throw SwiftyJSONError if parsing fails
    let rootJSON = try JSON(data: data)

    // Repeat for all battle modes
    for battleMode in BattleMode.allCases {
      // Access rotation array
      guard let rotationArrayJSON = rootJSON[battleMode.rawValue].array
      else { throw IkaError.serverError(.badData) }

      for rotationJSON in rotationArrayJSON {
        // rotation time
        guard
          let startTimeDouble = rotationJSON["start_time"].double,
          let endTimeDouble = rotationJSON["end_time"].double
        else { throw IkaError.serverError(.badData) }
        let startTime = Date(timeIntervalSince1970: startTimeDouble)
        let endTime = Date(timeIntervalSince1970: endTimeDouble)

        // rotation rule and stages
        guard
          let ruleNameString = rotationJSON["rule"]["name"].string,
          let stageANameString = rotationJSON["stage_a"]["name"].string,
          let stageBNameString = rotationJSON["stage_b"]["name"].string,
          let rule = BattleRule(rawValue: ruleNameString),
          let stageA = BattleStage(rawValue: stageANameString),
          let stageB = BattleStage(rawValue: stageBNameString)
        else { throw IkaError.serverError(.badData) }

        // SUCCESS: construct rotation using parsed data and append to array in dict
        battleRotationDict[battleMode]!.append(
          BattleRotation(
            startTime: startTime,
            endTime: endTime,
            mode: battleMode,
            rule: rule,
            stageA: stageA,
            stageB: stageB))
      }

      // Ensure the result array is not empty
      if battleRotationDict[battleMode]!.isEmpty { throw IkaError.serverError(.badData) }
    }

    // return the parsed dict
    return battleRotationDict
  }

  /// Parse the data into a salmon rotation array.
  /// - Parameter data: The data to parse from.
  /// - Throws:
  ///   - `SwiftyJSONError`: if failed to parse data into a SwiftyJSON instance.
  ///   - `IkaError.badData`: if JSON is of unsupported format.
  /// - Returns: The parsed array (will NOT be empty).
  ///
  static func parseSalmonRotations(from data: Data)
    throws -> [SalmonRotation]
  {
    var salmonRotations: [SalmonRotation] = []

    // Will throw SwiftyJSONError if parsing fails
    let rootDict = try JSON(data: data)

    // Access the `details` array for detailed rotations
    guard let detailsArray = rootDict["details"].array
    else { throw IkaError.serverError(.badData) }

    for rotationDetailsDict in detailsArray {
      // rotation time
      guard
        let startTimeDouble = rotationDetailsDict["start_time"].double,
        let endTimeDouble = rotationDetailsDict["end_time"].double
      else { throw IkaError.serverError(.badData) }
      let startTime = Date(timeIntervalSince1970: startTimeDouble)
      let endTime = Date(timeIntervalSince1970: endTimeDouble)

      // add stage if available
      var stage: SalmonStage?
      if let stageNameString = rotationDetailsDict["stage"]["name"].string {
        stage = SalmonStage(name: stageNameString)
      }

      // add weapons if available
      var weapons: [SalmonWeapon]? = []
      if let weaponsArray = rotationDetailsDict["weapons"].array {
        for weaponDict in weaponsArray {
          // id is in `string` format
          if
            let weaponIDString = weaponDict["id"].string,
            let weaponIDInt = Int(weaponIDString),
            let weapon = SalmonWeapon(weaponIDInt)
          {
            weapons?.append(weapon)
          }

          // id is in `number` format
          else if
            let weaponIDInt = weaponDict["id"].int,
            let weapon = SalmonWeapon(weaponIDInt)
          {
            weapons?.append(weapon)
          }

          // bad id
          else { throw IkaError.serverError(.badData) }
        }
      }

      // set to nil if empty
      if weapons!.isEmpty { weapons = nil }

      // SUCCESS: construct rotation using parsed data and append to array
      salmonRotations.append(.init(
        startTime: startTime,
        endTime: endTime,
        stage: stage,
        weapons: weapons))
    }

    // Check for at least one detailed rotation
    if salmonRotations.isEmpty { throw IkaError.serverError(.badData) }

    // Access the `schedules` array for non-detailed rotations
    guard let schedulesArrayJSON = rootDict["schedules"].array
    else { return salmonRotations }

    for index in salmonRotations.count ..< schedulesArrayJSON.count {
      if
        let startTimeDouble = schedulesArrayJSON[index]["start_time"].double,
        let endTimeDouble = schedulesArrayJSON[index]["end_time"].double
      {
        // SUCCESS: construct rotation using parsed data and append to array
        let startTime = Date(timeIntervalSince1970: startTimeDouble)
        let endTime = Date(timeIntervalSince1970: endTimeDouble)
        salmonRotations.append(.init(
          startTime: startTime,
          endTime: endTime))
      }
    }

    // Return the rotation array
    return salmonRotations
  }

  /// Parse the data into a info wrapper containing salmon run reward apparel and its available time.
  /// - Parameter data: The data to parse from.
  /// - Throws:
  ///   - `SwiftyJSONError`: if failed to parse data into a SwiftyJSON instance.
  ///   - `IkaError.badData`: if JSON is of unsupported format.
  /// - Returns: The parsed SalmonApparel info.
  ///
  static func parseSalmonRewardApparelInfo(from data: Data)
    throws -> SalmonApparelInfo
  {
    // Will throw SwiftyJSONError if parsing fails
    let rootDict = try JSON(data: data)

    // Access the reward apparel dict
    guard let rewardApparelDict = rootDict["coop"]["reward_gear"].dictionary
    else { throw IkaError.serverError(.badData) }

    // Get available time
    guard let availableTimeDouble = rewardApparelDict["available_time"]?.double
    else { throw IkaError.serverError(.badData) }
    let availableTime = Date(timeIntervalSince1970: availableTimeDouble)

    // Get apparel detail
    guard let apparelJSON = rootDict["coop"]["reward_gear"]["gear"].dictionary
    else { throw IkaError.serverError(.badData) }
    // apparel type
    guard let apparelTypeString = apparelJSON["kind"]?.string
    else { throw IkaError.serverError(.badData) }
    // apparel id
    let apparelIDInt: Int
    // id is in `int` format
    if let value = apparelJSON["id"]?.int { apparelIDInt = value }
    // id is in `string` format
    else if
      let apparelIDString = apparelJSON["id"]?.string,
      let value = Int(apparelIDString)
    {
      apparelIDInt = value
    }
    else { throw IkaError.serverError(.badData) }

    // Find apparel with type and id
    var rewardApparelOptional: SalmonApparel?
    switch apparelTypeString {
    case "head":
      rewardApparelOptional = SalmonApparel(type: .head, id: apparelIDInt)
    case "clothes":
      rewardApparelOptional = SalmonApparel(type: .body, id: apparelIDInt)
    case "shoes":
      rewardApparelOptional = SalmonApparel(type: .foot, id: apparelIDInt)
    default:
      rewardApparelOptional = nil
    }
    // strip nil - throw error if invalid type or invalid id
    guard let rewardApparel = rewardApparelOptional
    else { throw IkaError.serverError(.badData) }

    // SUCCESS: return the apparel info
    let rewardApparelInfo = SalmonApparelInfo(apparel: rewardApparel, availableTime: availableTime)
    return rewardApparelInfo
  }
}
