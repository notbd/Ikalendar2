//
//  TestHelpers.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing

@testable import Ikalendar2

/// Creates a fresh, isolated UserDefaults suite for one test.
/// Unique suite names keep parallel tests from sharing state; the simulator
/// container is ephemeral so no cleanup is needed. Never touch `.standard` in tests.
func makeTestDefaults() throws -> UserDefaults {
  try #require(UserDefaults(suiteName: "ikalendar2-tests-\(UUID().uuidString)"))
}
