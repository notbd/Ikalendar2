//
//  IkaDiscoveryLogTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaDiscoveryLogTests

@MainActor
@Suite("IkaDiscoveryLog")
struct IkaDiscoveryLogTests {
  @Test
  func `Fresh install shows onboarding and no discoveries`() throws {
    let log = try IkaDiscoveryLog(userDefaults: makeTestDefaults())

    // shouldShowOnboarding defaults to TRUE - reading it via bool(forKey:) (which
    // returns false for missing keys) would silently kill first-launch onboarding.
    #expect(log.shouldShowOnboarding)
    #expect(!log.hasDiscoveredRating)
    #expect(!log.hasDiscoveredAltAppIcon)
    #expect(!log.hasDiscoveredEasterEgg)
  }

  @Test
  func `Values persist across instances sharing a suite`() throws {
    let defaults = try makeTestDefaults()

    let first: IkaDiscoveryLog = .init(userDefaults: defaults)
    first.shouldShowOnboarding = false
    first.hasDiscoveredRating = true
    first.hasDiscoveredEasterEgg = true

    let second: IkaDiscoveryLog = .init(userDefaults: defaults)
    #expect(!second.shouldShowOnboarding)
    #expect(second.hasDiscoveredRating)
    #expect(!second.hasDiscoveredAltAppIcon)
    #expect(second.hasDiscoveredEasterEgg)
  }

  @Test
  func `Reset clears discoveries but keeps onboarding by default`() throws {
    let log = try IkaDiscoveryLog(userDefaults: makeTestDefaults())
    log.shouldShowOnboarding = false
    log.hasDiscoveredRating = true
    log.hasDiscoveredAltAppIcon = true
    log.hasDiscoveredEasterEgg = true

    log.resetStates()

    #expect(!log.shouldShowOnboarding)
    #expect(!log.hasDiscoveredRating)
    #expect(!log.hasDiscoveredAltAppIcon)
    #expect(!log.hasDiscoveredEasterEgg)
  }

  @Test
  func `Reset can also restore onboarding`() throws {
    let log = try IkaDiscoveryLog(userDefaults: makeTestDefaults())
    log.shouldShowOnboarding = false

    log.resetStates(shouldResetOnboarding: true)

    #expect(log.shouldShowOnboarding)
  }
}
