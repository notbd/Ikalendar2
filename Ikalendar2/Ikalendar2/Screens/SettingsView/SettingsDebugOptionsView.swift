//
//  SettingsDebugOptionsView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

struct SettingsDebugOptionsView: View {
  @Environment(IkaStatus.self) private var ikaStatus

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher
  @EnvironmentObject private var ikaLog: IkaLog
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var pulsingTrigger: Int = 0

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
      SimpleHaptics.generateTask(.heavy)
    } label: {
      Text("Show Onboarding Screen")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAppStates: some View {
    Button {
      ikaLog.resetStates()
      ikaPreference.resetAppIcon()
      SimpleHaptics.generateTask(.success)
    } label: {
      Text("Reset App States")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var rowResetAppPreferences: some View {
    Button {
      ikaPreference.resetPreferences()
      SimpleHaptics.generateTask(.success)
    } label: {
      Text("Reset App Preferences")
        .foregroundStyle(Color.accentColor)
    }
  }

  private var warningBanner: some View {
    let warningIcon = Image(systemName: "exclamationmark.triangle.fill")

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
          .foregroundStyle(value ? Color.red : Color.secondaryLabel)
      } animation: { _ in
        .spring(duration: 2.0)
      }
      .onReceive(ikaTimePublisher.bounceSignalPublisher) {
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
