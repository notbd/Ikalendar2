//
//  AltAppIconRow.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - AltAppIconRow

struct AltAppIconRow: View {
  typealias Scoped = Constants.Style.Settings.AltAppIcon.Row

  @EnvironmentObject private var ikaPreference: IkaPreference

  let ikaAppIcon: IkaAppIcon
  @Binding var appIconColorVariant: IkaAppIcon.ColorVariant
  var appIconDisplayMode: IkaAppIcon.DisplayMode {
    .init(color: appIconColorVariant, size: .small)
  }

  var body: some View {
    Button {
      setAltAppIcon(ikaAppIcon)
    }
    label: {
      rowContent
    }
  }

  private var rowContent: some View {
    HStack(spacing: Scoped.SPACING_H) {
      Image(ikaAppIcon.getImageName(appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size.screenSize,
          height: appIconDisplayMode.size.screenSize)
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .animation(
          Scoped.CROSS_FADE_ANIMATION,
          value: appIconColorVariant)

      Text(ikaAppIcon.displayNameLocalizedStringKey)
        .font(.system(.body, design: .rounded))
        .foregroundStyle(Scoped.DISPLAY_NAME_COLOR)

      Spacer()

      if ikaAppIcon == ikaPreference.preferredAppIcon {
        Image(systemName: Scoped.ACTIVE_INDICATOR_SFSYMBOL)
          .font(Scoped.ACTIVE_INDICATOR_FONT)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.accentColor, Color.systemGroupedBackgroundTertiary)
      }
    }
    .padding(.vertical, Scoped.ROW_PADDING_V)
  }

  private func setAltAppIcon(_ ikaAppIcon: IkaAppIcon) {
    guard ikaPreference.preferredAppIcon != ikaAppIcon else { return }

    ikaPreference.preferredAppIcon = ikaAppIcon
  }
}

// MARK: - AltAppIconEasterEggRow

struct AltAppIconEasterEggRow: View {
  typealias Scoped = Constants.Style.Settings.AltAppIcon.Row

  @Environment(\.openURL) private var openURL
  @Environment(\.locale) private var currentLocale

  @EnvironmentObject private var ikaPreference: IkaPreference
  @EnvironmentObject private var ikaLog: IkaLog

  @Environment(IkaInternetConnectivityPublisher.self) var gfwMonitor

  let ikaAppIcon: IkaAppIcon
  @Binding var appIconColorVariant: IkaAppIcon.ColorVariant
  var appIconDisplayMode: IkaAppIcon.DisplayMode {
    .init(color: appIconColorVariant, size: .small)
  }

  @Binding var buttonPressCounter: Int

  var body: some View {
    Button {
      // jump to the good stuff
      if !ikaLog.hasDiscoveredEasterEgg { Task { await jumpToURLAfterDelay() } }
      // set flag: has discovered easter egg
      if !ikaLog.hasDiscoveredEasterEgg { ikaLog.hasDiscoveredEasterEgg = true }
      // add compensatory haptics for repeated button presses
      if ikaPreference.preferredAppIcon == .rick { SimpleHaptics.generateTask(.medium) }
      // trigger animation
      buttonPressCounter += 1
      // set app icon
      setAltAppIcon(ikaAppIcon)
    }
    label: { rowContent }
  }

  private var rowContent: some View {
    HStack(spacing: Scoped.SPACING_H) {
      Image(ikaAppIcon.getImageName(appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size.screenSize,
          height: appIconDisplayMode.size.screenSize)
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .animation(
          Scoped.CROSS_FADE_ANIMATION,
          value: appIconColorVariant)
        .apply(applyEasterEggAnimation)

      Text(ikaAppIcon.displayNameLocalizedStringKey)
        .font(.system(.body, design: .rounded))
        .foregroundStyle(Scoped.DISPLAY_NAME_COLOR)

      Spacer()

      if ikaAppIcon == ikaPreference.preferredAppIcon {
        Image(systemName: Scoped.ACTIVE_INDICATOR_SFSYMBOL)
          .font(Scoped.ACTIVE_INDICATOR_FONT)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.accentColor, Color.systemGroupedBackgroundTertiary)
      }
    }
    .padding(.vertical, Scoped.ROW_PADDING_V)
  }

  private func jumpToURLAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(1.3 * 1_000_000_000))
    let goodStuffURLString = gfwMonitor.isGFWed
      ? Constants.Key.URL.THE_GOOD_STUFF_CN
      : Constants.Key.URL.THE_GOOD_STUFF
    guard let url = URL(string: goodStuffURLString) else { return }

    openURL(url)
  }

  private func applyEasterEggAnimation(_ content: some View) -> some View {
    let randomRotationAngel: Double = .init((Int.random(in: 16 ... 24)) * (Bool.random() ? 1 : -1))

    return
      content
        .keyframeAnimator(
          initialValue: AppIconEasterEggAnimationValues(),
          trigger: buttonPressCounter)
        { content, value in
          content
            .rotationEffect(value.angle)
            .scaleEffect(value.scale)
            .scaleEffect(y: value.verticalStretch)
            .offset(y: value.verticalTranslation)
        } keyframes: { _ in
          KeyframeTrack(\.angle) {
            CubicKeyframe(.zero, duration: 0.58)
            CubicKeyframe(.degrees(randomRotationAngel), duration: 0.125)
            CubicKeyframe(.degrees(-randomRotationAngel), duration: 0.125)
            CubicKeyframe(.degrees(randomRotationAngel), duration: 0.125)
            CubicKeyframe(.zero, duration: 0.125)
          }

          KeyframeTrack(\.verticalStretch) {
            CubicKeyframe(1.0, duration: 0.1)
            CubicKeyframe(0.6, duration: 0.15)
            CubicKeyframe(1.5, duration: 0.1)
            CubicKeyframe(1.05, duration: 0.15)
            CubicKeyframe(1.0, duration: 0.88)
            CubicKeyframe(0.8, duration: 0.1)
            CubicKeyframe(1.04, duration: 0.4)
            CubicKeyframe(1.0, duration: 0.22)
          }

          KeyframeTrack(\.scale) {
            LinearKeyframe(1.0, duration: 0.36)
            SpringKeyframe(1.5, duration: 0.8, spring: .bouncy)
            SpringKeyframe(1.0, spring: .bouncy)
          }

          KeyframeTrack(\.verticalTranslation) {
            LinearKeyframe(0.0, duration: 0.1)
            SpringKeyframe(20.0, duration: 0.15, spring: .bouncy)
            SpringKeyframe(-60.0, duration: 1.0, spring: .bouncy)
            SpringKeyframe(0.0, spring: .bouncy)
          }
        }
  }

  private func setAltAppIcon(_ ikaAppIcon: IkaAppIcon) {
    guard ikaPreference.preferredAppIcon != ikaAppIcon else { return }

    ikaPreference.preferredAppIcon = ikaAppIcon
  }
}

// MARK: - AppIconEasterEggAnimationValues

struct AppIconEasterEggAnimationValues {
  var scale = 1.0
  var verticalStretch = 1.0
  var verticalTranslation = 0.0
  var angle: Angle = .zero
}
