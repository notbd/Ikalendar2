//
//  IkaNetworkManager.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// A singleton network manager that relies on completion handler.
final class IkaNetworkManager {

  /// The shared singleton instance
  static let shared = IkaNetworkManager()

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  /// Asynchronously get the battle rotation dict from the `splatoon2.ink` api
  func getBattleRotationDict()
    async throws -> BattleRotationDict
  {
    try await fetchAndDecode(
      url: URL(string: Constants.Keys.URL.BATTLE_ROTATIONS)!,
      decodeUsing: IkaDecoder.parseBattleRotationDict)
  }

  /// Asynchronously get the salmon rotation array from the `splatoon2.ink` api
  func getSalmonRotationArray()
    async throws -> [SalmonRotation]
  {
    try await fetchAndDecode(
      url: URL(string: Constants.Keys.URL.SALMON_ROTATIONS)!,
      decodeUsing: IkaDecoder.parseSalmonRotationArray)
  }

  /// Asynchronously get the reward apparel from the `splatoon2.ink` api
  func getRewardApparel()
    async throws -> SalmonApparel
  {
    try await fetchAndDecode(
      url: URL(string: Constants.Keys.URL.TIMELINE)!,
      decodeUsing: IkaDecoder.parseRewardApparel)
  }

  /// Asynchronously fetches and decodes data from a specified URL.
  ///
  /// The function initiates a URLSession data task with a given URL and checks for a valid HTTP
  /// response with a status code of either 200 or 304. If the URLSession data task fails or the
  /// response is not valid, a custom error of type `IkaError` is thrown.
  ///
  /// If the response is valid, the function attempts to decode the raw data into a model of generic
  /// type `T` using the provided decoding closure. If the decoding process fails, a custom error of
  /// type `IkaError` is thrown.
  ///
  /// Errors are propagated up the chain to be handled by the caller.
  ///
  /// - Parameters:
  ///   - url: The URL from which to fetch the data.
  ///   - decoder: A closure that takes raw `Data` as input and attempts to decode it into a model of
  ///     type `T`. This closure must be capable of throwing an error if the decoding process fails.
  ///
  /// - Returns: A model of type `T`, decoded from the fetched data.
  ///
  /// - Throws:
  ///   - `IkaError.connectionError`: If the URLSession data task fails, typically due to network issues.
  ///   - `IkaError.serverError(.badResponse)`: If the response is not a valid HTTP response
  ///                                           or the status code is neither 200 nor 304.
  ///   - `IkaError.serverError(.badData)`: If the decoding process fails.
  ///
  func fetchAndDecode<T>(
    url: URL,
    decodeUsing decoder: (Data) throws -> T)
    async throws -> T
  {
    let (data, response): (Data, URLResponse)

    do {
      (data, response) = try await URLSession.shared.data(from: url)
    }
    catch {
      // ERROR: URLSession data task fails
      throw IkaError.connectionError
    }

    guard
      let httpResponse = response as? HTTPURLResponse,
      [200, 304].contains(httpResponse.statusCode)
    else {
      // ERROR: not an HTTP response or bad status code
      throw IkaError.serverError(.badResponse)
    }

    do {
      let decoded = try decoder(data)
      return decoded
    }
    catch {
      // ERROR: fails to decode data
      throw IkaError.serverError(.badData)
    }
  }
}
