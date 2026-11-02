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

    log.reset()

    #expect(!log.shouldShowOnboarding)
    #expect(!log.hasDiscoveredRating)
    #expect(!log.hasDiscoveredAltAppIcon)
    #expect(!log.hasDiscoveredEasterEgg)
  }

  @Test
  func `Reset can also restore onboarding`() throws {
    let log = try IkaDiscoveryLog(userDefaults: makeTestDefaults())
    log.shouldShowOnboarding = false

    log.reset(includingOnboarding: true)

    #expect(log.shouldShowOnboarding)
  }

  // MARK: - On-disk format (golden)

  // Keys are spelled out as literals on purpose: renaming a key constant would re-show
  // onboarding and forget every discovery for upgrading users, so it must fail here.
  // Never rewrite these literals in terms of `Constants.Key`.

  @Test
  func `Pre-seeded on-disk values load under the frozen keys`() throws {
    let defaults = try makeTestDefaults()
    // Onboarding defaults to true, so only an explicit stored false proves the key is read.
    defaults.set(false, forKey: "pref.if_should_show_onboarding")
    defaults.set(true, forKey: "pref.if_has_discovered_rating")
    defaults.set(true, forKey: "pref.if_has_discovered_alt_app_icon")
    defaults.set(true, forKey: "pref.if_has_discovered_easter_egg")

    let log: IkaDiscoveryLog = .init(userDefaults: defaults)

    #expect(!log.shouldShowOnboarding)
    #expect(log.hasDiscoveredRating)
    #expect(log.hasDiscoveredAltAppIcon)
    #expect(log.hasDiscoveredEasterEgg)
  }

  @Test
  func `Writes store Bool values under the frozen keys`() throws {
    let defaults = try makeTestDefaults()
    let log: IkaDiscoveryLog = .init(userDefaults: defaults)

    log.shouldShowOnboarding = false
    log.hasDiscoveredRating = true
    log.hasDiscoveredAltAppIcon = true
    log.hasDiscoveredEasterEgg = true

    #expect(defaults.object(forKey: "pref.if_should_show_onboarding") as? Bool == false)
    #expect(defaults.object(forKey: "pref.if_has_discovered_rating") as? Bool == true)
    #expect(defaults.object(forKey: "pref.if_has_discovered_alt_app_icon") as? Bool == true)
    #expect(defaults.object(forKey: "pref.if_has_discovered_easter_egg") as? Bool == true)

    log.reset(includingOnboarding: true)

    #expect(defaults.object(forKey: "pref.if_should_show_onboarding") as? Bool == true)
    #expect(defaults.object(forKey: "pref.if_has_discovered_rating") as? Bool == false)
    #expect(defaults.object(forKey: "pref.if_has_discovered_alt_app_icon") as? Bool == false)
    #expect(defaults.object(forKey: "pref.if_has_discovered_easter_egg") as? Bool == false)
  }
}
