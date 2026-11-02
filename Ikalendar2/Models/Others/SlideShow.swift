//
//  SlideShow.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - SlideShow

/// The App Icon page's color slideshow as a value: what it is doing, and when the running cycle
/// started. The progress bar renders the cycle on its own, so the state changes once per cycle
/// rather than on every progress step.
struct SlideShow: Equatable {
  enum Phase: Equatable {
    case playing
    case paused
    /// Variant picker is open; playback resumes on collapse iff it was playing before.
    case pickerExpanded(wasPlaying: Bool)
  }

  let cycleLength: TimeInterval
  private(set) var phase: Phase = .paused
  /// Start of the running cycle; nil whenever the bar shows empty (paused, or picker open).
  private(set) var cycleStart: Date?

  var isPlaying: Bool { phase == .playing }

  var isPickerExpanded: Bool {
    if case .pickerExpanded = phase { return true }
    return false
  }

  /// The running cycle as a date range, for `ProgressView(timerInterval:)`.
  var cycle: ClosedRange<Date>? {
    cycleStart.map { $0 ... $0.addingTimeInterval(cycleLength) }
  }

  init(cycleLength: TimeInterval = Constants.Motion.slideShowCycle) {
    self.cycleLength = cycleLength
  }

  // MARK: Transitions

  /// Starts playing with a fresh cycle. Already playing, it keeps the running cycle, so a repeated
  /// onAppear does not reset the bar.
  mutating func play(now: Date) {
    guard !isPlaying else { return }

    phase = .playing
    cycleStart = now
  }

  /// Stops playing and empties the bar; the next play starts a fresh cycle.
  mutating func pause() {
    phase = .paused
    cycleStart = nil
  }

  /// Play/pause button.
  mutating func togglePlayback(now: Date) {
    switch phase {
      case .playing: pause()
      case .paused: play(now: now)
      case .pickerExpanded: break // the control is hit-disabled while the picker is open
    }
  }

  /// Opens the variant picker, remembering whether to resume on collapse.
  mutating func expandPicker() {
    phase = .pickerExpanded(wasPlaying: isPlaying)
    cycleStart = nil
  }

  /// Collapses the picker (dimming-layer tap or variant selection), restoring playback.
  mutating func collapsePicker(now: Date) {
    guard case .pickerExpanded(let wasPlaying) = phase else { return }

    if wasPlaying { play(now: now) } else { pause() }
  }

  /// Next tap or cycle completion. The caller advances the variant; a fresh cycle starts only
  /// while playing.
  mutating func restartCycle(now: Date) {
    guard isPlaying else { return }

    cycleStart = now
  }
}
