//
//  AsyncUtilsTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - AsyncUtilsTests

/// Every duration that an assertion does not depend on is deliberately unreachable (600 s+):
/// slow CI simulators have taken over a second for trivial tests, and a reachable deadline
/// would turn that slowness into a wrong result.
@Suite("AsyncUtils")
struct AsyncUtilsTests {
  @Test
  func `Fast operation wins the race and returns its value`() async throws {
    let result = try await AsyncUtils.withTimeout(
      seconds: 600,
      timeoutError: IkaError.connectionError)
    {
      42
    }
    #expect(result == 42)
  }

  @Test
  func `Slow operation loses and the injected timeout error surfaces`() async {
    await #expect(throws: IkaError.connectionError) {
      try await AsyncUtils.withTimeout(
        seconds: 0.05,
        timeoutError: IkaError.connectionError)
      {
        try await Task.sleep(for: .seconds(600)) // cancellable - cleaned up by the group
        return 0
      }
    }
  }

  @Test
  func `Operation error takes precedence over the timeout`() async {
    await #expect(throws: IkaError.serverError(.badData)) {
      let _: Int = try await AsyncUtils.withTimeout(
        seconds: 600,
        timeoutError: IkaError.connectionError)
      {
        throw IkaError.serverError(.badData)
      }
    }
  }

  @Test(.timeLimit(.minutes(1)))
  func `External cancellation ends the race promptly`() async {
    // "Promptly" is enforced by the timeLimit trait rather than a wall-clock
    // assertion - elapsed-time checks are flaky under parallel-test load.
    // Both the race deadline and the operation sleep sit far beyond the 1-minute
    // limit, so if cancellation did NOT propagate, the trait trips deterministically
    // instead of the timeout error arriving first and satisfying the expectation.
    let task = Task {
      try await AsyncUtils.withTimeout(
        seconds: 600,
        timeoutError: IkaError.connectionError)
      {
        try await Task.sleep(for: .seconds(1200))
        return 0
      }
    }
    task.cancel()

    // Don't over-specify WHICH error cancellation produces - only that it errors.
    await #expect(throws: (any Error).self) { try await task.value }
  }
}
