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
/// The cadence is tied to the view's identity rather than its value: parent
/// re-renders no longer reset the rhythm (the old stored-property Timer did,
/// making nudges fire on an inconsistent schedule). The loop starts one full
/// interval after appearing and ends as soon as `isActive` flips off - i.e.
/// once the user has discovered the feature.
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
