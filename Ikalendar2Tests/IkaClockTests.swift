//
//  IkaClockTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaClockTests

/// Pins the tick arithmetic: a tick publishes the whole second it woke in, so countdowns computed
/// from the clock step by exactly one second, wherever in that second the tick landed.
@Suite("IkaClock")
struct IkaClockTests {
  private let second: Date = .init(timeIntervalSinceReferenceDate: 815_000_000)

  @Test(arguments: [0.0, 0.3, 0.999])
  func `A tick publishes the whole second it woke in`(offset: TimeInterval) {
    let wake: Date = second.addingTimeInterval(offset)

    #expect(IkaClock.wholeSecond(containing: wake) == second)
  }
}
