//
//  OnboardingView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
  typealias Scoped = Constants.Style.Onboarding

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @EnvironmentObject private var ikaLog: IkaLog

  @State private var startAnimation: Bool = false
  @State private var startPulse: Bool = false
  @State private var iconBounceCounter: Int = 0
  @State private var currentTriggerIconBounceAfterDelayTask: Task<Void, Never>?

  var body: some View {
    ZStack {
      Color.systemBackground
        .onTapGesture { iconBounceCounter += 1 }
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
        icon
          .onTapGesture { iconBounceCounter += 1 }
        message
          .onTapGesture { iconBounceCounter += 1 }
        Spacer()
        button
      }
      .containerRelativeFrame(
        .horizontal,
        count: isHorizontalCompact ? 5 : 2,
        span: isHorizontalCompact ? 4 : 1,
        spacing: 0)
      .padding(.all)
    }
    .hAlignment(.center)
    .task {
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      startAnimation = true
      let hapticsDelay = OnboardingObject.Phase.show.duration + OnboardingObject.Phase.float.duration
      try? await Task.sleep(nanoseconds: UInt64(hapticsDelay * 1_000_000_000))
      SimpleHaptics.generateTask(.soft)
      Task {
        // start repeated icon bounce
        try? await Task.sleep(nanoseconds: UInt64(3 * 1_000_000_000))
        if iconBounceCounter == 0 { iconBounceCounter += 1 }
      }
      Task {
        // repeat button pulse
        repeat {
          try? await Task.sleep(nanoseconds: UInt64(9 * 1_000_000_000))
          startPulse.toggle()
        }
        while true
      }
    }
  }

  private var icon: some View {
    let appIconDisplayMode = IkaAppIcon.DisplayMode.mid

    return
      Image(IkaAppIcon.default.getImageName(appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size,
          height: appIconDisplayMode.size)
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .onChange(of: iconBounceCounter, initial: false) {
          Task {
            try? await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
            await SimpleHaptics.generate(.light)
          }
          // Cancel the previous task, if it exists
          currentTriggerIconBounceAfterDelayTask?.cancel()
          // Schedule a new task
          currentTriggerIconBounceAfterDelayTask = Task {
            await triggerIconBounceAfterDelay()
          }
        }
        .keyframeAnimator(
          initialValue: OnboardingObject.icon.animationValues,
          trigger: startAnimation,
          content: OnboardingObject.keyframeTransformation,
          keyframes: OnboardingObject.iconKeyframes)
        .keyframeAnimator(
          initialValue: OnboardingObject.iconEnd.animationValues,
          trigger: iconBounceCounter,
          content: OnboardingObject.keyframeTransformation,
          keyframes: OnboardingObject.iconExtraKeyframes)
  }

  private var message: some View {
    let appName = Constants.Key.BundleInfo.APP_DISPLAY_NAME
    let message: String = .init(localized: "Welcome to\n\(appName)")
    var messageAttributedString: AttributedString = .init(message)
    let appNameRange = messageAttributedString.range(of: appName)!
    messageAttributedString[appNameRange].foregroundColor = .accentColor

    return
      Text(messageAttributedString)
        .foregroundStyle(.primary)
        .font(Scoped.TITLE_FONT)
        .fontWeight(Scoped.TITLE_FONT_WEIGHT)
        .keyframeAnimator(
          initialValue: OnboardingObject.title.animationValues,
          trigger: startAnimation,
          content: OnboardingObject.keyframeTransformation,
          keyframes: OnboardingObject.titleKeyframes)
  }

  private var button: some View {
    Button {
      SimpleHaptics.generateTask(.success)
      ikaLog.shouldShowOnboarding = false
    } label: {
      Text("Get Started")
        .font(Scoped.BUTTON_FONT)
        .padding(.vertical, Scoped.BUTTON_TEXT_PADDING_V)
        .padding(.horizontal)
        .hAlignment(.center)
    }
    .tint(.accentColor)
    .buttonStyle(.glassProminent)
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

  private func triggerIconBounceAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(9 * 1_000_000_000))
    guard !Task.isCancelled else { return }

    iconBounceCounter += 1
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
      CubicKeyframe(1.0, duration: 0.01)
      CubicKeyframe(0.8, duration: 0.06)
      CubicKeyframe(1.12, duration: 0.1)
      CubicKeyframe(1.04, duration: 0.3)
      CubicKeyframe(1.0, duration: 0.3)
      CubicKeyframe(0.9, duration: 0.22)
      CubicKeyframe(1.02, duration: 0.23)
      CubicKeyframe(1.0, duration: 0.20)
    }

    KeyframeTrack(\.scale) {
      LinearKeyframe(1.0, duration: 0.16)
      SpringKeyframe(1.05, duration: 0.38, spring: .bouncy)
      SpringKeyframe(1.05, duration: 0.27, spring: .smooth)
      SpringKeyframe(1.0, spring: .bouncy(duration: 0.65, extraBounce: 0.1))
    }

    KeyframeTrack(\.vTranslation) {
      SpringKeyframe(10.0, duration: 0.11, spring: .bouncy)
      SpringKeyframe(-10.0, duration: 0.43, spring: .bouncy)
      SpringKeyframe(-12.0, duration: 0.27, spring: .smooth)
      SpringKeyframe(0.0, spring: .bouncy(duration: 0.65, extraBounce: 0.3))
    }
  }
}

#Preview {
  OnboardingView()
}
