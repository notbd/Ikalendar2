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
  /// Updates every second (with 0.1s tolerance for power efficiency).
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

  /// One second after the previous deadline, or now if that is already past (the process was
  /// suspended), so the ticks missed while suspended fire once instead of being replayed one by one
  /// (59847fe, pinned by IkaClockTests).
  nonisolated static func nextDeadline(
    after previous: ContinuousClock.Instant,
    now: ContinuousClock.Instant)
    -> ContinuousClock.Instant
  {
    max(previous + .seconds(1), now)
  }

  private func startTicking() {
    // Deadline-based so ticks don't drift; weak self is re-acquired each lap
    // so short-lived instances (previews, tests) can actually deinit.
    tickTask = Task { [weak self] in
      var nextTick: ContinuousClock.Instant = .now
      while !Task.isCancelled {
        nextTick = Self.nextDeadline(after: nextTick, now: .now)
        try? await Task.sleep(until: nextTick, tolerance: .seconds(0.1), clock: .continuous)
        guard !Task.isCancelled else { return }
        guard let self else { return }

        currentTime = .init()
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
