//
//  MotionConstants.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SwiftUI

/// Constant data deciding how fast or how often something moves. Catalog load timings stay in
/// `Config.Catalog` (data flow, not motion); choreography that only one screen uses may stay in
/// that screen's private `Timing` enum, as OnboardingView does.
extension Constants.Motion {
  // MARK: Cadences and Delays

  static let nudgeInterval: TimeInterval = 5
  static let pulseInterval: TimeInterval = 3
  static let slideShowCycle: TimeInterval = 4
  /// Small lag so the bounce haptic lands on the squash, not the tap.
  static let bounceHapticDelay: TimeInterval = 0.1
  /// How long About's unclipped overlay copy stays after a bounce (covers the longest keyframe track).
  static let aboutIconCopyLinger: TimeInterval = 1.6
  static let easterEggCopyLinger: TimeInterval = 2.1
  static let easterEggJumpDelay: TimeInterval = 1.3
  static let licenseLoadDelay: TimeInterval = 0.2
  static let colorSchemeCrossDissolve: TimeInterval = 0.25
  static let timerTolerance: TimeInterval = 0.1

  // MARK: Named Animations

  static let pulse: Animation = .spring(duration: 1.2)
  static let appIconCrossFade: Animation = .spring(response: 1.4, dampingFraction: 1.0, blendDuration: 0.5)
  static let countdownRoll: Animation = .snappy
  static let listReflow: Animation = .bouncy
  static let buttonPulseIn: Animation = .snappy(duration: 0.5)
  static let buttonPulseOut: Animation = .bouncy(duration: 0.4, extraBounce: 0.2)
}
