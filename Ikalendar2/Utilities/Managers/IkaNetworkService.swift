//
//  IkaNetworkService.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - IkaNetworkService

/// Abstraction over the networking layer, enabling mock injection in tests.
protocol IkaNetworkService: Sendable {
  func fetchLicense(from githubRepoURLString: String) async throws -> IkaOpenSourceLicense
  func fetchBattleRotationDict() async throws -> BattleRotationDict
  func fetchSalmonRotations() async throws -> [SalmonRotation]
  func fetchSalmonRewardApparelInfo() async throws -> SalmonApparelInfo
}

extension EnvironmentValues {
  /// The app-wide networking service. Overridden at the App root; default suits previews.
  @Entry var ikaNetworkService: any IkaNetworkService = IkaNetworkManager()
}
