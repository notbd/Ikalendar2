//
//  IkaInternetConnectivityPublisher.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

@Observable
final class IkaInternetConnectivityPublisher {
  var isGFWed: Bool = false
  private(set) var checkInProgress: Bool = false

  private let testDomains: [String] = [
    "www.google.com",
    "www.facebook.com",
  ]
  static private let timeoutInterval: TimeInterval = 4.0

  /// Reused across checks: creating a URLSession per call leaks the session
  /// (it is never invalidated). Consider `.ephemeral` in the future to keep
  /// GFW probes free of local cache interference.
  @ObservationIgnored private let session: URLSession

  init() {
    let config: URLSessionConfiguration = .default
    config.timeoutIntervalForRequest = Self.timeoutInterval
    config.timeoutIntervalForResource = Self.timeoutInterval
    session = URLSession(configuration: config)
  }

  @MainActor
  func performGFWCheck() async {
    guard !checkInProgress else { return }

    checkInProgress = true

    var failedChecksCount: Int = 0
    let totalChecks = testDomains.count

    await withTaskGroup(of: Bool.self) { group in
      for domain in testDomains {
        group.addTask {
          guard let url = URL(string: "https://\(domain)") else {
            // invalid URL treated as failure
            return false
          }

          do {
            _ = try await self.session.data(for: URLRequest(url: url))
            // For GFW specifically, simply getting *any* HTTP response usually means
            // it isn't GFW-blocked at the network level.
            return true
          }
          catch {
            return false
          }
        }
      }

      // collect results
      for await success in group where !success {
        failedChecksCount += 1
      }
    }

    checkInProgress = false

    // unidirectionally flips the isGFWed status, stays true once gets there
    isGFWed = isGFWed || (failedChecksCount == totalChecks)
  }

  /// for manually reset
  func resetStatus() {
    isGFWed = false
  }
}
