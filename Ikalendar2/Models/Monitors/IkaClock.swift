//
//  IkaClock.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// An observable clock that publishes the current time, updated every second.
/// Views reading `currentTime` in their body re-render each tick via Observation tracking.
@MainActor
@Observable
final class IkaClock {
  /// Updates every second (with 0.1s tolerance for power efficiency).
  private(set) var currentTime: Date = .init()

  @ObservationIgnored private var tickTask: Task<Void, Never>?

  init() {
    startTicking()
  }

  deinit {
    // Legal in a nonisolated deinit: Task is Sendable and cancel() is nonisolated.
    tickTask?.cancel()
  }

  private func startTicking() {
    // Deadline-based so ticks don't drift; weak self is re-acquired each lap
    // so short-lived instances (previews, tests) can actually deinit.
    tickTask = Task { [weak self] in
      var nextTick: ContinuousClock.Instant = .now
      while !Task.isCancelled {
        nextTick += .seconds(1)
        try? await Task.sleep(until: nextTick, tolerance: .seconds(0.1), clock: .continuous)
        guard !Task.isCancelled else { return }
        guard let self else { return }

        currentTime = .init()
      }
    }
  }
}
