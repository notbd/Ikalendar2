//
//  Deprecated-NetworkManager.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import Foundation

/// [DEPRECATED]
///
/// A singleton network manager that relies on completion handler.
final class DeprecatedNetworkManager {

  /// The shared singleton instance
  static let shared = DeprecatedNetworkManager()

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  /// Asynchronously get the battle rotation dict from the `splatoon2.ink` api
  /// - Parameter completion: handler function for the result
  func asyncGetBattleRotationDict(
    completion: @escaping (Result<BattleRotationDict, IkaError>)
      -> Void)
  {
    asyncFetchAndDecode(
      url: URL(string: Constants.Keys.URL.BATTLE_ROTATIONS)!,
      decodeUsing: IkaDecoder.parseBattleRotationDict,
      completion: completion)
  }

  /// Asynchronously get the salmon rotation array from the `splatoon2.ink` api
  /// - Parameter completion: handler function for the result
  func asyncGetSalmonRotationArray(
    completion: @escaping (Result<[SalmonRotation], IkaError>)
      -> Void)
  {
    asyncFetchAndDecode(
      url: URL(string: Constants.Keys.URL.SALMON_ROTATIONS)!,
      decodeUsing: IkaDecoder.parseSalmonRotationArray,
      completion: completion)
  }

  /// Asynchronously get the reward gear from the `splatoon2.ink` api
  /// - Parameter completion: handler function for the result
  func asyncGetRewardGear(completion: @escaping (Result<SalmonGear, IkaError>) -> Void) {
    asyncFetchAndDecode(
      url: URL(string: Constants.Keys.URL.TIMELINE)!,
      decodeUsing: IkaDecoder.parseRewardGear,
      completion: completion)
  }

  /// Helper function to asynchronously fetch and decode the data
  /// - Parameters:
  ///   - url: the URL to fetch the data from
  ///   - decoder: the decoding function to decode the data into custom types
  ///   - completion: the callback function to handle the result
  func asyncFetchAndDecode<T>(
    url: URL,
    decodeUsing decoder: @escaping (Data) throws -> T,
    completion: @escaping (Result<T, IkaError>) -> Void)
  {
    let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
      // Scope: callback function
      if error != nil {
        // FAILED: unable to init data task (likely to be device network issues)
        completion(.failure(.unableToComplete))
        return
      }

      guard
        let response = response as? HTTPURLResponse,
        [200, 304].contains(response.statusCode)
      else {
        // FAILED: empty or invalid response
        completion(.failure(.badResponse))
        return
      }

      guard let data else {
        // FAILED: empty data
        completion(.failure(.badData))
        return
      }

      do {
        // decoding...
        let decoded = try decoder(data)
        // SUCCESS!
        completion(.success(decoded))
      }
      catch {
        // FAILED: bad data
        completion(.failure(.badData))
      }
    }

    // fire off data task
    task.resume()
  }
}
