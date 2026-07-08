//
//  IconNudge.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - IconNudge

/// Periodically wiggles a symbol to hint at an undiscovered, tappable row.
///
/// The cadence is tied to the view's identity, so parent re-renders don't reset
/// the rhythm. Starts one full interval after appearing; stops once discovered.
struct IconNudge: ViewModifier {
  let isActive: Bool
  let interval: TimeInterval

  @State private var trigger: Int = 0

  func body(content: Content) -> some View {
    content
      .symbolEffect(.wiggle, value: trigger)
      .task(id: isActive) {
        guard isActive else { return }

        while !Task.isCancelled {
          try? await Task.sleep(for: .seconds(interval), tolerance: .seconds(0.1))
          guard !Task.isCancelled else { return }

          trigger += 1
        }
      }
  }
}

extension View {
  /// Wiggles the symbol every `interval` seconds while `isActive` is true.
  func iconNudge(
    isActive: Bool,
    interval: TimeInterval = Constants.Config.Timer.nudgeSignalInterval)
    -> some View
  {
    modifier(IconNudge(isActive: isActive, interval: interval))
  }
}

#if DEBUG
#Preview {
  // The star wiggles every 2s; the checkmark stays still (discovered).
  VStack(spacing: 32) {
    Image(systemName: "star")
      .font(.largeTitle)
      .iconNudge(isActive: true, interval: 2)
    Image(systemName: "checkmark.circle")
      .font(.largeTitle)
      .iconNudge(isActive: false, interval: 2)
  }
}
#endif
