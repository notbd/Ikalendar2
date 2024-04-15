//
//  IkaNetworkManager.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// `IkaNetworkManager` is a singleton class that serves as the networking layer of the application.
/// It is designed to handle asynchronous data fetching and decoding tasks in a unified manner.
/// The class is architected to be easily extendable for supporting various types of data and sources.
/// It is intended to be used in tandem with the `IkaDecoder` utility class for decoding the fetched data.
///
final class IkaNetworkManager {
  static let shared: IkaNetworkManager = .init()

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  /// Asynchronously fetches a text file from a specified URL and returns its content as a `String`.
  /// It is intended for fetching read-only textual data like logs, licenses, configuration files, etc.
  ///
  /// - Parameter urlString: The URL String pointing to the text file.
  ///
  /// - Returns: A `String` containing the text file content.
  ///
  /// - Throws: `IkaError` if there's any error during fetching or decoding.
  ///
  func fetchTextFile(from urlString: String)
    async throws -> String
  {
    guard let url = URL(string: urlString) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: IkaDecoder.parseText)
  }

  func fetchLicense(from githubRepoURLString: String)
    async throws -> IkaOpenSourceLicense
  {
    guard let githubAPIURLString = IkaOpenSourceLicense.parseGithubAPIURLString(from: githubRepoURLString)
    else { throw IkaError.unknownError }

    guard let githubAPIURL = URL(string: githubAPIURLString)
    else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: githubAPIURL,
      decodeUsing: IkaDecoder.parseLicenseFromGithubAPI)
  }

  /// Asynchronously fetches the battle rotation dictionary from the `splatoon2.ink` API.
  ///
  /// - Returns: A `BattleRotationDict` object containing the battle rotation data.
  ///
  /// - Throws: `IkaError` if there's any error during fetching or decoding.
  ///
  func getBattleRotationDict()
    async throws -> BattleRotationDict
  {
    guard let url = URL(string: Constants.Key.URL.BATTLE_ROTATIONS) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: IkaDecoder.parseBattleRotationDict)
  }

  /// Asynchronously fetches the salmon rotation array from the `splatoon2.ink` API.
  ///
  /// - Returns: An array of `SalmonRotation` objects containing the salmon rotation data.
  ///
  /// - Throws: `IkaError` if there's any error during fetching or decoding.
  ///
  func getSalmonRotations()
    async throws -> [SalmonRotation]
  {
    guard let url = URL(string: Constants.Key.URL.SALMON_ROTATIONS) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: IkaDecoder.parseSalmonRotations)
  }

  /// Asynchronously fetches the reward apparel info from the `splatoon2.ink` API.
  ///
  /// - Returns: A `SalmonApparelInfo` object containing the reward apparel type and time.
  ///
  /// - Throws: `IkaError` if there's any error during fetching or decoding.
  ///
  func getSalmonRewardApparelInfo()
    async throws -> SalmonApparelInfo
  {
    guard let url = URL(string: Constants.Key.URL.SALMON_APPAREL_INFO) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: IkaDecoder.parseSalmonRewardApparelInfo)
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
