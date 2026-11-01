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

/// Pins the tick deadline arithmetic: a drift-free one-second cadence while the clock keeps
/// up, and a single catch-up tick (not one per missed second) after a suspension.
@Suite("IkaClock")
struct IkaClockTests {
  @Test
  func `On-time tick keeps the one-second cadence`() {
    let previous: ContinuousClock.Instant = .now
    let next: ContinuousClock.Instant = IkaClock.nextDeadline(after: previous, now: previous + .milliseconds(50))

    #expect(next == previous + .seconds(1))
  }

  @Test
  func `Tick after a long suspension re-anchors to now instead of replaying missed ticks`() {
    let previous: ContinuousClock.Instant = .now
    let now: ContinuousClock.Instant = previous + .seconds(3600)

    #expect(IkaClock.nextDeadline(after: previous, now: now) == now)
  }
}
