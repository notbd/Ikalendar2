//
//  AltAppIconRow.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - AltAppIconRow

struct AltAppIconRow: View {
  typealias Scoped = Constants.Style.Settings.AltAppIcon

  @EnvironmentObject private var ikaPreference: IkaPreference

  let ikaAppIcon: IkaAppIcon

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
      Image(ikaAppIcon.getImageName(.small))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: IkaAppIcon.DisplayMode.small.size,
          height: IkaAppIcon.DisplayMode.small.size)
        .clipShape(
          IkaAppIcon.DisplayMode.small.clipShape)
        .overlay(
          IkaAppIcon.DisplayMode.small.clipShape
            .stroke(Scoped.APP_ICON_STROKE_COLOR, lineWidth: Scoped.APP_ICON_STROKE_LINE_WIDTH)
            .opacity(Scoped.APP_ICON_STROKE_OPACITY))
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)

      Text(ikaAppIcon.displayName.localizedStringKey)
        .font(.system(.body, design: .rounded))
        .foregroundStyle(Scoped.DISPLAY_NAME_COLOR)

      Spacer()

      if ikaAppIcon == ikaPreference.preferredAppIcon {
        Image(systemName: Scoped.ACTIVE_INDICATOR_SFSYMBOL)
          .font(Scoped.ACTIVE_INDICATOR_FONT)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.accentColor, Color.tertiarySystemGroupedBackground)
      }
    }
    .padding(.vertical, Scoped.ROW_PADDING_V)
  }

  // MARK: Private

  private func setAltAppIcon(_ ikaAppIcon: IkaAppIcon) {
    guard ikaPreference.preferredAppIcon != ikaAppIcon else { return }
    ikaPreference.preferredAppIcon = ikaAppIcon
  }
}

// MARK: - AltAppIconEasterEggRow

struct AltAppIconEasterEggRow: View {
  typealias Scoped = Constants.Style.Settings.AltAppIcon

  @Environment(\.openURL) private var openURL
  @Environment(\.locale) private var currentLocale

  @EnvironmentObject private var ikaPreference: IkaPreference
  @EnvironmentObject private var ikaLog: IkaLog

  @State private var isGFWed = true

  let ikaAppIcon: IkaAppIcon
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
    .task {
      if !ikaLog.hasDiscoveredEasterEgg { await checkIfGFWed() }
    }
  }

  private var rowContent: some View {
    HStack(spacing: Scoped.SPACING_H) {
      Image(ikaAppIcon.getImageName(.small))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: IkaAppIcon.DisplayMode.small.size,
          height: IkaAppIcon.DisplayMode.small.size)
        .clipShape(
          IkaAppIcon.DisplayMode.small.clipShape)
        .overlay(
          IkaAppIcon.DisplayMode.small.clipShape
            .stroke(Scoped.APP_ICON_STROKE_COLOR, lineWidth: Scoped.APP_ICON_STROKE_LINE_WIDTH)
            .opacity(Scoped.APP_ICON_STROKE_OPACITY))
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .if(ikaAppIcon.isEasterEgg) {
          applyEasterEggAnimation($0)
        }

      Text(ikaAppIcon.displayName.localizedStringKey)
        .font(.system(.body, design: .rounded))
        .foregroundStyle(Scoped.DISPLAY_NAME_COLOR)

      Spacer()

      if ikaAppIcon == ikaPreference.preferredAppIcon {
        Image(systemName: Scoped.ACTIVE_INDICATOR_SFSYMBOL)
          .font(Scoped.ACTIVE_INDICATOR_FONT)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.accentColor, Color.tertiarySystemGroupedBackground)
      }
    }
    .padding(.vertical, Scoped.ROW_PADDING_V)
  }

  // MARK: Private

  private func jumpToURLAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(1.3 * 1_000_000_000))
    let goodStuffURLString = isGFWed
      ? Constants.Key.URL.THE_GOOD_STUFF_CN
      : Constants.Key.URL.THE_GOOD_STUFF
    guard let url = URL(string: goodStuffURLString) else { return }
    openURL(url)
  }

  private func checkIfGFWed() async {
    guard let googleURL = URL(string: Constants.Key.URL.GOOGLE_HOMEPAGE) else { return }
    do {
      let (_, response) = try await URLSession.shared.data(from: googleURL)
      if let httpResponse = response as? HTTPURLResponse {
        if 200 ... 299 ~= httpResponse.statusCode { isGFWed = false } // OK
        else { return } // is GFW'ed
      }
    }
    catch { return } // device is offline
  }

  private func applyEasterEggAnimation(_ content: some View) -> some View {
    let randomRotationAngel = Double((Int.random(in: 16 ... 24)) * (Bool.random() ? 1 : -1))

    return content
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
  var angle = Angle.zero
}
