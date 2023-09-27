//
//  OnboardingView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
  typealias Scoped = Constants.Style.Onboarding

  @EnvironmentObject private var ikaLog: IkaLog

  @State private var startAnimation: Bool = false
  @State private var startBouncing: Bool = false

  var body: some View {
    let appIconDisplayMode = IkaAppIcon.DisplayMode.mid
    let appName = Constants.Key.BundleInfo.APP_DISPLAY_NAME
    let title = String(localized: "Welcome to\n\(appName)")
    var titleAttributedString = AttributedString(title)
    let appNameRange = titleAttributedString.range(of: appName)!
    titleAttributedString[appNameRange].foregroundColor = .accentColor

    return
      ZStack {
        Color.systemBackground
          .ignoresSafeArea()

        VStack(alignment: .leading) {
          Spacer()

          Image(IkaAppIcon.defaultIcon.getImageName(appIconDisplayMode))
            .antialiased(true)
            .resizable()
            .scaledToFit()
            .frame(
              width: appIconDisplayMode.size,
              height: appIconDisplayMode.size)
            .clipShape(
              appIconDisplayMode.clipShape)
            .overlay(
              appIconDisplayMode.clipShape
                .stroke(Scoped.STROKE_COLOR, lineWidth: Scoped.STROKE_LINE_WIDTH)
                .opacity(Scoped.STROKE_OPACITY))
            .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
            .onTapGesture {
              startAnimation.toggle()
            }
            .keyframeAnimator(
              initialValue: OnboardingObject.icon.animationValues,
              trigger: startAnimation,
              content: OnboardingObject.keyframeTransformation,
              keyframes: OnboardingObject.iconKeyframes)

          Text(titleAttributedString)
            .foregroundStyle(.primary)
            .font(Scoped.TITLE_FONT)
            .fontWeight(Scoped.TITLE_FONT_WEIGHT)
            .keyframeAnimator(
              initialValue: OnboardingObject.title.animationValues,
              trigger: startAnimation,
              content: OnboardingObject.keyframeTransformation,
              keyframes: OnboardingObject.titleKeyframes)

          Spacer()

          Button {
            SimpleHaptics.generateTask(.heavy)
            ikaLog.hasFinishedOnboarding = true
          } label: {
            Text("Get Started")
              .foregroundStyle(Color.white)
              .font(.headline)
              .padding(.vertical, Scoped.BUTTON_TEXT_PADDING_V)
              .containerRelativeFrame(.horizontal, count: 4, span: 3, spacing: 0)
              .fixedSize()
              .background(Color.accentColor)
              .clipShape(.rect(cornerRadius: Scoped.BUTTON_RECT_CORNER_RADIUS))
          }
          .keyframeAnimator(
            initialValue: OnboardingObject.button.animationValues,
            trigger: startAnimation,
            content: OnboardingObject.keyframeTransformation,
            keyframes: OnboardingObject.buttonKeyframes)
          .phaseAnimator([1, 0.95], trigger: startBouncing) { content, value in
            content
              .scaleEffect(value)
          } animation: { phase in
            switch phase {
            case 1:
              .bouncy(duration: 0.4, extraBounce: 0.2)
            default:
              .snappy(duration: 0.5)
            }
          }
        }
      }
      .task {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        startAnimation = true
        let hapticsDelay = OnboardingObject.Phase.show.duration + OnboardingObject.Phase.float.duration
        try? await Task.sleep(nanoseconds: UInt64(hapticsDelay * 1_000_000_000))
        SimpleHaptics.generateTask(.soft)
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        repeat {
          startBouncing.toggle()
          try? await Task.sleep(nanoseconds: 6_000_000_000)
        }
        while true
      }
  }
}

// MARK: - OnboardingObject

enum OnboardingObject {
  case icon
  case title
  case button

  static let duration: Double = 3

  enum Phase {
    case initial
    case show
    case float
    case bounceDown
    case bounceUp

    var duration: Double {
      switch self {
      case .initial:
        0.0
      case .show:
        1.5
      case .float:
        0.5
      case .bounceDown:
        0.15
      case .bounceUp:
        1.0
      }
    }
  }

  var animationValues: OnboardingAnimationValues {
    switch self {
    case .icon:
      .init(
        opacity: 0,
        scale: 0.5,
        vStretch: 1,
        vTranslation: -5)
    case .title:
      .init(
        opacity: 0,
        scale: 0.5,
        vStretch: 1,
        vTranslation: 10)
    case .button:
      .init(
        opacity: 0,
        scale: 0.8,
        vStretch: 1,
        vTranslation: 10)
    }
  }

  // MARK: Internal

  struct OnboardingAnimationValues {
    var opacity: Double
    var scale: Double
    var vStretch: Double
    var vTranslation: Double
  }

  @ViewBuilder
  @Sendable
  static func keyframeTransformation(
    content: PlaceholderContentView<some View>,
    values: OnboardingAnimationValues)
    -> some View
  {
    content
      .opacity(values.opacity)
      .scaleEffect(values.scale)
      .scaleEffect(y: values.vStretch)
      .offset(y: values.vTranslation)
  }

  @KeyframesBuilder<OnboardingAnimationValues>
  static func iconKeyframes(_: OnboardingAnimationValues)
    -> some Keyframes<OnboardingAnimationValues>
  {
    KeyframeTrack(\.opacity) {
      LinearKeyframe(1.0, duration: Phase.show.duration)
    }

    KeyframeTrack(\.scale) {
      SpringKeyframe(1.0, duration: Phase.show.duration)
    }

    KeyframeTrack(\.vTranslation) {
      LinearKeyframe(0.0, duration: Phase.show.duration)
      LinearKeyframe(0.0, duration: Phase.float.duration + 0.1)
      SpringKeyframe(5.0, duration: Phase.bounceDown.duration, spring: .bouncy)
      SpringKeyframe(-80.0, duration: Phase.bounceUp.duration, spring: .bouncy)
    }
  }

  @KeyframesBuilder<OnboardingAnimationValues>
  static func titleKeyframes(_: OnboardingAnimationValues)
    -> some Keyframes<OnboardingAnimationValues>
  {
    KeyframeTrack(\.opacity) {
      LinearKeyframe(1.0, duration: Phase.show.duration)
    }

    KeyframeTrack(\.scale) {
      SpringKeyframe(1.0, duration: Phase.show.duration)
    }

    KeyframeTrack(\.vTranslation) {
      LinearKeyframe(0.0, duration: Phase.show.duration + Phase.float.duration)
      SpringKeyframe(5.0, duration: Phase.bounceDown.duration, spring: .bouncy)
      SpringKeyframe(-80.0, duration: Phase.bounceUp.duration, spring: .bouncy)
    }
  }

  @KeyframesBuilder<OnboardingAnimationValues>
  static func buttonKeyframes(start: OnboardingAnimationValues)
    -> some Keyframes<OnboardingAnimationValues>
  {
    KeyframeTrack(\.opacity) {
      LinearKeyframe(start.opacity, duration: Phase.show.duration + Phase.float.duration)
      SpringKeyframe(1.0, duration: Phase.bounceDown.duration + Phase.bounceUp.duration)
    }

    KeyframeTrack(\.scale) {
      LinearKeyframe(start.scale, duration: Phase.show.duration + Phase.float.duration)
      SpringKeyframe(1.0, duration: Phase.bounceDown.duration + Phase.bounceUp.duration)
    }

    KeyframeTrack(\.vTranslation) {
      LinearKeyframe(start.vTranslation, duration: Phase.show.duration + Phase.float.duration)
      SpringKeyframe(0.0, duration: Phase.bounceUp.duration, spring: .bouncy)
    }
  }

}

#Preview {
  OnboardingView()
}
