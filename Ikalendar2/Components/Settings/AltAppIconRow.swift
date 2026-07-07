//
//  AltAppIconRow.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - AltAppIconRow

/// One selectable app icon row: preview image, name, and active checkmark.
struct AltAppIconRow: View {
  typealias Scoped = Constants.Style.Settings.AltAppIcon.Row

  @Environment(IkaPreference.self) private var ikaPreference

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
    HStack(spacing: Scoped.spacingH) {
      Image(ikaAppIcon.getImageName(appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size.screenSize,
          height: appIconDisplayMode.size.screenSize)
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .animation(
          Scoped.crossFadeAnimation,
          value: appIconColorVariant)

      Text(ikaAppIcon.displayNameLocalizedStringKey)
        .font(.system(.body, design: .rounded))
        .foregroundStyle(Scoped.displayNameColor)

      Spacer()

      if ikaAppIcon == ikaPreference.preferredAppIcon {
        Image(systemName: Scoped.activeIndicatorSFSymbol)
          .font(Scoped.activeIndicatorFont)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.accentColor, Color.systemGroupedBackgroundTertiary)
      }
    }
    .padding(.vertical, Scoped.rowPaddingV)
  }

  private func setAltAppIcon(_ ikaAppIcon: IkaAppIcon) {
    guard ikaPreference.preferredAppIcon != ikaAppIcon else { return }

    ikaPreference.preferredAppIcon = ikaAppIcon
  }
}

// MARK: - AltAppIconEasterEggRow

/// The Rick row. Selecting it jumps to the good stuff on first discovery.
struct AltAppIconEasterEggRow: View {
  typealias Scoped = Constants.Style.Settings.AltAppIcon.Row

  @Environment(\.openURL) private var openURL
  @Environment(\.locale) private var currentLocale

  @Environment(IkaPreference.self) private var ikaPreference
  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog

  @Environment(IkaConnectivityChecker.self) var connectivityChecker

  let ikaAppIcon: IkaAppIcon
  @Binding var appIconColorVariant: IkaAppIcon.ColorVariant
  var appIconDisplayMode: IkaAppIcon.DisplayMode {
    .init(color: appIconColorVariant, size: .small)
  }

  @Binding var buttonPressCounter: Int

  var body: some View {
    Button {
      // jump to the good stuff (first discovery only)
      if !ikaDiscoveryLog.hasDiscoveredEasterEgg { Task { await jumpToURLAfterDelay() } }
      if !ikaDiscoveryLog.hasDiscoveredEasterEgg { ikaDiscoveryLog.hasDiscoveredEasterEgg = true }
      // compensatory haptics for repeated presses
      if ikaPreference.preferredAppIcon == .rick { SimpleHaptics.generateTask(.medium) }
      buttonPressCounter += 1
      setAltAppIcon(ikaAppIcon)
    }
    label: { rowContent }
  }

  private var rowContent: some View {
    HStack(spacing: Scoped.spacingH) {
      Image(ikaAppIcon.getImageName(appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size.screenSize,
          height: appIconDisplayMode.size.screenSize)
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .animation(
          Scoped.crossFadeAnimation,
          value: appIconColorVariant)
        // Inlined on the concrete view: wrapping this in a `some View` helper
        // trips a non-Sendable metatype warning from the content closure.
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
          AppIconEasterEggAnimationValues.easterEggKeyframes(
            rotationAngle: .init((Int.random(in: 16 ... 24)) * (Bool.random() ? 1 : -1)))
        }

      Text(ikaAppIcon.displayNameLocalizedStringKey)
        .font(.system(.body, design: .rounded))
        .foregroundStyle(Scoped.displayNameColor)

      Spacer()

      if ikaAppIcon == ikaPreference.preferredAppIcon {
        Image(systemName: Scoped.activeIndicatorSFSymbol)
          .font(Scoped.activeIndicatorFont)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.accentColor, Color.systemGroupedBackgroundTertiary)
      }
    }
    .padding(.vertical, Scoped.rowPaddingV)
  }

  private func jumpToURLAfterDelay() async {
    try? await Task.sleep(for: .seconds(Constants.Config.Settings.AltAppIcon.easterEggJumpDelay))
    let goodStuffURLString = connectivityChecker.isGFWed
      ? Constants.Key.URLs.theGoodStuffCN
      : Constants.Key.URLs.theGoodStuff
    guard let url = URL(string: goodStuffURLString) else { return }

    openURL(url)
  }

  private func setAltAppIcon(_ ikaAppIcon: IkaAppIcon) {
    guard ikaPreference.preferredAppIcon != ikaAppIcon else { return }

    ikaPreference.preferredAppIcon = ikaAppIcon
  }
}

// MARK: - AppIconEasterEggAnimationValues

/// Animatable values for the easter-egg icon jump.
struct AppIconEasterEggAnimationValues {
  var scale = 1.0
  var verticalStretch = 1.0
  var verticalTranslation = 0.0
  var angle: Angle = .zero

  /// Easter-egg jump: shake by +-`rotationAngle`, squash, leap with overshoot, settle.
  @KeyframesBuilder<AppIconEasterEggAnimationValues>
  static func easterEggKeyframes(rotationAngle: Double)
    -> some Keyframes<AppIconEasterEggAnimationValues>
  {
    KeyframeTrack(\.angle) {
      CubicKeyframe(.zero, duration: 0.58)
      CubicKeyframe(.degrees(rotationAngle), duration: 0.125)
      CubicKeyframe(.degrees(-rotationAngle), duration: 0.125)
      CubicKeyframe(.degrees(rotationAngle), duration: 0.125)
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

#Preview("Rows") {
  @Previewable @State var colorVariant: IkaAppIcon.ColorVariant = .default

  List {
    Section {
      ForEach(IkaAppIcon.allCases.filter { !$0.isEasterEgg }) { icon in
        AltAppIconRow(ikaAppIcon: icon, appIconColorVariant: $colorVariant)
      }
    }
  }
  .listStyle(.insetGrouped)
  .ikaPreviewEnvironment()
}

#Preview("Easter Egg Row") {
  @Previewable @State var colorVariant: IkaAppIcon.ColorVariant = .default
  @Previewable @State var bounceCounter: Int = 0

  List {
    AltAppIconEasterEggRow(
      ikaAppIcon: .rick,
      appIconColorVariant: $colorVariant,
      buttonPressCounter: $bounceCounter)
  }
  .listStyle(.insetGrouped)
  .ikaPreviewEnvironment()
}
