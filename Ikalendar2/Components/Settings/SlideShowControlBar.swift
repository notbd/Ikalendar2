//
//  SlideShowControlBar.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SlideShowControlBar

/// The App Icon page's bottom bar: play/pause, the color variant picker with the cycle's
/// progress bar, and next.
struct SlideShowControlBar: View {
  typealias Scoped = Constants.Style.Settings.AltAppIcon

  @Binding var slideShow: SlideShow
  @Binding var appIconColorVariant: IkaAppIcon.ColorVariant

  var body: some View {
    GlassEffectContainer(spacing: Scoped.safeAreaBarGlassEffectSpacing) {
      HStack {
        playPauseButton
        colorVariantPicker
        nextButton
      }
      .font(Scoped.safeAreaBarDefaultFont)
    }
  }

  private var playPauseButton: some View {
    Image(systemName: slideShow.isPlaying ? "pause" : "play")
      .symbolVariant(.fill)
      .contentTransition(.symbolEffect(.replace.offUp))
      .opacity(!slideShow.isPickerExpanded ? 1 : Scoped.slideShowNextButtonDisabledOpacity)
      .frame(
        width: Scoped.slideShowControlButtonSize,
        height: Scoped.slideShowControlButtonSize)
      .contentShape(Rectangle())
      .allowsHitTesting(!slideShow.isPickerExpanded)
      .onTapGesture {
        SimpleHaptics.generateTask(.selection)
        withAnimation(.bouncy) {
          slideShow.togglePlayback(now: .now)
        }
      }
      .accessibilityLabel(slideShow.isPlaying ? Text("Pause") : Text("Play"))
      .accessibilityAddTraits(.isButton)
      .accessibilityHidden(slideShow.isPickerExpanded)
      .glassEffect(!slideShow.isPickerExpanded ? .regular.interactive() : .regular)
  }

  private var nextButton: some View {
    Image(systemName: "forward.end")
      .symbolVariant(.fill)
      .opacity(!slideShow.isPickerExpanded ? 1 : Scoped.slideShowNextButtonDisabledOpacity)
      .frame(width: Scoped.slideShowControlButtonSize, height: Scoped.slideShowControlButtonSize)
      .contentShape(Rectangle())
      .allowsHitTesting(!slideShow.isPickerExpanded)
      .onTapGesture {
        SimpleHaptics.generateTask(.selection)
        // One transaction, not inside withAnimation: an implicit animation here would fight the
        // icon's own cross-fade (Constants.Motion.appIconCrossFade).
        appIconColorVariant = appIconColorVariant.next
        slideShow.restartCycle(now: .now)
      }
      .accessibilityLabel(Text("Next"))
      .accessibilityAddTraits(.isButton)
      .accessibilityHidden(slideShow.isPickerExpanded)
      .glassEffect(!slideShow.isPickerExpanded ? .regular.interactive() : .regular)
  }

  private var pickerNameLabels: some View {
    ZStack {
      ForEach(IkaAppIcon.ColorVariant.allCases) { variant in
        Text(variant.displayNameLocalizedStringKey)
          .blurFade(isShown: !slideShow.isPickerExpanded && variant == appIconColorVariant)
          .frame(
            height: Scoped.slideShowControlButtonSize)
          .fixedSize()
          .padding(.horizontal, Scoped.slideShowControlPickerNameLabelPaddingH)
          .contentShape(Rectangle())
          .allowsHitTesting(!slideShow.isPickerExpanded && variant == appIconColorVariant)
          .onTapGesture {
            withAnimation(.bouncy) {
              slideShow.expandPicker()
            }
          }
          .accessibilityAddTraits(.isButton)
          .accessibilityHidden(slideShow.isPickerExpanded || variant != appIconColorVariant)
      }
    }
  }

  private var progressBar: some View {
    Group {
      if let cycle = slideShow.cycle {
        // Fills on its own from the cycle's dates; nothing re-renders the page while it runs.
        ProgressView(timerInterval: cycle, countsDown: false) {
          EmptyView()
        } currentValueLabel: {
          EmptyView()
        }
      }
      else {
        ProgressView(value: 0.0)
      }
    }
    .tint(.accentColor)
    .opacity(Scoped.slideShowProgressBarOpacity)
    .frame(height: Scoped.slideShowProgressBarHeight)
    .blurFade(isShown: !slideShow.isPickerExpanded)
    .vAlignment(.bottom)
    .padding(.horizontal, Scoped.slideShowProgressBarPaddingH)
    .allowsHitTesting(false)
    .accessibilityHidden(slideShow.isPickerExpanded)
    .clipShape(.capsule)
    // A fresh bar per cycle: a restart or a stop never animates the fill draining back to 0.
    .id(slideShow.cycleStart)
  }

  private var pickerIcons: some View {
    ForEach(IkaAppIcon.ColorVariant.allCases) { variant in
      Image(systemName: variant.sfSymbolName)
        .symbolEffect(
          .bounce.down.byLayer,
          options: .nonRepeating,
          isActive: appIconColorVariant == variant)
        .blurFade(isShown: slideShow.isPickerExpanded)
        .frame(
          width: Scoped.slideShowControlButtonSize,
          height: Scoped.slideShowControlButtonSize)
        .contentShape(Rectangle())
        .allowsHitTesting(slideShow.isPickerExpanded)
        .onTapGesture {
          SimpleHaptics.generateTask(.selection)
          withAnimation(.bouncy) {
            appIconColorVariant = variant
            slideShow.collapsePicker(now: .now)
          }
        }
        .accessibilityLabel(Text(variant.displayNameLocalizedStringKey))
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(variant == appIconColorVariant ? .isSelected : [])
        .accessibilityHidden(!slideShow.isPickerExpanded)
    }
  }

  private var colorVariantPicker: some View {
    let layout = slideShow.isPickerExpanded ? AnyLayout(HStackLayout()) : AnyLayout(ZStackLayout())
    return
      ZStack {
        pickerNameLabels
          .overlay(alignment: .bottom) {
            progressBar
          }
        layout { pickerIcons }
      }
      .font(Scoped.colorVariantPickerFont)
      .glassEffect(.regular.interactive())
  }
}

#Preview {
  @Previewable @State var slideShow: SlideShow = .init()
  @Previewable @State var colorVariant: IkaAppIcon.ColorVariant = .default

  SlideShowControlBar(slideShow: $slideShow, appIconColorVariant: $colorVariant)
    .padding()
    .onAppear { slideShow.play(now: .now) }
    .ikaPreviewEnvironment()
}
