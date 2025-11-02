//
//  SettingsAltAppIconView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Combine
import SimpleHaptics
import SwiftUI

// MARK: - SettingsAltAppIconView

/// The Settings page for switching alternate App Icons.
@MainActor
struct SettingsAltAppIconView: View {
  typealias ScopedConfig = Constants.Config.Settings.AltAppIcon
  typealias ScopedStyle = Constants.Style.Settings.AltAppIcon

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

  @State private var isVariantPickerExpanded: Bool = false
  @State private var activeAppIconColorVariant: IkaAppIcon.ColorVariant = .default
  var activeAppIconDisplayMode: IkaAppIcon.DisplayMode {
    .init(color: activeAppIconColorVariant, size: .small)
  }

  @State private var slideShowTimerCancellable: AnyCancellable?
  @State private var isSlideShowActive: Bool = false
  @State private var wasSlideShowActiveBeforePickerExpanded: Bool = false
  @State private var slideShowProgress: Int = 0
  var slideShowIntervalStepCount: Int {
    Int(floor(ScopedConfig.slideShowInterval / ScopedConfig.slideShowIntervalStepLength))
  }

  private var slideShowTimerPublisher: AnyPublisher<Date, Never> {
    Timer.publish(
      every: ScopedConfig.slideShowIntervalStepLength,
      tolerance: ScopedConfig.slideShowIntervalStepLength / 10,
      on: .main,
      in: .common)
      .autoconnect()
      .eraseToAnyPublisher()
  }

  private func startSlideShow() {
    guard !isSlideShowActive else { return }

    slideShowTimerCancellable =
      slideShowTimerPublisher
        .sink { _ in
          withAnimation(.snappy) {
            slideShowProgress = (slideShowProgress + 1) % slideShowIntervalStepCount
          }
        }
    isSlideShowActive = true

    withAnimation(.bouncy) {
      isVariantPickerExpanded = false
    }
  }

  private func stopSlideShow() {
    slideShowTimerCancellable?.cancel()
    slideShowTimerCancellable = nil
    resetSlideShowProgress()
    isSlideShowActive = false
  }

  private func toggleSlideShow() {
    isSlideShowActive ? stopSlideShow() : startSlideShow()
  }

  private func resetSlideShowProgress() {
    slideShowProgress = 0
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
        if !ikaLog.hasDiscoveredAltAppIcon { ikaLog.hasDiscoveredAltAppIcon = true }
        startSlideShow()
      }
      .onChange(of: slideShowProgress) { oldVal, _ in
        if oldVal == slideShowIntervalStepCount - 1 {
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
      GlassEffectContainer(spacing: ScopedStyle.SAFE_AREA_BAR_GLASS_EFFECT_SPACING) {
        HStack {
          appIconSlideShowPlayPauseButton
          activeAppIconColorVariantPicker
          appIconSlideShowNextButton
        }
        .font(ScopedStyle.SAFE_AREA_BAR_DEFAULT_FONT)
      }
      .padding()
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

  private var modalDimmingLayer: some View {
    Color.black
      .ignoresSafeArea()
      .opacity(!isVariantPickerExpanded ? 0 : ScopedStyle.MODAL_DIMMING_LAYER_OPACITY)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .onTapGesture {
        withAnimation(.bouncy) {
          isVariantPickerExpanded.toggle()
          wasSlideShowActiveBeforePickerExpanded ? startSlideShow() : { }()
        }
      }
  }

  private var appIconSlideShowPlayPauseButton: some View {
    Image(systemName: isSlideShowActive ? "pause" : "play")
      .symbolVariant(.fill)
      .contentTransition(.symbolEffect(.replace.offUp))
      .frame(
        width: ScopedStyle.SLIDE_SHOW_CONTROL_BUTTON_SIZE,
        height: ScopedStyle.SLIDE_SHOW_CONTROL_BUTTON_SIZE)
      .contentShape(Rectangle())
      .onTapGesture {
        SimpleHaptics.generateTask(.selection)
        withAnimation(.bouncy) {
          toggleSlideShow()
        }
      }
      .glassEffect(.regular.interactive())
  }

  private var appIconSlideShowNextButton: some View {
    Image(systemName: "forward.end")
      .symbolVariant(.fill)
      .opacity(!isVariantPickerExpanded ? 1 : ScopedStyle.SLIDE_SHOW_NEXT_BUTTON_DISABLED_OPACITY)
      .frame(width: ScopedStyle.SLIDE_SHOW_CONTROL_BUTTON_SIZE, height: ScopedStyle.SLIDE_SHOW_CONTROL_BUTTON_SIZE)
      .contentShape(Rectangle())
      .allowsHitTesting(!isVariantPickerExpanded)
      .onTapGesture {
        SimpleHaptics.generateTask(.selection)
        // -> outside of closure because of icon animation collision
        activeAppIconColorVariant = activeAppIconColorVariant.next

        withAnimation(.snappy) {
          resetSlideShowProgress()
        }
      }
      .glassEffect(!isVariantPickerExpanded ? .regular.interactive() : .regular)
  }

  private var pickerNameLabels: some View {
    ZStack {
      ForEach(IkaAppIcon.ColorVariant.allCases) { variant in
        Text(variant.displayNameLocalizedStringKey)
          .blurFade(isShown: !isVariantPickerExpanded && variant == activeAppIconColorVariant)
          .frame(
            height: ScopedStyle.SLIDE_SHOW_CONTROL_BUTTON_SIZE)
          .fixedSize()
          .padding(.horizontal)
          .contentShape(Rectangle())
          .allowsHitTesting(!isVariantPickerExpanded && variant == activeAppIconColorVariant)
          .onTapGesture {
            withAnimation(.bouncy) {
              isVariantPickerExpanded.toggle()
              wasSlideShowActiveBeforePickerExpanded = isSlideShowActive
              stopSlideShow()
            }
          }
      }
    }
  }

  private var progressBar: some View {
    ProgressView(
      value: Double(slideShowProgress),
      total: Double(slideShowIntervalStepCount))
      .tint(.accentColor)
      .opacity(ScopedStyle.SLIDE_SHOW_PROGRESS_BAR_OPACITY)
      .frame(height: ScopedStyle.SLIDE_SHOW_PROGRESS_BAR_HEIGHT)
      .blurFade(isShown: !isVariantPickerExpanded)
      .vAlignment(.bottom)
      .padding(.horizontal, ScopedStyle.SLIDE_SHOW_PROGRESS_BAR_PADDING_H)
      .allowsHitTesting(false)
      .clipShape(.capsule)
      .id("\(activeAppIconColorVariant)-\(isSlideShowActive)")
  }

  private var pickerIcons: some View {
    Group {
      ForEach(IkaAppIcon.ColorVariant.allCases) { variant in
        Image(systemName: variant.sfSymbolName)
          .symbolEffect(
            .bounce.down.byLayer,
            options: .nonRepeating,
            isActive: activeAppIconColorVariant == variant)
          .blurFade(isShown: isVariantPickerExpanded)
          .frame(
            width: ScopedStyle.SLIDE_SHOW_CONTROL_BUTTON_SIZE,
            height: ScopedStyle.SLIDE_SHOW_CONTROL_BUTTON_SIZE)
          .contentShape(Rectangle())
          .allowsHitTesting(isVariantPickerExpanded)
          .onTapGesture {
            SimpleHaptics.generateTask(.selection)
            withAnimation(.bouncy) {
              activeAppIconColorVariant = variant
              isVariantPickerExpanded.toggle()
            }
          }
      }
    }
  }

  private var activeAppIconColorVariantPicker: some View {
    let layout = isVariantPickerExpanded ? AnyLayout(HStackLayout()) : AnyLayout(ZStackLayout())
    return
      ZStack {
        pickerNameLabels
          .overlay(alignment: .bottom) {
            progressBar
          }
        layout { pickerIcons }
      }
      .font(ScopedStyle.COLOR_VARIANT_PICKER_FONT)
      .glassEffect(.regular.interactive())
  }

  private var easterEggTrigger: some View {
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
