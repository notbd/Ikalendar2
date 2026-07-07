//
//  SettingsAboutView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Combine
import SimpleHaptics
import StoreKit
import SwiftUI

// MARK: - SettingsAboutView

/// The About page in App Settings.
struct SettingsAboutView: View {
  typealias Scoped = Constants.Style.Settings.About

  @Environment(\.requestReview) private var requestReview
  @Environment(\.openURL) private var openURL
  @Environment(\.dynamicTypeSize) var dynamicTypeSize

  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog

  @State private var appStoreOverlayPresented = false

  @State private var rowAppInfoRectGlobal: CGRect = .init()
  @State private var appIconBounceCounter: Int = 0

  @State private var shouldDisplayAnimatedCopy: Bool = false

  /// How long the unclipped overlay copy stays after a bounce (covers the longest keyframe track).
  static private let animatedCopyLinger: TimeInterval = 1.6
  /// Small lag so the bounce haptic lands on the squash, not the tap.
  static private let bounceHapticDelay: TimeInterval = 0.1

  var body: some View {
    ZStack {
      List {
        Section {
          rowAppInfo
            .opacity(shouldDisplayAnimatedCopy ? 0 : 1)
            .background {
              GeometryReader { geo in
                Color.clear
                  .onChange(of: geo.frame(in: .global), initial: true) { _, newValue in
                    rowAppInfoRectGlobal = newValue
                  }
              }
            }
        }
        .listRowBackground(Color.clear)

        Section {
          rowShare
        } header: { Text("Share") }

        Section {
          rowRating
          rowLeavingReview
          rowAppStoreOverlay
        } header: { Text("Review") }

        Section {
          rowDeveloperTwitter
          rowDeveloperEmail
        } header: { Text("Contact") }

        Section {
          rowAppWebsite
          rowSourceCode
          rowPrivacyPolicy
        } header: { Text("App") }

        Section {
          rowDebugOptions
        } footer: { footerIkalendar3 }
      }
      .navigationTitle("About")
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(.insetGrouped)

      // Animated copy
      rowAppInfo
        .frame(width: rowAppInfoRectGlobal.width, height: rowAppInfoRectGlobal.height)
        .globalPosition(x: rowAppInfoRectGlobal.midX, y: rowAppInfoRectGlobal.midY)
        .opacity(shouldDisplayAnimatedCopy ? 1 : 0)
    }
    .onChange(of: appIconBounceCounter, initial: false) {
      // Short-lived by design: delays the haptic onto the squash frame.
      Task {
        try? await Task.sleep(for: .seconds(Self.bounceHapticDelay))
        await SimpleHaptics.generate(.light)
      }
    }
    // While bouncing, the icon escapes its list cell's clip bounds - so hide the
    // original and overlay an unclipped copy at the same spot. Re-triggering
    // restarts the linger window.
    .task(id: appIconBounceCounter) {
      guard appIconBounceCounter > 0 else { return }

      shouldDisplayAnimatedCopy = true
      try? await Task.sleep(for: .seconds(Self.animatedCopyLinger))
      guard !Task.isCancelled else { return }

      shouldDisplayAnimatedCopy = false
    }
  }

  // MARK: - Icon Section

  private var rowAppInfo: some View {
    let appIconVariant: IkaAppIcon = .default
    let appIconDisplayMode: IkaAppIcon.DisplayMode =
      .init(color: .default, size: .large)

    var appIconImage: some View {
      Image(appIconVariant.getImageName(appIconDisplayMode))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: appIconDisplayMode.size.screenSize,
          height: appIconDisplayMode.size.screenSize)
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .zIndex(1)
        .onTapGesture {
          appIconBounceCounter += 1
        }
        // Inlined on the concrete view: wrapping this in a `some View` helper
        // trips a non-Sendable metatype warning from the content closure.
        .keyframeAnimator(
          initialValue: SettingsAboutAppIconAnimationValues(),
          trigger: appIconBounceCounter)
        { content, values in
          content
            .scaleEffect(values.scale)
            .scaleEffect(y: values.vStretch)
            .offset(y: values.vTranslation)
        } keyframes: { _ in
          SettingsAboutAppIconAnimationValues.appIconKeyframes()
        }
    }

    var appIconTitle: some View {
      let title = Constants.Key.BundleInfo.appDisplayName
      return Text(title)
        .font(Scoped.appIconTitleFont)
        .fontWeight(Scoped.appIconTitleFontWeight)
        .foregroundStyle(Color.accentColor)
    }

    var appIconSubtitle: some View {
      let versionNumber = Constants.Key.BundleInfo.appVersion
      let buildNumber = Constants.Key.BundleInfo.appBuild
      let subtitle = "Version \(versionNumber) (\(buildNumber))"
      return Text(subtitle)
        .font(Scoped.appIconSubtitleFont)
        .fontWeight(Scoped.appIconSubtitleFontWeight)
        .foregroundStyle(Color.secondary)
    }

    return
      VStack(alignment: .center) {
        appIconImage
        appIconTitle
        appIconSubtitle
      }
      .hAlignment(.center)
  }

  // MARK: - Share Section

  private var rowShare: some View {
    // NOTE: could not find a way to trigger haptics when tapped ShareLink as of iOS 26
    let shareURL: URL = .init(string: Constants.Key.URLs.appStorePage)!

    return
      ShareLink(item: shareURL) {
        Label {
          Text("Share ikalendar2")
            .foregroundStyle(Color.primary)
        } icon: {
          Image(systemName: Scoped.shareSFSymbol)
            .imageScale(.medium)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.accentColor)
        }
      }
  }

  // MARK: - Review Section

  /// Fires the wiggle once as immediate tap feedback (the periodic hint is iconNudge's job).
  @State private var ratingTapFeedbackTrigger: Int = 0

  private var rowRating: some View {
    Button {
      SimpleHaptics.generateTask(.selection)
      requestReview()
      ratingTapFeedbackTrigger += 1
      if !ikaDiscoveryLog.hasDiscoveredRating { ikaDiscoveryLog.hasDiscoveredRating = true }
    } label: {
      Label {
        Text("Rate ikalendar2")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.ratingSFSymbol)
          .symbolEffect(.wiggle, value: ratingTapFeedbackTrigger)
          .iconNudge(isActive: !ikaDiscoveryLog.hasDiscoveredRating)
          .imageScale(.medium)
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  private var rowLeavingReview: some View {
    Button {
      guard let url = URL(string: Constants.Key.URLs.appStoreReview) else { return }

      openURL(url)
    } label: {
      Label {
        Text("Leave a Review")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.reviewSFSymbol)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  @State private var rowAppStoreOverlayBounceCounter: Int = 0

  private var rowAppStoreOverlay: some View {
    Button {
      SimpleHaptics.generateTask(.selection)
      appStoreOverlayPresented.toggle()
    } label: {
      Label {
        Text("View ikalendar2 on the App Store")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.viewOnAppStoreSFSymbol)
          .imageScale(.large)
          .symbolEffect(.bounce, value: rowAppStoreOverlayBounceCounter)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
    .appStoreOverlay(isPresented: $appStoreOverlayPresented) {
      SKOverlay.AppConfiguration(
        appIdentifier: Constants.Key.BundleInfo.appStoreIdentifier,
        position: .bottom)
    }
    .onChange(of: appStoreOverlayPresented, initial: false) { _, newVal in
      if newVal == true { rowAppStoreOverlayBounceCounter += 1 }
    }
  }

  // MARK: - Contact Section

  private var rowDeveloperTwitter: some View {
    let twitterURLString = Constants.Key.URLs.twitterProfile
    let twitterHandle = twitterURLString
      .shortenedURL(base: Constants.Key.URLs.twitterBase, newPrefix: "@")!

    return
      Button {
        guard let url = URL(string: twitterURLString) else { return }

        openURL(url)
      } label: {
        HStack {
          Label {
            Text("Twitter")
              .foregroundStyle(Color.primary)
          }
          icon: {
            Image(Scoped.twitterIconName)
              .antialiased(true)
              .resizable()
              .scaledToFit()
              .frame(
                width: dynamicTypeSize <= .small
                  ? Scoped.twitterIconSizeSmall
                  : Scoped.twitterIconSizeLarge)
          }

          Spacer()

          Text(twitterHandle)
            .foregroundStyle(Color.secondary)
        }
      }
  }

  private var rowDeveloperEmail: some View {
    Button {
      guard let url = URL(string: Constants.Key.URLs.developerEmail) else { return }

      openURL(url)
    } label: {
      Label {
        Text("Feedback Email")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.emailSFSymbol)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  // MARK: - About App Section

  private var rowAppWebsite: some View {
    Button {
      guard let url = URL(string: Constants.Key.URLs.ikalendar2Website) else { return }

      openURL(url)
    } label: {
      Label {
        Text("App Website")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.appWebsiteSFSymbol)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  private var rowSourceCode: some View {
    let repoName = Constants.Key.BundleInfo.appDisplayName
    let repoURLString = Constants.Key.URLs.sourceCodeRepo
    let destination: DetailsLicenseView =
      .init(
        repoName: repoName,
        repoURLString: repoURLString,
        isLinkable: true)

    return
      NavigationLink(destination: destination) {
        Label {
          Text("Source Code")
            .foregroundStyle(.primary)
        }
        icon: {
          Image(systemName: Scoped.sourceCodeSFSymbol)
            .imageScale(.medium)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.accentColor)
        }
      }
      .swipeActions {
        Button {
          guard let url = URL(string: repoURLString) else { return }

          openURL(url)
        } label: {
          Constants.Style.Global.externalLinkJumpIcon
        }
        .tint(Color.accentColor)
      }
  }

  private var rowPrivacyPolicy: some View {
    Button {
      guard let url = URL(string: Constants.Key.URLs.privacyPolicy) else { return }

      openURL(url)
    } label: {
      Label {
        Text("Privacy Policy")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.privacyPolicySFSymbol)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  // MARK: - Others Section

  private var rowDebugOptions: some View {
    NavigationLink(destination: SettingsDebugOptionsView()) {
      Label {
        Text("Debug Options")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.debugOptionsSFSymbol)
          .imageScale(.medium)
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  @ScaledMetric(relativeTo: .title) var littleBuddyHeight: CGFloat = Scoped.littleBuddyHeight

  private var footerIkalendar3: some View {
    HStack(alignment: .center) {
      Image(.littleBuddy)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .saturation(0.6)
        .frame(height: littleBuddyHeight)
        .padding(.vertical)
        .padding(.trailing, 10)

      Text(Constants.Key.Slogan.ikalendar3.localizedStringKey)
        .scaledLimitedLine(lineLimit: 2)
        .ikaFont(
          .ika2,
          size: Scoped.sloganIkalendar3FontSize,
          relativeTo: .footnote)
    }
  }
}

// MARK: - SettingsAboutAppIconAnimationValues

/// Animatable values for the about-page app icon bounce.
struct SettingsAboutAppIconAnimationValues {
  var scale: Double = 1
  var vStretch: Double = 1
  var vTranslation: Double = 0

  /// Tap bounce: classic squash-and-stretch - dip, big hop with overshoot, settle.
  @KeyframesBuilder<SettingsAboutAppIconAnimationValues>
  static func appIconKeyframes()
    -> some Keyframes<SettingsAboutAppIconAnimationValues>
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
      SpringKeyframe(1.03, duration: 0.38, spring: .bouncy)
      SpringKeyframe(1.03, duration: 0.27, spring: .smooth)
      SpringKeyframe(1.0, spring: .bouncy(duration: 0.65, extraBounce: 0.1))
    }

    KeyframeTrack(\.vTranslation) {
      SpringKeyframe(40.0, duration: 0.11, spring: .bouncy)
      SpringKeyframe(-30.0, duration: 0.43, spring: .bouncy)
      SpringKeyframe(-34.0, duration: 0.27, spring: .smooth)
      SpringKeyframe(0.0, spring: .bouncy(duration: 0.65, extraBounce: 0.3))
    }
  }
}

#Preview("Dark") {
  NavigationStack {
    SettingsAboutView()
  }
  .ikaPreviewEnvironment()
  .preferredColorScheme(.dark)
}

#Preview("Light") {
  NavigationStack {
    SettingsAboutView()
  }
  .ikaPreviewEnvironment()
  .preferredColorScheme(.light)
}
