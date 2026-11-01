//
//  PeriodicPulse.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - PeriodicPulse

/// Pulses the content red and back, once on appear and then every `interval` seconds.
///
/// The trigger is this modifier's own `@State` and the loop is this view's `.task`, so nothing
/// shared can restart or synchronize the rhythm. Hoisting pulse/nudge timers into shared state
/// made unrelated views pulse together (a5bfe35, fixed in 20a3489).
private struct PeriodicPulse: ViewModifier {
  let interval: TimeInterval
  let animation: Animation

  @State private var trigger: Int = 0

  func body(content: Content) -> some View {
    content
      .phaseAnimator([false, true], trigger: trigger) { content, isLit in
        content
          .foregroundStyle(isLit ? Color.red : Color.secondary)
      } animation: { _ in
        animation
      }
      .task {
        trigger += 1

        while !Task.isCancelled {
          try? await Task.sleep(for: .seconds(interval), tolerance: .seconds(Constants.Motion.timerTolerance))
          guard !Task.isCancelled else { return }

          trigger += 1
        }
      }
  }
}

extension View {
  /// Pulses the content red every `interval` seconds while it is on screen.
  func periodicPulse(
    every interval: TimeInterval = Constants.Motion.pulseInterval,
    animation: Animation = Constants.Motion.pulse)
    -> some View
  {
    modifier(PeriodicPulse(interval: interval, animation: animation))
  }
}
