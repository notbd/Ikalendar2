//
//  SettingsAltAppIconView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsAltAppIconView

/// The Settings page for switching alternate App Icons.
@MainActor
struct SettingsAltAppIconView: View {
  @Environment(\.colorScheme) private var colorScheme

  @EnvironmentObject private var ikaPreference: IkaPreference
  @EnvironmentObject private var ikaLog: IkaLog

  @State private var doesPreferRickOnAppear: Bool = false
  @State private var triggeredEasterEgg: Bool = false
  private var showEasterEgg: Bool { doesPreferRickOnAppear || triggeredEasterEgg }

  @State private var easterEggCellRectGlobal: CGRect = .init()
  @State private var easterEggBounceCounter: Int = 0

  @State private var shouldDisplayAnimatedCopy: Bool = false
  @State private var currentToggleAfterDelayTask: Task<Void, Never>?

  var body: some View {
    ZStack {
      List {
        if showEasterEgg {
          Section {
            AltAppIconEasterEggRow(ikaAppIcon: .rick, buttonPressCounter: $easterEggBounceCounter)
              .opacity(shouldDisplayAnimatedCopy ? 0 : 1)
              .background {
                GeometryReader { geo in
                  Color.clear
                    .onChange(of: geo.frame(in: .global), initial: true) { _, newValue in
                      easterEggCellRectGlobal = newValue
                    }
                }
              }
          } header: { Text("Never Gonna Give You Up") }
        }

        Section {
          ForEach(IkaAppIcon.allCases.filter { !$0.isEasterEgg }) { ikaAppIcon in
            AltAppIconRow(ikaAppIcon: ikaAppIcon)
          }
        } header: { if showEasterEgg { EmptyView() } else { Spacer() } }
      }
      .toolbar {
        Button {
          if !doesPreferRickOnAppear { SimpleHaptics.generateTask(.soft) }
          withAnimation { triggeredEasterEgg.toggle() }
        }
        label: {
          if ikaLog.hasDiscoveredEasterEgg {
            Image(systemName: showEasterEgg ? "party.popper.fill" : "party.popper")
              .transition(.symbolEffect(.automatic))
          }
          else {
            Text("Tap Me :)")
          }
        }
        .foregroundStyle(
          Color.accentColor
            .opacity(
              ikaLog.hasDiscoveredEasterEgg
                ? 1
                : colorScheme == .dark
                  ? 0.07
                  : 0.05))
      }
      .navigationTitle("App Icon")
      .navigationBarTitleDisplayMode(.large)
      .listStyle(.insetGrouped)
      .onAppear {
        if !ikaLog.hasDiscoveredAltAppIcon { ikaLog.hasDiscoveredAltAppIcon = true }
      }

      // Animated copy
      if showEasterEgg {
        AltAppIconEasterEggRow(ikaAppIcon: .rick, buttonPressCounter: $easterEggBounceCounter)
          .allowsHitTesting(false)
          .frame(width: easterEggCellRectGlobal.width, height: easterEggCellRectGlobal.height)
          .globalPosition(x: easterEggCellRectGlobal.midX, y: easterEggCellRectGlobal.midY)
          .opacity(shouldDisplayAnimatedCopy ? 1 : 0)
      }
    }
    .onAppear {
      doesPreferRickOnAppear = ikaPreference.preferredAppIcon == .rick
    }
    .onChange(of: easterEggBounceCounter) {
      shouldDisplayAnimatedCopy = true
      // Cancel the previous task, if it exists
      currentToggleAfterDelayTask?.cancel()
      // Schedule a new task
      currentToggleAfterDelayTask = Task { await toggleShouldDisplayAnimatedCopyAfterDelay() }
    }
  }

  private func toggleShouldDisplayAnimatedCopyAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(2.1 * 1_000_000_000))
    guard !Task.isCancelled else { return }
    shouldDisplayAnimatedCopy = false
  }
}

// MARK: - SettingsAppIconView_Previews

struct SettingsAppIconView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAltAppIconView()
  }
}
