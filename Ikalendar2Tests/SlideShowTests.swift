//
//  SlideShowTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - SlideShowTests

/// Pins the App Icon slideshow's state machine: which cycle runs after each control, and that the
/// variant picker resumes playback only if it was playing before it opened.
@Suite("Slide show")
struct SlideShowTests {
  private let start: Date = .init(timeIntervalSinceReferenceDate: 1000)
  private let later: Date = .init(timeIntervalSinceReferenceDate: 1002.5)

  private func playing(since now: Date) -> SlideShow {
    var slideShow: SlideShow = .init()
    slideShow.play(now: now)
    return slideShow
  }

  @Test
  func `Starts paused with no running cycle`() {
    let slideShow: SlideShow = .init()

    #expect(slideShow.phase == .paused)
    #expect(slideShow.cycle == nil)
  }

  @Test
  func `Play starts one slideshow cycle at now`() {
    let slideShow: SlideShow = playing(since: start)

    #expect(slideShow.isPlaying)
    #expect(slideShow.cycle == start ... start.addingTimeInterval(Constants.Motion.slideShowCycle))
  }

  @Test
  func `Play while playing keeps the running cycle`() {
    var slideShow: SlideShow = playing(since: start)
    slideShow.play(now: later)

    #expect(slideShow.cycleStart == start)
  }

  @Test
  func `Pause clears the running cycle`() {
    var slideShow: SlideShow = playing(since: start)
    slideShow.togglePlayback(now: later)

    #expect(slideShow.phase == .paused)
    #expect(slideShow.cycleStart == nil)
  }

  @Test
  func `Opening the picker while playing remembers to resume and clears the cycle`() {
    var slideShow: SlideShow = playing(since: start)
    slideShow.expandPicker()

    #expect(slideShow.phase == .pickerExpanded(wasPlaying: true))
    #expect(slideShow.cycleStart == nil)
  }

  @Test
  func `Opening the picker while paused remembers to stay paused`() {
    var slideShow: SlideShow = .init()
    slideShow.expandPicker()

    #expect(slideShow.phase == .pickerExpanded(wasPlaying: false))
    #expect(slideShow.cycleStart == nil)
  }

  @Test
  func `Closing the picker after playing resumes with a fresh cycle`() {
    var slideShow: SlideShow = playing(since: start)
    slideShow.expandPicker()
    slideShow.collapsePicker(now: later)

    #expect(slideShow.isPlaying)
    #expect(slideShow.cycleStart == later)
  }

  @Test
  func `Closing the picker after pausing stays paused`() {
    var slideShow: SlideShow = .init()
    slideShow.expandPicker()
    slideShow.collapsePicker(now: later)

    #expect(slideShow.phase == .paused)
    #expect(slideShow.cycleStart == nil)
  }

  @Test
  func `Play and pause do nothing while the picker is open`() {
    var slideShow: SlideShow = playing(since: start)
    slideShow.expandPicker()
    slideShow.togglePlayback(now: later)

    #expect(slideShow.phase == .pickerExpanded(wasPlaying: true))
    #expect(slideShow.cycleStart == nil)
  }

  @Test
  func `Restarting while playing starts the next cycle at now`() {
    var slideShow: SlideShow = playing(since: start)
    slideShow.restartCycle(now: later)

    #expect(slideShow.isPlaying)
    #expect(slideShow.cycleStart == later)
  }

  @Test
  func `Restarting while paused or with the picker open keeps the bar empty`() {
    var paused: SlideShow = .init()
    paused.restartCycle(now: later)
    var expanded: SlideShow = playing(since: start)
    expanded.expandPicker()
    expanded.restartCycle(now: later)

    #expect(paused == SlideShow())
    #expect(expanded.phase == .pickerExpanded(wasPlaying: true))
    #expect(expanded.cycleStart == nil)
  }
}
