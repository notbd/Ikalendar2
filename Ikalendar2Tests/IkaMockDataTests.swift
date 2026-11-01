//
//  IkaMockDataTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaMockDataTests

/// Mock rotations feed `ForEach` in previews, which requires unique `Identifiable` ids.
@Suite("Mock data")
struct IkaMockDataTests {
  @Test(arguments: BattleMode.allCases)
  func `Mock battle rotations have unique ids`(mode: BattleMode) throws {
    let rotations = try #require(IkaMockData.makeBattleRotations()[mode])
    #expect(!rotations.isEmpty)
    #expect(Set(rotations.map(\.id)).count == rotations.count)
  }
}
