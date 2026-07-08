//
//  IkaNetworkManager.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import OSLog
import SwiftUI

// MARK: - IkaNetworkService

/// Abstraction over the networking layer, enabling mock injection in tests.
protocol IkaNetworkService: Sendable {
  func fetchLicense(from githubRepoURLString: String) async throws -> IkaOpenSourceLicense
  func fetchBattleRotationDict() async throws -> BattleRotationDict
  func fetchSalmonRotations() async throws -> [SalmonRotation]
  func fetchSalmonRewardApparelInfo() async throws -> SalmonApparelInfo
}

extension EnvironmentValues {
  /// The app-wide networking service. Overridden at the App root; default suits previews.
  @Entry var ikaNetworkService: any IkaNetworkService = IkaNetworkManager()
}

// MARK: - IkaNetworkManager

/// `IkaNetworkManager` serves as the networking layer of the application.
/// It is designed to handle asynchronous data fetching and decoding tasks in a unified manner.
/// The class is architected to be easily extendable for supporting various types of data and sources.
/// It is intended to be used in tandem with the `IkaDecoder` utility class for decoding the fetched data.
///
final class IkaNetworkManager: IkaNetworkService {
  /// Dedicated session with explicit timeouts: a hanging server should fail an
  /// auto-load attempt within seconds, not URLSession's 60s default.
  private let session: URLSession

  init() {
    let config: URLSessionConfiguration = .default
    config.timeoutIntervalForRequest = 10
    config.timeoutIntervalForResource = 30
    session = URLSession(configuration: config)
  }

  @concurrent
  func fetchLicense(from githubRepoURLString: String)
    async throws -> IkaOpenSourceLicense
  {
    guard let githubAPIURLString = IkaOpenSourceLicense.parseGithubAPIURLString(from: githubRepoURLString)
    else { throw IkaError.unknownError }
    guard let githubAPIURL = URL(string: githubAPIURLString)
    else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: githubAPIURL,
      decodeUsing: { try IkaDecoder.parseLicenseFromGithubAPI(from: $0) })
  }

  /// Asynchronously fetches the battle rotation dictionary from the `splatoon2.ink` API.
  ///
  /// - Returns: A `BattleRotationDict` object containing the battle rotation data.
  ///
  /// - Throws: `IkaError` if there's any error during fetching or decoding.
  ///
  @concurrent
  func fetchBattleRotationDict()
    async throws -> BattleRotationDict
  {
    guard let url = URL(string: Constants.Key.URLs.battleRotations) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: { try IkaDecoder.parseBattleRotationDict(from: $0) })
  }

  /// Asynchronously fetches the salmon rotation array from the `splatoon2.ink` API.
  ///
  /// - Returns: An array of `SalmonRotation` objects containing the salmon rotation data.
  ///
  /// - Throws: `IkaError` if there's any error during fetching or decoding.
  ///
  @concurrent
  func fetchSalmonRotations()
    async throws -> [SalmonRotation]
  {
    guard let url = URL(string: Constants.Key.URLs.salmonRotations) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: { try IkaDecoder.parseSalmonRotations(from: $0) })
  }

  /// Asynchronously fetches the reward apparel info from the `splatoon2.ink` API.
  ///
  /// - Returns: A `SalmonApparelInfo` object containing the reward apparel type and time.
  ///
  /// - Throws: `IkaError` if there's any error during fetching or decoding.
  ///
  @concurrent
  func fetchSalmonRewardApparelInfo()
    async throws -> SalmonApparelInfo
  {
    guard let url = URL(string: Constants.Key.URLs.salmonApparelInfo) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: { try IkaDecoder.parseSalmonRewardApparelInfo(from: $0) })
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
  ///   - decoder: A closure that takes raw `Data` and decodes it into a type `T`. This closure must be
  ///              capable of throwing an error if the decoding process fails.
  ///
  /// - Returns: A model of type `T`, decoded from the fetched data.
  ///
  /// - Throws:
  ///   - `IkaError.connectionError`: If the URLSession data task fails, typically due to network issues.
  ///   - `IkaError.serverError(.badResponse)`: If the response is not a valid HTTP response
  ///                                           or the status code is neither 200 nor 304.
  ///   - `IkaError.serverError(.badData)`: If the decoding process fails.
  ///
  @concurrent
  func fetchAndDecode<T>(
    url: URL,
    decodeUsing decoder: @Sendable (Data) throws -> T)
    async throws -> T
  {
    let (data, response): (Data, URLResponse)

    do {
      (data, response) = try await session.data(from: url)
    }
    catch is CancellationError {
      // Task cancellation is not a connection failure - propagate as-is
      throw CancellationError()
    }
    catch let urlError as URLError where urlError.code == .cancelled {
      // URLSession reports cancellation as URLError.cancelled
      throw CancellationError()
    }
    catch {
      // ERROR: URLSession data task fails
      Logger.network.error("request to \(url, privacy: .public) failed: \(error, privacy: .public)")
      throw IkaError.connectionError
    }

    guard
      let httpResponse = response as? HTTPURLResponse,
      [200, 304].contains(httpResponse.statusCode)
    else {
      // ERROR: not an HTTP response or bad status code
      let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
      Logger.network.error("unexpected response from \(url, privacy: .public): status \(statusCode)")
      throw IkaError.serverError(.badResponse)
    }

    do {
      return try decoder(data)
    }
    catch {
      // ERROR: fails to decode data
      throw IkaError.serverError(.badData)
    }
  }
}
