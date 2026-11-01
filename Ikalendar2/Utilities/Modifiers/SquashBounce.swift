//
//  SquashBounce.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SquashBounceValues

/// Animatable values for a squash-and-stretch bounce: dip, hop with overshoot, settle.
struct SquashBounceValues {
  var scale: Double = 1
  var vStretch: Double = 1
  var vTranslation: Double = 0

  /// How far the icon hops. The stretch track is shared; only scale and travel differ per site.
  struct Amplitude {
    let scalePeak: Double
    let dip: Double
    let hop: Double
    let hopHold: Double

    /// Onboarding icon (mid size): a small hop.
    static let onboarding: Amplitude = .init(scalePeak: 1.05, dip: 10, hop: -10, hopHold: -12)
    /// About page icon (large size): a big hop.
    static let aboutIcon: Amplitude = .init(scalePeak: 1.03, dip: 40, hop: -30, hopHold: -34)
  }

  @KeyframesBuilder<SquashBounceValues>
  static func keyframes(_ amplitude: Amplitude)
    -> some Keyframes<SquashBounceValues>
  {
    KeyframeTrack(\.vStretch) {
      CubicKeyframe(1.0, duration: 0.01)
      CubicKeyframe(0.8, duration: 0.06)
      CubicKeyframe(1.12, duration: 0.1)
      CubicKeyframe(1.04, duration: 0.3)
      CubicKeyframe(1.0, duration: 0.3)
      CubicKeyframe(0.9, duration: 0.22)
      CubicKeyframe(1.02, duration: 0.23)
      CubicKeyframe(1.0, duration: 0.20)
    }

    KeyframeTrack(\.scale) {
      LinearKeyframe(1.0, duration: 0.16)
      SpringKeyframe(amplitude.scalePeak, duration: 0.38, spring: .bouncy)
      SpringKeyframe(amplitude.scalePeak, duration: 0.27, spring: .smooth)
      SpringKeyframe(1.0, spring: .bouncy(duration: 0.65, extraBounce: 0.1))
    }

    KeyframeTrack(\.vTranslation) {
      SpringKeyframe(amplitude.dip, duration: 0.11, spring: .bouncy)
      SpringKeyframe(amplitude.hop, duration: 0.43, spring: .bouncy)
      SpringKeyframe(amplitude.hopHold, duration: 0.27, spring: .smooth)
      SpringKeyframe(0.0, spring: .bouncy(duration: 0.65, extraBounce: 0.3))
    }
  }
}

// MARK: - SquashBounce

/// Bounces the content on every change of `trigger`.
///
/// A modifier on purpose: in a `(some View) -> some View` helper, the animator's content
/// closure captures an opaque metatype and trips a non-Sendable warning (a58eaf9).
private struct SquashBounce: ViewModifier {
  let trigger: Int
  let amplitude: SquashBounceValues.Amplitude

  func body(content: Content) -> some View {
    // Reduce Motion hook: read `\.accessibilityReduceMotion` here to skip the keyframes.
    content
      .keyframeAnimator(
        initialValue: SquashBounceValues(),
        trigger: trigger)
      { content, values in
        content
          .scaleEffect(values.scale)
          .scaleEffect(y: values.vStretch)
          .offset(y: values.vTranslation)
      } keyframes: { _ in
        SquashBounceValues.keyframes(amplitude)
      }
  }
}

/// Small lag so the bounce haptic lands on the squash, not the tap.
private let bounceHapticDelay: TimeInterval = 0.1

extension View {
  /// Plays the squash-and-stretch bounce on every change of `trigger`.
  func squashBounce(trigger: Int, amplitude: SquashBounceValues.Amplitude) -> some View {
    modifier(SquashBounce(trigger: trigger, amplitude: amplitude))
  }

  /// Plays the bounce haptic on every change of `trigger`.
  ///
  /// Kept apart from `squashBounce`: About draws its bouncing icon twice (the list row and an
  /// unclipped copy), and the haptic must still play once per bounce.
  func squashBounceHaptic(trigger: Int) -> some View {
    onChange(of: trigger, initial: false) {
      // Short-lived by design: delays the haptic onto the squash frame.
      Task {
        try? await Task.sleep(for: .seconds(bounceHapticDelay))
        await SimpleHaptics.generate(.light)
      }
    }
  }
}
