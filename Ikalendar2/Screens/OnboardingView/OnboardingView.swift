//
//  OnboardingView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - OnboardingView

/// The first-launch welcome screen, dismissed for good by the Get Started button.
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
    // Button pulse loop; ends with the view.
    .task {
      try? await Task.sleep(for: .seconds(Timing.entranceDelay + Timing.entranceDuration))
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(Timing.buttonPulseInterval))
        guard !Task.isCancelled else { return }

        startPulse.toggle()
      }
    }
    // Auto-bounce scheduler: every bounce (tap or automatic) restarts the countdown.
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
      Image(decorative: appIconVariant.imageName(for: appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size.screenSize,
          height: appIconDisplayMode.size.screenSize)
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .squashBounceHaptic(trigger: iconBounceCounter)
        .keyframeAnimator(
          initialValue: OnboardingObject.icon.animationValues,
          trigger: startAnimation,
          content: OnboardingObject.keyframeTransformation,
          keyframes: OnboardingObject.iconKeyframes)
        .squashBounce(trigger: iconBounceCounter, amplitude: .onboarding)
  }

  private var message: some View {
    let appName = Constants.Key.BundleInfo.appDisplayName
    let message: String = .init(localized: "Welcome to\n\(appName)")
    var messageAttributedString: AttributedString = .init(message)
    // Highlight the app name; skip gracefully if a localization ever drops it.
    if let appNameRange = messageAttributedString.range(of: appName) {
      messageAttributedString[appNameRange].foregroundColor = .accentColor
    }

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
          Constants.Motion.buttonPulseOut
        default:
          Constants.Motion.buttonPulseIn
      }
    }
  }
}

// MARK: - OnboardingObject

/// The animatable pieces of the onboarding screen, with their entrance keyframes.
private enum OnboardingObject {
  case icon
  case title
  case button

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

  struct OnboardingAnimationValues {
    var opacity: Double
    var scale: Double
    var vStretch: Double
    var vTranslation: Double
  }

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
}

#Preview {
  OnboardingView()
    .ikaPreviewEnvironment()
}
