//
//  SettingsDebugOptionsView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import AlertKit
import Combine
import SimpleHaptics
import SwiftUI

/// The Settings page for debug actions: replay onboarding, reset states and preferences.
struct SettingsDebugOptionsView: View {
  @Environment(IkaStatus.self) private var ikaStatus

  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog
  @Environment(IkaPreference.self) private var ikaPreference

  @Environment(IkaConnectivityChecker.self) private var connectivityChecker

  @ScaledMetric(relativeTo: .title) private var squidBumperHeight: CGFloat = 50

  var body: some View {
    List {
      Section {
        rowSquidBumper
      }
      .listRowInsets(.init(.zero))
      .listRowBackground(Color.clear)

      Section {
        rowShowOnboarding
      }

      Section {
        rowResetAppStates
        rowResetAppPreferences
        rowResetAll
      }
    }
    .listStyle(.insetGrouped)
    .safeAreaBar(edge: .bottom) {
      warningBanner
        .padding()
    }
  }

  private var rowSquidBumper: some View {
    Image(.squidBumperMemCake)
      .ikaFitted()
      .frame(height: squidBumperHeight)
      .hAlignment(.leading)
      .accessibilityHidden(true)
  }

  private var rowShowOnboarding: some View {
    Button {
      ikaStatus.isSettingsPresented = false
      ikaDiscoveryLog.shouldShowOnboarding = true
      SimpleHaptics.generateTask(.selection)
    } label: {
      Text("Show Onboarding Screen")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAppStates: some View {
    Button {
      connectivityChecker.reset()
      ikaPreference.revertEasterEggAppIcon()
      ikaStatus.reset(dismissingSettings: false)
      ikaDiscoveryLog.reset(includingOnboarding: false)
      presentResetDoneAlert(titled: String(localized: "States Reset"))
    } label: {
      Text("Reset App States")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAppPreferences: some View {
    Button {
      ikaPreference.reset()
      presentResetDoneAlert(titled: String(localized: "Preferences Reset"))
    } label: {
      Text("Reset App Preferences")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAll: some View {
    Button {
      connectivityChecker.reset()
      ikaPreference.reset()
      ikaStatus.reset(dismissingSettings: true)
      ikaDiscoveryLog.reset(includingOnboarding: true)
      presentResetDoneAlert(titled: String(localized: "All Reset"))
    } label: {
      Text("Reset All")
        .foregroundStyle(Color.accentColor)
    }
  }

  /// The shared confirmation toast for the reset rows above.
  private func presentResetDoneAlert(titled title: String) {
    AlertKitAPI.present(
      title: title,
      icon: .done,
      style: .iOS17AppleMusic,
      haptic: .success)
  }

  @State private var pulsingTrigger: Int = 0
  /// View-local timer on purpose: hoisting the pulse/nudge timers into shared state made
  /// unrelated views pulse together (a5bfe35, fixed in 20a3489). Do not lift it.
  private var pulseTimer = Timer
    .publish(
      every: Constants.Config.Timer.pulseSignalInterval,
      tolerance: 0.1,
      on: .main,
      in: .common)
    .autoconnect()

  private var warningBanner: some View {
    let warningIcon: Image = .init(systemName: "exclamationmark.triangle.fill")
    let warningMessage: LocalizedStringKey = "Warning: Proceed with Caution"
    let warningText: Text = .init(warningMessage)

    let bannerText =
      HStack {
        warningIcon
        warningText
      }
      .font(.system(.body, design: .rounded, weight: .semibold))
      .phaseAnimator([false, true], trigger: pulsingTrigger)
      { content, value in
        content
          .foregroundStyle(value ? Color.red : Color.secondary)
      } animation: { _ in
        .spring(duration: 1.2)
      }
      .onAppear {
        pulsingTrigger += 1
      }
      .onReceive(pulseTimer) { _ in
        pulsingTrigger += 1
      }

    return
      bannerText
        .padding()
        .padding(.horizontal)
        .glassEffect(.regular.interactive())
  }
}

#Preview {
  NavigationStack {
    SettingsDebugOptionsView()
  }
  .ikaPreviewEnvironment()
}
