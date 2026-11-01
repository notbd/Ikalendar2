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

/// Production `IkaNetworkService`: one dedicated `URLSession` with short timeouts, decoding
/// through `IkaDecoder`.
final class IkaNetworkManager: IkaNetworkService {
  /// Dedicated session with explicit timeouts: a hanging server should fail an
  /// auto-load attempt within seconds, not URLSession's 60s default.
  private let session: URLSession

  /// - Parameter configuration: Injectable so tests can stub responses through a `URLProtocol`;
  ///   the timeouts below are applied to a copy, so the caller's object stays unchanged.
  init(configuration: URLSessionConfiguration = .default) {
    let sessionConfiguration = configuration.copy() as? URLSessionConfiguration ?? configuration
    sessionConfiguration.timeoutIntervalForRequest = 10
    sessionConfiguration.timeoutIntervalForResource = 30
    session = URLSession(configuration: sessionConfiguration)
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

  /// Fetches the battle schedules from splatoon2.ink.
  @concurrent
  func fetchBattleRotationDict()
    async throws -> BattleRotationDict
  {
    guard let url = URL(string: Constants.Key.URLs.battleRotations) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: { try IkaDecoder.parseBattleRotationDict(from: $0) })
  }

  /// Fetches the Salmon Run schedules from splatoon2.ink.
  @concurrent
  func fetchSalmonRotations()
    async throws -> [SalmonRotation]
  {
    guard let url = URL(string: Constants.Key.URLs.salmonRotations) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: { try IkaDecoder.parseSalmonRotations(from: $0) })
  }

  /// Fetches the current Salmon Run reward gear from the splatoon2.ink timeline.
  @concurrent
  func fetchSalmonRewardApparelInfo()
    async throws -> SalmonApparelInfo
  {
    guard let url = URL(string: Constants.Key.URLs.salmonApparelInfo) else { throw IkaError.unknownError }

    return try await fetchAndDecode(
      url: url,
      decodeUsing: { try IkaDecoder.parseSalmonRewardApparelInfo(from: $0) })
  }

  /// Fetches `url` with GET, accepts status 200 or 304, and decodes the body with `decoder`.
  /// Transport failures become `.connectionError`, other statuses `.serverError(.badResponse)`,
  /// decode failures `.serverError(.badData)`; task cancellation propagates as `CancellationError`.
  @concurrent
  private func fetchAndDecode<T>(
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
      Logger.network.error("request to \(url, privacy: .public) failed: \(error, privacy: .public)")
      throw IkaError.connectionError
    }

    guard
      let httpResponse = response as? HTTPURLResponse,
      [200, 304].contains(httpResponse.statusCode)
    else {
      let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
      Logger.network.error("unexpected response from \(url, privacy: .public): status \(statusCode)")
      throw IkaError.serverError(.badResponse)
    }

    do {
      return try decoder(data)
    }
    catch {
      throw IkaError.serverError(.badData)
    }
  }
}
