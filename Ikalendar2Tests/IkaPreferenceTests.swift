//
//  IkaPreferenceTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaPreferenceTests

/// Every test builds its own IkaPreference on a fresh UserDefaults suite, so the
/// suite is parallel-safe. Haptics are no-ops on simulator; `preferredAppIcon` is
/// only exercised in the dedicated persistence test (its didSet calls
/// UIApplication.setAlternateIconName, harmless but noisy on simulator).
@MainActor
@Suite("IkaPreference")
struct IkaPreferenceTests {
  // MARK: - Defaults

  @Test
  func `Fresh defaults produce the documented initial values`() throws {
    let preference = try IkaPreference(userDefaults: makeTestDefaults())

    #expect(preference.preferredDefaultFlatMode == .regular)
    #expect(preference.preferredDefaultGameMode == .battle)
    #expect(preference.preferredDefaultBattleMode == .regular)
    #expect(preference.preferredAppColorScheme == .dark)
    #expect(preference.preferredAppIcon == .default)
    #expect(!preference.shouldMinimizeTabBar)
    #expect(!preference.shouldSwapBottomToolbarPickers)
    #expect(!preference.shouldUseAltStageImages)
  }

  // MARK: - Tri-mode sync

  @Test(arguments: FlatMode.allCases)
  func `Setting flat mode syncs game and battle modes`(flatMode: FlatMode) throws {
    let preference = try IkaPreference(userDefaults: makeTestDefaults())
    let battleModeBefore = preference.preferredDefaultBattleMode

    preference.preferredDefaultFlatMode = flatMode

    switch flatMode {
      case .regular:
        #expect(preference.preferredDefaultGameMode == .battle)
        #expect(preference.preferredDefaultBattleMode == .regular)

      case .gachi:
        #expect(preference.preferredDefaultGameMode == .battle)
        #expect(preference.preferredDefaultBattleMode == .gachi)

      case .league:
        #expect(preference.preferredDefaultGameMode == .battle)
        #expect(preference.preferredDefaultBattleMode == .league)

      case .salmon:
        #expect(preference.preferredDefaultGameMode == .salmon)
        // Documented semantics: switching to salmon leaves battle mode untouched.
        #expect(preference.preferredDefaultBattleMode == battleModeBefore)
    }
  }

  @Test
  func `Setting game mode rebuilds flat mode from battle mode`() throws {
    let preference = try IkaPreference(userDefaults: makeTestDefaults())

    preference.preferredDefaultBattleMode = .league
    preference.preferredDefaultGameMode = .salmon
    #expect(preference.preferredDefaultFlatMode == .salmon)

    preference.preferredDefaultGameMode = .battle
    #expect(preference.preferredDefaultFlatMode == .league)
  }

  @Test(arguments: BattleMode.allCases)
  func `Setting battle mode follows through to flat mode`(battleMode: BattleMode) throws {
    let preference = try IkaPreference(userDefaults: makeTestDefaults())
    preference.preferredDefaultFlatMode = .salmon // move away so every assignment is a change
    preference.preferredDefaultGameMode = .battle

    preference.preferredDefaultBattleMode = battleMode
    #expect(preference.preferredDefaultFlatMode.rawValue == battleMode.rawValue)
    #expect(preference.preferredDefaultGameMode == .battle)
  }

  // MARK: - Persistence

  @Test
  func `Values persist across instances sharing a suite`() throws {
    let defaults = try makeTestDefaults()

    let first: IkaPreference = .init(userDefaults: defaults)
    first.preferredDefaultFlatMode = .salmon
    first.preferredAppColorScheme = .light
    first.shouldUseAltStageImages = true

    let second: IkaPreference = .init(userDefaults: defaults)
    #expect(second.preferredDefaultFlatMode == .salmon)
    #expect(second.preferredDefaultGameMode == .salmon)
    #expect(second.preferredAppColorScheme == .light)
    #expect(second.shouldUseAltStageImages)
  }

  @Test
  func `Synced side-effect assignments are persisted too`() throws {
    // Regression guard for the isSyncing trap: when setting flatMode cascades into
    // gameMode/battleMode, those synced writes must still reach UserDefaults.
    let defaults = try makeTestDefaults()

    let first: IkaPreference = .init(userDefaults: defaults)
    first.preferredDefaultFlatMode = .league

    let second: IkaPreference = .init(userDefaults: defaults)
    #expect(second.preferredDefaultBattleMode == .league)
    #expect(second.preferredDefaultGameMode == .battle)
  }

  @Test
  func `App icon choice persists`() throws {
    let defaults = try makeTestDefaults()

    IkaPreference(userDefaults: defaults).preferredAppIcon = .rick
    #expect(IkaPreference(userDefaults: defaults).preferredAppIcon == .rick)
  }

  // MARK: - Reset & termination

  @Test
  func `Reset restores every default`() throws {
    let preference = try IkaPreference(userDefaults: makeTestDefaults())
    preference.preferredDefaultFlatMode = .salmon
    preference.preferredAppColorScheme = .system
    preference.shouldMinimizeTabBar = true
    preference.shouldSwapBottomToolbarPickers = true
    preference.shouldUseAltStageImages = true

    preference.resetPreferences()

    #expect(preference.preferredDefaultFlatMode == .default)
    #expect(preference.preferredDefaultGameMode == .default)
    #expect(preference.preferredDefaultBattleMode == .default)
    #expect(preference.preferredAppColorScheme == .default)
    #expect(preference.preferredAppIcon == .default)
    #expect(!preference.shouldMinimizeTabBar)
    #expect(!preference.shouldSwapBottomToolbarPickers)
    #expect(!preference.shouldUseAltStageImages)
  }

  @Test
  func `Repeated and cascading assignments terminate without recursion`() throws {
    // Completing at all proves the isSyncing flag prevents infinite willSet recursion.
    let preference = try IkaPreference(userDefaults: makeTestDefaults())

    preference.preferredDefaultFlatMode = .gachi
    preference.preferredDefaultFlatMode = .gachi // same-value assignment is a no-op
    preference.preferredDefaultGameMode = .salmon
    preference.preferredDefaultBattleMode = .regular

    // Documents existing semantics: setting battleMode only rebuilds flatMode; the
    // isSyncing guard stops the cascade before gameMode. gameMode therefore stays
    // .salmon here. UI cannot reach this state (the battle picker is disabled
    // whenever gameMode != .battle) - this pin exists so any future change to the
    // sync topology is a conscious one.
    #expect(preference.preferredDefaultFlatMode == .regular)
    #expect(preference.preferredDefaultGameMode == .salmon)
    #expect(preference.preferredDefaultBattleMode == .regular)
  }

  @Test
  func `Easter egg icon reverts only when active`() throws {
    let preference = try IkaPreference(userDefaults: makeTestDefaults())

    preference.revertEasterEggAppIcon()
    #expect(preference.preferredAppIcon == .default)

    preference.preferredAppIcon = .rick
    preference.revertEasterEggAppIcon()
    #expect(preference.preferredAppIcon == .default)
  }
}
