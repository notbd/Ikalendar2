//
//  IkaConnectivityChecker.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import OSLog

/// An observable on-demand checker for restricted network environments (GFW).
/// `isGFWed` flips to true (and stays true) once all test domains are unreachable.
/// Used by SettingsAltAppIconView: when `isGFWed`, the easter-egg link opens the Bilibili mirror
/// instead of the YouTube one.
@MainActor
@Observable
final class IkaConnectivityChecker {
  private(set) var isGFWed: Bool = false
  private(set) var checkInProgress: Bool = false

  private let testDomains: [String] = [
    "www.google.com",
    "www.facebook.com",
  ]
  static private let timeoutInterval: TimeInterval = 4.0

  /// One session for the object's lifetime: a session per check is never invalidated and leaks.
  @ObservationIgnored private let session: URLSession

  init() {
    let config: URLSessionConfiguration = .default
    config.timeoutIntervalForRequest = Self.timeoutInterval
    config.timeoutIntervalForResource = Self.timeoutInterval
    session = URLSession(configuration: config)
  }

  func performGFWCheck() async {
    guard !checkInProgress else { return }

    checkInProgress = true

    var failedChecksCount: Int = 0
    let totalChecks = testDomains.count

    await withTaskGroup(of: Bool.self) { [session] group in
      for domain in testDomains {
        group.addTask {
          guard let url = URL(string: "https://\(domain)") else {
            return false
          }

          do {
            _ = try await session.data(for: URLRequest(url: url))
            // For GFW specifically, simply getting *any* HTTP response usually means
            // it isn't GFW-blocked at the network level.
            return true
          }
          catch {
            return false
          }
        }
      }

      for await success in group where !success {
        failedChecksCount += 1
      }
    }

    checkInProgress = false

    // unidirectionally flips the isGFWed status, stays true once gets there
    isGFWed = isGFWed || (failedChecksCount == totalChecks)
    Logger.network.info("GFW check: \(failedChecksCount) of \(totalChecks) probes failed")
  }

  /// Debug Options only: clears the sticky flag so the next check starts clean.
  func resetStatus() {
    isGFWed = false
  }
}
