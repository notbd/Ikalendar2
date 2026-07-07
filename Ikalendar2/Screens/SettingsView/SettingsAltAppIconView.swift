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
  typealias ScopedConfig = Constants.Config.Settings.AltAppIcon
  typealias ScopedStyle = Constants.Style.Settings.AltAppIcon

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @Environment(IkaPreference.self) private var ikaPreference
  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog

  @Environment(IkaConnectivityChecker.self) var connectivityChecker

  @State private var doesPreferRickOnAppear: Bool = false
  @State private var triggeredEasterEgg: Bool = false
  private var showEasterEgg: Bool { doesPreferRickOnAppear || triggeredEasterEgg }

  @State private var easterEggCellRectGlobal: CGRect = .init()
  @State private var easterEggBounceCounter: Int = 0

  @State private var shouldDisplayAnimatedCopy: Bool = false
  @State private var currentToggleAfterDelayTask: Task<Void, Never>?

  @State private var activeAppIconColorVariant: IkaAppIcon.ColorVariant = .default
  var activeAppIconDisplayMode: IkaAppIcon.DisplayMode {
    .init(color: activeAppIconColorVariant, size: .small)
  }

  // MARK: Slide Show State Machine

  /// The slideshow's exhaustive set of states. Modeling the picker-expanded case
  /// with its resume intent keeps every pause/resume rule in one place - the old
  /// four-flag version resumed on dimming-layer taps but silently stayed paused
  /// when a variant was picked, and left stale resume flags behind.
  private enum SlideShowPhase: Equatable {
    case playing
    case paused
    /// Variant picker is open; playback resumes on collapse iff it was playing before.
    case pickerExpanded(wasPlaying: Bool)

    var isPlaying: Bool { self == .playing }

    var isPickerExpanded: Bool {
      if case .pickerExpanded = self { return true }
      return false
    }
  }

  @State private var slideShowPhase: SlideShowPhase = .paused
  @State private var slideShowProgress: Int = 0

  private var slideShowStepCount: Int {
    Int(floor(ScopedConfig.slideShowInterval / ScopedConfig.slideShowIntervalStepLength))
  }

  // MARK: Slide Show Transitions

  /// Play/pause button. Pausing resets progress (a fresh cycle starts on resume).
  private func togglePlayback() {
    switch slideShowPhase {
      case .playing:
        slideShowPhase = .paused
        slideShowProgress = 0

      case .paused:
        slideShowPhase = .playing

      case .pickerExpanded:
        break // the control is hit-disabled while the picker is open
    }
  }

  /// Opens the variant picker, remembering whether to resume on collapse.
  private func expandPicker() {
    slideShowPhase = .pickerExpanded(wasPlaying: slideShowPhase.isPlaying)
    slideShowProgress = 0
  }

  /// Collapses the picker (dimming-layer tap or variant selection), restoring playback.
  private func collapsePicker() {
    if case .pickerExpanded(let wasPlaying) = slideShowPhase {
      slideShowPhase = wasPlaying ? .playing : .paused
    }
  }

  var body: some View {
    ZStack {
      List {
        if showEasterEgg {
          Section {
            AltAppIconEasterEggRow(
              ikaAppIcon: .rick,
              appIconColorVariant: $activeAppIconColorVariant,
              buttonPressCounter: $easterEggBounceCounter)
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
        slideShowPhase = .playing
      }
      // Step ticker: runs only while playing, cancels itself on pause/expand/disappear.
      .task(id: slideShowPhase.isPlaying) {
        guard slideShowPhase.isPlaying else { return }

        while !Task.isCancelled {
          try? await Task.sleep(
            for: .seconds(ScopedConfig.slideShowIntervalStepLength),
            tolerance: .seconds(ScopedConfig.slideShowIntervalStepLength / 10))
          guard !Task.isCancelled else { return }

          withAnimation(.snappy) {
            slideShowProgress = (slideShowProgress + 1) % slideShowStepCount
          }
        }
      }
      .onChange(of: slideShowProgress) { oldVal, _ in
        // A wrap-around (last step -> 0) completes one interval: advance the variant.
        if oldVal == slideShowStepCount - 1 {
          withAnimation(.bouncy) {
            activeAppIconColorVariant = activeAppIconColorVariant.next
          }
        }
      }

      // Animated copy
      if showEasterEgg {
        AltAppIconEasterEggRow(
          ikaAppIcon: .rick,
          appIconColorVariant: $activeAppIconColorVariant,
          buttonPressCounter: $easterEggBounceCounter)
          .allowsHitTesting(false)
          .frame(width: easterEggCellRectGlobal.width, height: easterEggCellRectGlobal.height)
          .globalPosition(x: easterEggCellRectGlobal.midX, y: easterEggCellRectGlobal.midY)
          .opacity(shouldDisplayAnimatedCopy ? 1 : 0)
      }

      modalDimmingLayer
    }
    .safeAreaBar(edge: .bottom) {
      slideShowControl
        .padding()
    }
    .onAppear {
      doesPreferRickOnAppear = ikaPreference.preferredAppIcon == .rick
      Task { await connectivityChecker.performGFWCheck() }
    }
    .onChange(of: easterEggBounceCounter) {
      shouldDisplayAnimatedCopy = true
      // Cancel the previous task, if it exists
      currentToggleAfterDelayTask?.cancel()
      // Schedule a new task
      currentToggleAfterDelayTask = Task { await toggleShouldDisplayAnimatedCopyAfterDelay() }
    }
  }

  private var modalDimmingLayer: some View {
    Color.black
      .ignoresSafeArea()
      .opacity(!slideShowPhase.isPickerExpanded ? 0 : ScopedStyle.modalDimmingLayerOpacity)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .onTapGesture {
        withAnimation(.bouncy) {
          collapsePicker()
        }
      }
  }

  private var slideShowControl: some View {
    GlassEffectContainer(spacing: ScopedStyle.safeAreaBarGlassEffectSpacing) {
      HStack {
        appIconSlideShowPlayPauseButton
        activeAppIconColorVariantPicker
        appIconSlideShowNextButton
      }
      .font(ScopedStyle.safeAreaBarDefaultFont)
    }
  }

  private var appIconSlideShowPlayPauseButton: some View {
    Image(systemName: slideShowPhase.isPlaying ? "pause" : "play")
      .symbolVariant(.fill)
      .contentTransition(.symbolEffect(.replace.offUp))
      .opacity(!slideShowPhase.isPickerExpanded ? 1 : ScopedStyle.slideShowNextButtonDisabledOpacity)
      .frame(
        width: ScopedStyle.slideShowControlButtonSize,
        height: ScopedStyle.slideShowControlButtonSize)
      .contentShape(Rectangle())
      .allowsHitTesting(!slideShowPhase.isPickerExpanded)
      .onTapGesture {
        SimpleHaptics.generateTask(.selection)
        withAnimation(.bouncy) {
          togglePlayback()
        }
      }
      .glassEffect(!slideShowPhase.isPickerExpanded ? .regular.interactive() : .regular)
  }

  private var appIconSlideShowNextButton: some View {
    Image(systemName: "forward.end")
      .symbolVariant(.fill)
      .opacity(!slideShowPhase.isPickerExpanded ? 1 : ScopedStyle.slideShowNextButtonDisabledOpacity)
      .frame(width: ScopedStyle.slideShowControlButtonSize, height: ScopedStyle.slideShowControlButtonSize)
      .contentShape(Rectangle())
      .allowsHitTesting(!slideShowPhase.isPickerExpanded)
      .onTapGesture {
        SimpleHaptics.generateTask(.selection)
        // -> outside of closure because of icon animation collision
        activeAppIconColorVariant = activeAppIconColorVariant.next

        withAnimation(.snappy) {
          slideShowProgress = 0
        }
      }
      .glassEffect(!slideShowPhase.isPickerExpanded ? .regular.interactive() : .regular)
  }

  private var pickerNameLabels: some View {
    ZStack {
      ForEach(IkaAppIcon.ColorVariant.allCases) { variant in
        Text(variant.displayNameLocalizedStringKey)
          .blurFade(isShown: !slideShowPhase.isPickerExpanded && variant == activeAppIconColorVariant)
          .frame(
            height: ScopedStyle.slideShowControlButtonSize)
          .fixedSize()
          .padding(.horizontal, ScopedStyle.slideShowControlPickerNameLabelPaddingH)
          .contentShape(Rectangle())
          .allowsHitTesting(!slideShowPhase.isPickerExpanded && variant == activeAppIconColorVariant)
          .onTapGesture {
            withAnimation(.bouncy) {
              expandPicker()
            }
          }
      }
    }
  }

  private var progressBar: some View {
    ProgressView(
      value: Double(slideShowProgress),
      total: Double(slideShowStepCount))
      .tint(.accentColor)
      .opacity(ScopedStyle.slideShowProgressBarOpacity)
      .frame(height: ScopedStyle.slideShowProgressBarHeight)
      .blurFade(isShown: !slideShowPhase.isPickerExpanded)
      .vAlignment(.bottom)
      .padding(.horizontal, ScopedStyle.slideShowProgressBarPaddingH)
      .allowsHitTesting(false)
      .clipShape(.capsule)
      // identity reset: skip the fill-drain animation when the variant or phase jumps
      .id("\(activeAppIconColorVariant)-\(slideShowPhase.isPlaying)")
  }

  private var pickerIcons: some View {
    Group {
      ForEach(IkaAppIcon.ColorVariant.allCases) { variant in
        Image(systemName: variant.sfSymbolName)
          .symbolEffect(
            .bounce.down.byLayer,
            options: .nonRepeating,
            isActive: activeAppIconColorVariant == variant)
          .blurFade(isShown: slideShowPhase.isPickerExpanded)
          .frame(
            width: ScopedStyle.slideShowControlButtonSize,
            height: ScopedStyle.slideShowControlButtonSize)
          .contentShape(Rectangle())
          .allowsHitTesting(slideShowPhase.isPickerExpanded)
          .onTapGesture {
            SimpleHaptics.generateTask(.selection)
            withAnimation(.bouncy) {
              activeAppIconColorVariant = variant
              collapsePicker()
            }
          }
      }
    }
  }

  private var activeAppIconColorVariantPicker: some View {
    let layout = slideShowPhase.isPickerExpanded ? AnyLayout(HStackLayout()) : AnyLayout(ZStackLayout())
    return
      ZStack {
        pickerNameLabels
          .overlay(alignment: .bottom) {
            progressBar
          }
        layout { pickerIcons }
      }
      .font(ScopedStyle.colorVariantPickerFont)
      .glassEffect(.regular.interactive())
  }

  private var easterEggTrigger: some View {
    Button {
      if !doesPreferRickOnAppear { SimpleHaptics.generateTask(.soft) }
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
    .foregroundStyle(
      Color.accentColor
        .opacity(
          ikaDiscoveryLog.hasDiscoveredEasterEgg
            ? 1
            : colorScheme == .light
              ? 0.07
              : horizontalSizeClass == .compact
                ? 0.07
                : 0.03))
  }

  private func toggleShouldDisplayAnimatedCopyAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(2.1 * 1_000_000_000))
    guard !Task.isCancelled else { return }

    shouldDisplayAnimatedCopy = false
  }
}

#Preview {
  NavigationStack {
    SettingsAltAppIconView()
  }
  .ikaPreviewEnvironment()
}
