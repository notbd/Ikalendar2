//
//  IkaLogger.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import OSLog

/// Centralized loggers, one per subsystem concern.
/// View in Console.app or `log stream` filtered by the app's bundle id.
extension Logger {
  static private let subsystem = Bundle.main.bundleIdentifier ?? "ikalendar2"

  /// Networking: request failures, unexpected HTTP responses.
  static let network: Logger = .init(subsystem: subsystem, category: "network")
  /// Decoding: wire-payload parse failures (with underlying DecodingError detail).
  static let decode: Logger = .init(subsystem: subsystem, category: "decode")
  /// Data stores: catalog load/auto-load lifecycle anomalies.
  static let store: Logger = .init(subsystem: subsystem, category: "store")
}
