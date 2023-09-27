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
  @State private var startPulse: Bool = false
  @State private var triggerIconBounce: Int = 0
  @State private var currentTriggerIconBounceAfterDelayTask: Task<Void, Never>?

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
              triggerIconBounce += 1
            }
            .onChange(of: triggerIconBounce, initial: false) {
              Task {
                try? await Task.sleep(nanoseconds: UInt64(0.07 * 1_000_000_000))
                await SimpleHaptics.generate(.light)
              }
              // Cancel the previous task, if it exists
              currentTriggerIconBounceAfterDelayTask?.cancel()
              // Schedule a new task
              currentTriggerIconBounceAfterDelayTask = Task {
                await toggleShouldDisplayAnimatedCopyAfterDelay()
              }
            }
            .keyframeAnimator(
              initialValue: OnboardingObject.icon.animationValues,
              trigger: startAnimation,
              content: OnboardingObject.keyframeTransformation,
              keyframes: OnboardingObject.iconKeyframes)
            .keyframeAnimator(
              initialValue: OnboardingObject.iconEnd.animationValues,
              trigger: triggerIconBounce,
              content: OnboardingObject.keyframeTransformation,
              keyframes: OnboardingObject.iconExtraKeyframes)

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
              .font(Scoped.BUTTON_FONT)
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
          .phaseAnimator([1, 0.95], trigger: startPulse) { content, value in
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
        Task {
          try? await Task.sleep(nanoseconds: UInt64(4 * 1_000_000_000))
          if triggerIconBounce == 0 { triggerIconBounce += 1 }
        }
        Task {
          repeat {
            try? await Task.sleep(nanoseconds: UInt64(9 * 1_000_000_000))
            startPulse.toggle()
          }
          while true
        }
      }
  }

  // MARK: Private

  private func toggleShouldDisplayAnimatedCopyAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(9 * 1_000_000_000))
    guard !Task.isCancelled else { return }
    triggerIconBounce += 1
  }
}

// MARK: - OnboardingObject

enum OnboardingObject {
  case icon
  case title
  case button
  case iconEnd

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
    case .iconEnd:
      .init(
        opacity: 1,
        scale: 1,
        vStretch: 1,
        vTranslation: 0)
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

  @KeyframesBuilder<OnboardingAnimationValues>
  static func iconExtraKeyframes(start _: OnboardingAnimationValues)
    -> some Keyframes<OnboardingAnimationValues>
  {
    KeyframeTrack(\.vStretch) {
      CubicKeyframe(1.0, duration: 0.02)
      CubicKeyframe(0.8, duration: 0.04)
      CubicKeyframe(1.12, duration: 0.07)
      CubicKeyframe(1.04, duration: 0.3)
      CubicKeyframe(1.0, duration: 0.3)
      CubicKeyframe(0.9, duration: 0.22)
      CubicKeyframe(1.02, duration: 0.23)
      CubicKeyframe(1.0, duration: 0.20)
    }

    KeyframeTrack(\.scale) {
      LinearKeyframe(1.0, duration: 0.13)
      SpringKeyframe(1.05, duration: 0.35, spring: .bouncy)
      SpringKeyframe(1.05, duration: 0.27, spring: .smooth)
      SpringKeyframe(1.0, spring: .bouncy(duration: 0.65, extraBounce: 0.1))
    }

    KeyframeTrack(\.vTranslation) {
      SpringKeyframe(10.0, duration: 0.08, spring: .bouncy)
      SpringKeyframe(-10.0, duration: 0.4, spring: .bouncy)
      SpringKeyframe(-12.0, duration: 0.27, spring: .smooth)
      SpringKeyframe(0.0, spring: .bouncy(duration: 0.65, extraBounce: 0.3))
    }
  }
}

#Preview {
  OnboardingView()
}
