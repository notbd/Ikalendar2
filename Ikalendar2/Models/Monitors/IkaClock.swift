//
//  IkaClock.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import UIKit

/// An observable clock that publishes the current time, updated every second.
/// Views reading `currentTime` in their body re-render each tick via Observation tracking.
@MainActor
@Observable
final class IkaClock {
  /// Updates on every whole second (with 0.1s tolerance for power efficiency), snapped to that second.
  private(set) var currentTime: Date = .init()

  @ObservationIgnored private var tickTask: Task<Void, Never>?
  @ObservationIgnored private var significantTimeChangeTask: Task<Void, Never>?
  @ObservationIgnored private var timeZoneChangeTask: Task<Void, Never>?

  init() {
    startTicking()
    significantTimeChangeTask = observeTimeChanges(named: UIApplication.significantTimeChangeNotification)
    timeZoneChangeTask = observeTimeChanges(named: .NSSystemTimeZoneDidChange)
  }

  deinit {
    // Legal in a nonisolated deinit: Task is Sendable and cancel() is nonisolated.
    tickTask?.cancel()
    significantTimeChangeTask?.cancel()
    timeZoneChangeTask?.cancel()
  }

  /// The whole second `now` is in, as a Date: what the clock publishes for a tick that woke at `now`
  /// (pinned by IkaClockTests).
  nonisolated static func wholeSecond(containing now: Date) -> Date {
    Date(timeIntervalSinceReferenceDate: now.timeIntervalSinceReferenceDate.rounded(.down))
  }

  private func startTicking() {
    // Sleeps to the next whole second each lap, so ticks don't drift; weak self is re-acquired
    // each lap so short-lived instances (previews, tests) can actually deinit.
    tickTask = Task { [weak self] in
      while !Task.isCancelled {
        let now: Date = .init()
        let nextSecond = Self.wholeSecond(containing: now).addingTimeInterval(1)
        try? await Task.sleep(for: .seconds(nextSecond.timeIntervalSince(now)), tolerance: .seconds(0.1))
        guard !Task.isCancelled else { return }
        guard let self else { return }

        // Snapped to the second it represents: countdowns computed from it never skip or repeat a
        // second, and every row flips on the same whole second. A late wake (the process was
        // suspended) snaps to the second it actually woke in, so the missed ticks collapse into one
        // instead of being replayed (59847fe).
        currentTime = Self.wholeSecond(containing: .init())
      }
    }
  }

  /// `TimeZone.current` is cached per process and only picks up a new system time zone after
  /// `NSTimeZone.resetSystemTimeZone()` (8e1ea9d). Reset it whenever `name` is posted, then publish a fresh
  /// `currentTime` so views reading the clock re-render right away in the new zone. Observed for:
  /// - `significantTimeChangeNotification`: a new day (midnight), a carrier time update, or a
  ///   change to or from daylight saving time.
  /// - `NSSystemTimeZoneDidChange`: a change of the time zone, which Apple does not list among
  ///   the significant time changes.
  private func observeTimeChanges(named name: Notification.Name) -> Task<Void, Never> {
    Task { [weak self] in
      for await _ in NotificationCenter.default.notifications(named: name) {
        guard let self else { return }

        NSTimeZone.resetSystemTimeZone()
        currentTime = .init()
      }
    }
  }
}
