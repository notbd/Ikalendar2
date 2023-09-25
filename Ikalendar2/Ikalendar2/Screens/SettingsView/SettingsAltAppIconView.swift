//
//  SettingsAltAppIconView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
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

  @State private var rect: CGRect = .init()
  @State private var easterEggBounceCounter: Int = 0

  @State private var tapCount: Int = 0 // temp

  @State private var displayAnimatedCopy: Bool = false
  @State private var currentFlipAfterDelayTask: Task<Void, Never>?

  private var showEasterEgg: Bool {
    doesPreferRickOnAppear || triggeredEasterEgg
  }

  var body: some View {
    ZStack {
      List {
        if showEasterEgg {
          Section(header: Text("Never Gonna Give You Up")) {
            AltAppIconEasterEggRow(ikaAppIcon: .rick, buttonPressCounter: $easterEggBounceCounter)
              .opacity(displayAnimatedCopy ? 0 : 1)
              .background {
                GeometryReader { geo in
                  Color.clear
                    .onChange(of: geo.frame(in: .global), initial: true) { _, newValue in
                      rect = newValue
                    }
                }
              }
          }
        }

        Section {
          ForEach(IkaAppIcon.allCases.filter { !$0.isEasterEgg }) { ikaAppIcon in
            AltAppIconRow(ikaAppIcon: ikaAppIcon)
          }
        } header: {
          if showEasterEgg { EmptyView() } else { Spacer() }
        }
      }
      .toolbar {
        Button("Tap Me :)") {
          SimpleHaptics.generateTask(triggeredEasterEgg ? .soft : .success)
          withAnimation(.bouncy) {
            triggeredEasterEgg.toggle()
          }
        }
        .foregroundStyle(
          Color.accentColor
            .opacity(
              ikaLog.hasDiscoveredEasterEgg
                ? 0
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

      // Overlay view
      if showEasterEgg {
        AltAppIconEasterEggRow(ikaAppIcon: .rick, buttonPressCounter: $easterEggBounceCounter)
          .allowsHitTesting(false)
          .frame(width: rect.width, height: rect.height)
          .globalPosition(x: rect.midX, y: rect.midY)
          .opacity(displayAnimatedCopy ? 1 : 0)
      }
    }
    .onAppear {
      doesPreferRickOnAppear = ikaPreference.preferredAppIcon == .rick
    }
    .onChange(of: easterEggBounceCounter) {
      displayAnimatedCopy = true

      // Cancel the previous task, if it exists
      currentFlipAfterDelayTask?.cancel()

      // Schedule a new task
      currentFlipAfterDelayTask =
        Task {
          await flipDisplayAnimatedCopyAfterDelay()
        }
    }
  }

  // MARK: Private

  private func flipDisplayAnimatedCopyAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(2.1 * 1_000_000_000))
    guard !Task.isCancelled else { return }
    displayAnimatedCopy = false
  }

  private func checkForEasterEgg() {
    tapCount += 1
    if tapCount >= 1 {
      withAnimation(.bouncy) {
        triggeredEasterEgg = true
      }
    }
  }
}

// MARK: - SettingsAppIconView_Previews

struct SettingsAppIconView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAltAppIconView()
  }
}
