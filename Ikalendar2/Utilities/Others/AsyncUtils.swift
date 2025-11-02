//
//  AsyncUtils.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

enum AsyncUtils {
  static func withTimeout<T>(
    seconds: TimeInterval,
    timeoutError: Error,
    operation: @escaping @Sendable () async throws -> T) async throws
    -> T
  {
    try await withThrowingTaskGroup(of: T.self) { group in
      group.addTask {
        try await operation()
      }

      group.addTask {
        try await Task.sleep(for: .seconds(seconds))
        throw timeoutError
      }

      guard let result = try await group.next() else {
        throw timeoutError
      }

      group.cancelAll()
      return result
    }
  }
}
