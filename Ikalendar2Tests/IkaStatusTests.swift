//
//  IkaStatusTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaStatusTests

@MainActor
@Suite("IkaStatus")
struct IkaStatusTests {
  private func makeStatus(
    flatMode: FlatMode = .default) throws
    -> (status: IkaStatus, preference: IkaPreference)
  {
    let preference = try IkaPreference(userDefaults: makeTestDefaults())
    preference.preferredDefaultFlatMode = flatMode
    return (IkaStatus(ikaPreference: preference), preference)
  }

  @Test
  func `Init pulls current values from the injected preference`() throws {
    let (status, _) = try makeStatus(flatMode: .salmon)

    #expect(status.currentFlatMode == .salmon)
    #expect(status.currentGameMode == .salmon)
    #expect(!status.isSettingsPresented)
  }

  @Test(arguments: FlatMode.allCases)
  func `Setting current flat mode syncs game and battle modes`(flatMode: FlatMode) throws {
    let (status, _) = try makeStatus()
    let battleModeBefore = status.currentBattleMode

    status.currentFlatMode = flatMode

    switch flatMode {
      case .regular:
        #expect(status.currentGameMode == .battle)
        #expect(status.currentBattleMode == .regular)

      case .gachi:
        #expect(status.currentGameMode == .battle)
        #expect(status.currentBattleMode == .gachi)

      case .league:
        #expect(status.currentGameMode == .battle)
        #expect(status.currentBattleMode == .league)

      case .salmon:
        #expect(status.currentGameMode == .salmon)
        #expect(status.currentBattleMode == battleModeBefore)
    }
  }

  @Test
  func `Setting game mode rebuilds flat mode from battle mode`() throws {
    let (status, _) = try makeStatus()

    status.currentBattleMode = .league
    status.currentGameMode = .salmon
    #expect(status.currentFlatMode == .salmon)

    status.currentGameMode = .battle
    #expect(status.currentFlatMode == .league)
  }

  @Test
  func `Reset restores the preference defaults`() throws {
    let (status, preference) = try makeStatus(flatMode: .gachi)

    status.currentFlatMode = .salmon
    status.isSettingsPresented = true
    #expect(status.currentFlatMode != preference.preferredDefaultFlatMode)

    status.resetStatuses()

    #expect(status.currentFlatMode == .gachi)
    #expect(status.currentGameMode == .battle)
    #expect(status.currentBattleMode == .gachi)
    #expect(status.isSettingsPresented) // default arg leaves the settings sheet alone
  }

  @Test
  func `Reset can also dismiss settings`() throws {
    let (status, _) = try makeStatus()
    status.isSettingsPresented = true

    status.resetStatuses(shouldExitSettings: true)

    #expect(!status.isSettingsPresented)
  }
}
