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

@Suite("AsyncUtils")
struct AsyncUtilsTests {
  @Test
  func `Fast operation wins the race and returns its value`() async throws {
    let result = try await AsyncUtils.withTimeout(
      seconds: 1,
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
        try await Task.sleep(for: .seconds(10)) // cancellable - cleaned up by the group
        return 0
      }
    }
  }

  @Test
  func `Operation error takes precedence over the timeout`() async {
    await #expect(throws: IkaError.serverError(.badData)) {
      let _: Int = try await AsyncUtils.withTimeout(
        seconds: 1,
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
    // If cancellation did NOT propagate, this would sleep out the full 60s race.
    let task = Task {
      try await AsyncUtils.withTimeout(
        seconds: 60,
        timeoutError: IkaError.connectionError)
      {
        try await Task.sleep(for: .seconds(120))
        return 0
      }
    }
    task.cancel()

    // Don't over-specify WHICH error cancellation produces - only that it errors.
    await #expect(throws: (any Error).self) { try await task.value }
  }
}
