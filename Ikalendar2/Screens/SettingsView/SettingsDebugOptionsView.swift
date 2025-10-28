//
//  SettingsDebugOptionsView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import AlertKit
import SimpleHaptics
import SwiftUI

struct SettingsDebugOptionsView: View {
  @Environment(IkaStatus.self) private var ikaStatus

  @EnvironmentObject private var ikaLog: IkaLog
  @EnvironmentObject private var ikaPreference: IkaPreference

  @ScaledMetric(relativeTo: .title) var squidBumperHeight: CGFloat = 50

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
    .safeAreaInset(edge: .bottom) {
      warningBanner
        .padding()
        .background(.ultraThinMaterial)
    }
  }

  private var rowSquidBumper: some View {
    Image(.squidBumperMemCake)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .frame(height: squidBumperHeight)
      .hAlignment(.leading)
  }

  private var rowShowOnboarding: some View {
    Button {
      ikaStatus.isSettingsPresented = false
      ikaLog.shouldShowOnboarding = true
      SimpleHaptics.generateTask(.selection)
    } label: {
      Text("Show Onboarding Screen")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAppStates: some View {
    Button {
      ikaPreference.revertEasterEggAppIcon()
      ikaStatus.resetStatuses(shouldExitSettings: false)
      ikaLog.resetStates(shouldResetOnboarding: false)
      AlertKitAPI.present(
        title: String(localized: "States Reset"),
        icon: .done,
        style: .iOS17AppleMusic,
        haptic: .success)
    } label: {
      Text("Reset App States")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAppPreferences: some View {
    Button {
      ikaPreference.resetPreferences()
      AlertKitAPI.present(
        title: String(localized: "Preferences Reset"),
        icon: .done,
        style: .iOS17AppleMusic,
        haptic: .success)
    } label: {
      Text("Reset App Preferences")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAll: some View {
    Button {
      ikaPreference.resetPreferences()
      ikaStatus.resetStatuses(shouldExitSettings: true)
      ikaLog.resetStates(shouldResetOnboarding: true)
      AlertKitAPI.present(
        title: String(localized: "All Reset"),
        icon: .done,
        style: .iOS17AppleMusic,
        haptic: .success)
    } label: {
      Text("Reset All")
        .foregroundStyle(Color.accentColor)
    }
  }

  @State private var pulsingTrigger: Int = 0
  private var pulseTimer = Timer
    .publish(
      every: Constants.Config.Timer.pulseSignalInterval,
      tolerance: 0.1,
      on: .main,
      in: .common)
    .autoconnect()

  private var warningBanner: some View {
    let warningIcon: Image = .init(systemName: "exclamationmark.triangle.fill")

    let bannerText =
      HStack {
        warningIcon
        Text("Warning: Proceed with Caution")
      }
      .font(.system(.body, design: .rounded, weight: .semibold))
      .scaledLimitedLine()
      .phaseAnimator([false, true], trigger: pulsingTrigger)
      { content, value in
        content
          .foregroundStyle(!value ? Color.secondaryLabel : Color.red)
      } animation: { _ in
        .spring(duration: 1.2)
      }
      .onReceive(pulseTimer) { _ in
        pulsingTrigger += 1
      }

    let bannerContent =
      bannerText
        .padding()
        .hAlignment(.center)

    return
      ZStack {
        bannerContent

        bannerContent
          .background(.ultraThinMaterial)
          .clipShape(.rect(cornerRadius: 10, style: .continuous))
      }
  }
}
