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

  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog

  /// Choreography timing, relative to view appearance unless noted.
  private enum Timing {
    /// Beat of stillness before the entrance sequence begins.
    static let entranceDelay: TimeInterval = 1
    /// Entrance runs show + float before the icon lands (haptic moment).
    static let entranceDuration: TimeInterval =
      OnboardingObject.Phase.show.duration + OnboardingObject.Phase.float.duration
    /// First automatic icon bounce, relative to the landing haptic.
    static let firstAutoBounceDelay: TimeInterval = 3
    /// Idle interval between subsequent auto-bounces; a tap restarts the countdown.
    static let autoBounceInterval: TimeInterval = 9
    /// Button pulse period (first pulse waits out the entrance first).
    static let buttonPulseInterval: TimeInterval = 9
    /// Small lag so the bounce haptic lands on the squash, not the tap.
    static let bounceHapticDelay: TimeInterval = 0.1
  }

  @State private var startAnimation: Bool = false
  @State private var startPulse: Bool = false
  @State private var iconBounceCounter: Int = 0

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
    // Entrance sequence: pause, run the keyframe entrance, then a landing haptic
    // and (if the user hasn't tapped yet) the first attention bounce.
    .task {
      try? await Task.sleep(for: .seconds(Timing.entranceDelay))
      startAnimation = true

      try? await Task.sleep(for: .seconds(Timing.entranceDuration))
      guard !Task.isCancelled else { return }

      SimpleHaptics.generateTask(.soft)

      try? await Task.sleep(for: .seconds(Timing.firstAutoBounceDelay))
      guard !Task.isCancelled else { return }

      if iconBounceCounter == 0 { iconBounceCounter += 1 }
    }
    // Button pulse loop. Runs as a child of the view's lifetime - the previous
    // detached Task kept pulsing forever after onboarding was dismissed.
    .task {
      try? await Task.sleep(for: .seconds(Timing.entranceDelay + Timing.entranceDuration))
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(Timing.buttonPulseInterval))
        guard !Task.isCancelled else { return }

        startPulse.toggle()
      }
    }
    // Auto-bounce scheduler: every bounce (tap or automatic) restarts the
    // countdown; replacing the task via id: subsumes the old manual
    // cancel-and-reschedule bookkeeping.
    .task(id: iconBounceCounter) {
      guard iconBounceCounter > 0 else { return }

      try? await Task.sleep(for: .seconds(Timing.autoBounceInterval))
      guard !Task.isCancelled else { return }

      iconBounceCounter += 1
    }
  }

  private var icon: some View {
    let appIconVariant: IkaAppIcon = .default
    let appIconDisplayMode: IkaAppIcon.DisplayMode = .init(color: .default, size: .mid)

    return
      Image(appIconVariant.getImageName(appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size.screenSize,
          height: appIconDisplayMode.size.screenSize)
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .onChange(of: iconBounceCounter, initial: false) {
          // Short-lived by design: delays the haptic onto the squash frame.
          Task {
            try? await Task.sleep(for: .seconds(Timing.bounceHapticDelay))
            await SimpleHaptics.generate(.light)
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
    let appName = Constants.Key.BundleInfo.appDisplayName
    let message: String = .init(localized: "Welcome to\n\(appName)")
    var messageAttributedString: AttributedString = .init(message)
    let appNameRange = messageAttributedString.range(of: appName)!
    messageAttributedString[appNameRange].foregroundColor = .accentColor

    return
      Text(messageAttributedString)
        .foregroundStyle(.primary)
        .font(Scoped.titleFont)
        .fontWeight(Scoped.titleFontWeight)
        .keyframeAnimator(
          initialValue: OnboardingObject.title.animationValues,
          trigger: startAnimation,
          content: OnboardingObject.keyframeTransformation,
          keyframes: OnboardingObject.titleKeyframes)
  }

  private var button: some View {
    Button {
      SimpleHaptics.generateTask(.success)
      ikaDiscoveryLog.shouldShowOnboarding = false
    } label: {
      Text("Get Started")
        .font(Scoped.buttonFont)
        .padding(.vertical, Scoped.buttonTextPaddingV)
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

  /// Entrance: fade/scale in during `.show`, hold through `.float`, then spring up to the resting slot.
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

  /// Entrance: mirrors the icon, offset so the title trails it upward.
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

  /// Entrance: stays hidden through show+float, then springs in as the icon lands.
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

  /// Tap/idle bounce: classic squash-and-stretch - dip, hop with overshoot, settle.
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
