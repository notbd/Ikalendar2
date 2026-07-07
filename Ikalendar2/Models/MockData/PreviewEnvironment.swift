//
//  PreviewEnvironment.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

#if DEBUG

import SwiftUI

// MARK: - PreviewNetworkService

/// Serves IkaMockData over the IkaNetworkService interface so previews (and the
/// preview catalog) can "load" realistic rotations without touching the network.
/// A short artificial latency keeps loading states visible when exercising refresh.
struct PreviewNetworkService: IkaNetworkService {
  var latency: Duration = .milliseconds(300)

  func getBattleRotationDict() async throws -> BattleRotationDict {
    try? await Task.sleep(for: latency)
    return IkaMockData.getBattleRotations()
  }

  func getSalmonRotations() async throws -> [SalmonRotation] {
    try? await Task.sleep(for: latency)
    return IkaMockData.getSalmonRotations()
  }

  func getSalmonRewardApparelInfo() async throws -> SalmonApparelInfo {
    try? await Task.sleep(for: latency)
    // availableTime deliberately matches no mock rotation: apparel attachment is
    // already covered by unit tests, and previews render the general case.
    return SalmonApparelInfo(apparel: .head(.oceanicHardHat), availableTime: .distantPast)
  }

  func fetchLicense(from _: String) async throws -> IkaOpenSourceLicense {
    try? await Task.sleep(for: latency)
    return IkaOpenSourceLicense(
      repoURL: "https://github.com/notbd/SimpleHaptics",
      type: "MIT",
      typeDescription: "MIT License",
      content: Constants.Key.Placeholder.licenseTemplateMit)
  }
}

// MARK: - View + ikaPreviewEnvironment

extension View {
  /// Injects the complete app environment, preloaded with mock data - the preview
  /// counterpart of the App composition root.
  ///
  /// Every view that reads `@Environment(SomeStore.self)` crashes the preview host
  /// unless that store is injected; apply this to any preview whose view hierarchy
  /// can reach one. Preferences use a throwaway UserDefaults suite so previews
  /// never pollute the real app's stored settings.
  @MainActor
  func ikaPreviewEnvironment() -> some View {
    let previewDefaults = UserDefaults(suiteName: "ikalendar2-preview") ?? .standard
    let ikaPreference: IkaPreference = .init(userDefaults: previewDefaults)
    let ikaDiscoveryLog: IkaDiscoveryLog = .init(userDefaults: previewDefaults)
    // Onboarding is previewed directly via OnboardingView - keep it out of the way here.
    ikaDiscoveryLog.shouldShowOnboarding = false

    let ikaClock: IkaClock = .init()
    let networkService: PreviewNetworkService = .init()

    return accentColor(.orange)
      .environment(IkaCatalog.preview(ikaNetworkService: networkService, ikaClock: ikaClock))
      .environment(IkaStatus(ikaPreference: ikaPreference))
      .environment(ikaClock)
      .environment(IkaDeviceMotionMonitor())
      .environment(IkaOrientationMonitor())
      .environment(ikaPreference)
      .environment(ikaDiscoveryLog)
      .environment(IkaConnectivityChecker())
      .environment(\.ikaNetworkService, networkService)
  }
}

#endif
