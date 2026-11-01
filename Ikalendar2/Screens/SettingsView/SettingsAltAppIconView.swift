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
struct SettingsAltAppIconView: View {
  typealias ScopedStyle = Constants.Style.Settings.AltAppIcon

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.openURL) private var openURL

  @Environment(IkaPreference.self) private var ikaPreference
  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog

  @Environment(IkaConnectivityChecker.self) private var connectivityChecker

  @State private var wasRickPreferredOnAppear: Bool = false
  @State private var triggeredEasterEgg: Bool = false
  /// The Rick section shows when Rick was already the chosen icon on entry, or after the hidden
  /// trigger button is tapped; when Rick was the icon on entry the button cannot hide it again.
  private var showEasterEgg: Bool { wasRickPreferredOnAppear || triggeredEasterEgg }

  @State private var easterEggCellRectGlobal: CGRect = .init()
  @State private var easterEggBounceCounter: Int = 0
  @State private var easterEggJumpRequestCounter: Int = 0
  /// The last jump request acted on, so showing the easter-egg section again does not replay it.
  @State private var handledEasterEggJumpRequest: Int = 0

  /// Restarts the jump task on a new request or when the easter-egg section shows or hides.
  private struct JumpKey: Equatable {
    let request: Int
    let isEasterEggShown: Bool
  }

  @State private var shouldDisplayAnimatedCopy: Bool = false

  @State private var activeAppIconColorVariant: IkaAppIcon.ColorVariant = .default

  @State private var slideShow: SlideShow = .init()

  var body: some View {
    ZStack {
      List {
        if showEasterEgg {
          Section {
            AltAppIconEasterEggRow(
              ikaAppIcon: .rick,
              appIconColorVariant: $activeAppIconColorVariant,
              buttonPressCounter: $easterEggBounceCounter,
              jumpRequestCounter: $easterEggJumpRequestCounter)
              .opacity(shouldDisplayAnimatedCopy ? 0 : 1)
              .onGeometryChange(for: CGRect.self) { geo in
                geo.frame(in: .global)
              } action: { newValue in
                easterEggCellRectGlobal = newValue
              }
          } header: { Text("Never Gonna Give You Up") }
        }

        Section {
          ForEach(IkaAppIcon.allCases.filter { !$0.isEasterEgg }) { ikaAppIcon in
            AltAppIconRow(
              ikaAppIcon: ikaAppIcon,
              appIconColorVariant: $activeAppIconColorVariant)
          }
        } header: { if showEasterEgg { EmptyView() } else { Spacer() } }
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          easterEggTrigger
        }
        .sharedBackgroundVisibility(.hidden)
      }
      .navigationTitle("App Icon")
      .navigationBarTitleDisplayMode(.large)
      .listStyle(.insetGrouped)
      .onAppear {
        if !ikaDiscoveryLog.hasDiscoveredAltAppIcon { ikaDiscoveryLog.hasDiscoveredAltAppIcon = true }
        slideShow.play(now: .now)
      }
      // One task per cycle: sleeps to the cycle's end, then advances the variant and starts the
      // next cycle, which restarts this task. Pause, picker expansion and Next change or clear
      // `cycleStart`, so a pending switch never fires for a stale cycle. Zero tolerance: the
      // default leeway (a tenth of the sleep) let the full bar sit for up to 0.4 s.
      .task(id: slideShow.cycleStart) {
        guard let cycle = slideShow.cycle else { return }

        try? await Task.sleep(for: .seconds(max(0, cycle.upperBound.timeIntervalSinceNow)), tolerance: .zero)
        guard !Task.isCancelled else { return }

        withAnimation(.bouncy) {
          activeAppIconColorVariant = activeAppIconColorVariant.next
          slideShow.restartCycle(now: .now)
        }
      }

      // Animated copy
      if showEasterEgg {
        AltAppIconEasterEggRow(
          ikaAppIcon: .rick,
          appIconColorVariant: $activeAppIconColorVariant,
          buttonPressCounter: $easterEggBounceCounter,
          jumpRequestCounter: $easterEggJumpRequestCounter)
          .allowsHitTesting(false)
          .accessibilityHidden(true) // visual-only duplicate of the list row
          .frame(width: easterEggCellRectGlobal.width, height: easterEggCellRectGlobal.height)
          .globalPosition(x: easterEggCellRectGlobal.midX, y: easterEggCellRectGlobal.midY)
          .opacity(shouldDisplayAnimatedCopy ? 1 : 0)
      }

      modalDimmingLayer
    }
    .safeAreaBar(edge: .bottom) {
      SlideShowControlBar(slideShow: $slideShow, appIconColorVariant: $activeAppIconColorVariant)
        .padding()
    }
    .onAppear {
      wasRickPreferredOnAppear = ikaPreference.preferredAppIcon == .rick
      Task { await connectivityChecker.performGFWCheck() }
    }
    // The pending delayed jump, owned by the page rather than the Rick row: scrolling the row
    // off-screen must not cancel it, but leaving the page or hiding the easter-egg section does
    // (14102a7, 82d952a). A new request restarts the delay.
    .task(id: JumpKey(request: easterEggJumpRequestCounter, isEasterEggShown: showEasterEgg)) {
      guard showEasterEgg, easterEggJumpRequestCounter != handledEasterEggJumpRequest else { return }

      handledEasterEggJumpRequest = easterEggJumpRequestCounter
      await jumpToGoodStuffAfterDelay()
    }
    // While bouncing, the icon escapes its list cell's clip bounds - so hide the
    // original and overlay an unclipped copy at the same spot. Re-triggering
    // restarts the linger window.
    .task(id: easterEggBounceCounter) {
      guard easterEggBounceCounter > 0 else { return }

      shouldDisplayAnimatedCopy = true
      try? await Task.sleep(for: .seconds(Constants.Motion.easterEggCopyLinger))
      guard !Task.isCancelled else { return }

      shouldDisplayAnimatedCopy = false
    }
  }

  private var modalDimmingLayer: some View {
    Color.black
      .ignoresSafeArea()
      .opacity(!slideShow.isPickerExpanded ? 0 : ScopedStyle.modalDimmingLayerOpacity)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .onTapGesture {
        withAnimation(.bouncy) {
          slideShow.collapsePicker(now: .now)
        }
      }
  }

  private func jumpToGoodStuffAfterDelay() async {
    try? await Task.sleep(for: .seconds(Constants.Motion.easterEggJumpDelay))
    guard !Task.isCancelled else { return }

    let goodStuffURLString = connectivityChecker.isGFWed
      ? Constants.Key.URLs.theGoodStuffCN
      : Constants.Key.URLs.theGoodStuff
    guard let url = URL(string: goodStuffURLString) else { return }

    openURL(url)
  }

  private var easterEggTrigger: some View {
    Button {
      if !wasRickPreferredOnAppear { SimpleHaptics.generateTask(.soft) }
      withAnimation { triggeredEasterEgg.toggle() }
    }
    label: {
      if ikaDiscoveryLog.hasDiscoveredEasterEgg {
        Image(systemName: showEasterEgg ? "party.popper.fill" : "party.popper")
          .transition(.symbolEffect(.automatic))
      }
      else {
        Text("Tap Me :)")
      }
    }
    .foregroundStyle(Color.accentColor.opacity(easterEggTriggerOpacity))
  }

  private var easterEggTriggerOpacity: Double {
    if ikaDiscoveryLog.hasDiscoveredEasterEgg { return 1 }

    return switch (colorScheme, horizontalSizeClass) {
      case (.light, _),
           (_, .compact):
        ScopedStyle.hintOpacityCompact
      default:
        ScopedStyle.hintOpacityRegular
    }
  }
}

#Preview {
  NavigationStack {
    SettingsAltAppIconView()
  }
  .ikaPreviewEnvironment()
}
