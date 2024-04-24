//
//  SettingsAboutView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import StoreKit
import SwiftUI

// MARK: - SettingsAboutView

/// The About page in App Settings.
@MainActor
struct SettingsAboutView: View {
  typealias Scoped = Constants.Style.Settings.About

  @Environment(\.requestReview) private var requestReview
  @Environment(\.openURL) private var openURL
  @Environment(\.dynamicTypeSize) var dynamicTypeSize

  @EnvironmentObject private var ikaLog: IkaLog

  @State private var appStoreOverlayPresented = false

  @State private var rowAppInfoRectGlobal: CGRect = .init()
  @State private var appIconBounceCounter: Int = 0

  @State private var shouldDisplayAnimatedCopy: Bool = false
  @State private var currentToggleAfterDelayTask: Task<Void, Never>?

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
      Task {
        try? await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
        await SimpleHaptics.generate(.light)
      }
      shouldDisplayAnimatedCopy = true
      // Cancel the previous task, if it exists
      currentToggleAfterDelayTask?.cancel()
      // Schedule a new task
      currentToggleAfterDelayTask = Task { await toggleShouldDisplayAnimatedCopyAfterDelay() }
    }
  }

  // MARK: - Icon Section

  private var rowAppInfo: some View {
    let appIconDisplayMode = IkaAppIcon.DisplayMode.large

    var appIconImage: some View {
      Image(IkaAppIcon.default.getImageName(appIconDisplayMode))
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
            .stroke(Scoped.APP_ICON_STROKE_COLOR, lineWidth: Scoped.APP_ICON_STROKE_LINE_WIDTH)
            .opacity(Scoped.APP_ICON_STROKE_OPACITY))
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .zIndex(1)
        .onTapGesture {
          // trigger animation
          appIconBounceCounter += 1
        }
        .apply(applyAppIconBounceAnimation)
    }

    var appIconTitle: some View {
      let title = Constants.Key.BundleInfo.APP_DISPLAY_NAME
      let text =
        Text(title)
          .font(Scoped.APP_ICON_TITLE_FONT)
          .fontWeight(Scoped.APP_ICON_TITLE_FONT_WEIGHT)
          .foregroundStyle(Color.accentColor)
      return text
    }

    var appIconSubtitle: some View {
      let versionNumber = Constants.Key.BundleInfo.APP_VERSION
      let buildNumber = Constants.Key.BundleInfo.APP_BUILD
      let subtitle = "Version \(versionNumber) (\(buildNumber))"
      let text =
        Text(subtitle)
          .font(Scoped.APP_ICON_SUBTITLE_FONT)
          .fontWeight(Scoped.APP_ICON_SUBTITLE_FONT_WEIGHT)
          .foregroundStyle(Color.secondary)
      return text
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
    // NOTE: could not find a way to trigger haptics when tapped ShareLink as of iOS 17.0
    let shareURL = URL(string: Constants.Key.URL.APP_STORE_PAGE)!

    return
      ShareLink(item: shareURL) {
        Label {
          Text("Share ikalendar2")
            .foregroundStyle(Color.primary)
        }
        icon: {
          Image(systemName: Scoped.SHARE_SFSYMBOL)
            .imageScale(.medium)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.accentColor)
        }
      }
  }

  // MARK: - Review Section

  @State private var rowRatingBounceTrigger: Int = 0
  private var bounceTimer = Timer
    .publish(
      every: Constants.Config.Timer.bounceSignalInterval,
      tolerance: 0.1,
      on: .main,
      in: .common)
    .autoconnect()

  private var rowRating: some View {
    Button {
      SimpleHaptics.generateTask(.selection)
      requestReview()
      rowRatingBounceTrigger += 1
      if !ikaLog.hasDiscoveredRating { ikaLog.hasDiscoveredRating = true }
    } label: {
      Label {
        Text("Rate ikalendar2")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.RATING_SFSYMBOL)
          .symbolEffect(.bounce, value: rowRatingBounceTrigger)
          .imageScale(.medium)
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(Color.accentColor)
      }
    }
    .onReceive(bounceTimer) { _ in
      guard !ikaLog.hasDiscoveredRating else { return }

      if rowRatingBounceTrigger >= 2 {
        ikaLog.hasDiscoveredRating = true
      }
      else {
        rowRatingBounceTrigger += 1
      }
    }
  }

  private var rowLeavingReview: some View {
    Button {
      guard let url = URL(string: Constants.Key.URL.APP_STORE_REVIEW) else { return }
      openURL(url)
    } label: {
      Label {
        Text("Leave a Review")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.REVIEW_SFSYMBOL)
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
        Image(systemName: Scoped.VIEW_ON_APP_STORE_SFSYMBOL)
          .imageScale(.large)
          .symbolEffect(.bounce, value: rowAppStoreOverlayBounceCounter)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
    .appStoreOverlay(isPresented: $appStoreOverlayPresented) {
      SKOverlay.AppConfiguration(
        appIdentifier: Constants.Key.BundleInfo.APP_STORE_IDENTIFIER,
        position: .bottom)
    }
    .onChange(of: appStoreOverlayPresented, initial: false) { _, newVal in
      if newVal == true { rowAppStoreOverlayBounceCounter += 1 }
    }
  }

  // MARK: - Contact Section

  private var rowDeveloperTwitter: some View {
    let twitterURLString = Constants.Key.URL.TWITTER_PROFILE
    let twitterHandle = twitterURLString
      .shortenedURL(base: Constants.Key.URL.TWITTER_BASE, newPrefix: "@")!

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
            Image(Scoped.TWITTER_ICON_NAME)
              .antialiased(true)
              .resizable()
              .scaledToFit()
              .frame(
                width: dynamicTypeSize <= .small
                  ? Scoped.TWITTER_ICON_SIZE_SMALL
                  : Scoped.TWITTER_ICON_SIZE_LARGE)
          }

          Spacer()

          Text(twitterHandle)
            .foregroundStyle(Color.secondary)
        }
      }
  }

  private var rowDeveloperEmail: some View {
    Button {
      guard let url = URL(string: Constants.Key.URL.DEVELOPER_EMAIL) else { return }
      openURL(url)
    } label: {
      Label {
        Text("Feedback Email")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.EMAIL_SFSYMBOL)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  // MARK: - Others Section

  private var rowSourceCode: some View {
    let repoName = Constants.Key.BundleInfo.APP_DISPLAY_NAME
    let repoURLString = Constants.Key.URL.SOURCE_CODE_REPO
    let destination =
      DetailsLicenseView(
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
          Image(systemName: Scoped.SOURCE_CODE_SFSYMBOL)
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
          Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
        }
        .tint(Color.accentColor)
      }
  }

  private var rowPrivacyPolicy: some View {
    Button {
      guard let url = URL(string: Constants.Key.URL.PRIVACY_POLICY) else { return }
      openURL(url)
    } label: {
      Label {
        Text("Privacy Policy")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.PRIVACY_POLICY_SFSYMBOL)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  private var rowDebugOptions: some View {
    NavigationLink(destination: SettingsDebugOptionsView()) {
      Label {
        Text("Debug Options")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.DEBUG_OPTIONS_SFSYMBOL)
          .imageScale(.medium)
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  @ScaledMetric(relativeTo: .title) var littleBuddyHeight: CGFloat = Scoped.LITTLE_BUDDY_HEIGHT

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

      Text(Constants.Key.Slogan.IKALENDAR3.localizedStringKey)
        .scaledLimitedLine(lineLimit: 2)
        .ikaFont(
          .ika2,
          size: Scoped.SLOGAN_IKALENDAR3_FONT_SIZE,
          relativeTo: .footnote)
    }
  }

  // MARK: Private

  private func applyAppIconBounceAnimation(_ content: some View) -> some View {
    content
      .keyframeAnimator(
        initialValue: SettingsAboutAppIconAnimationValues(),
        trigger: appIconBounceCounter,
        content: SettingsAboutAppIconAnimationValues.keyframeTransformation,
        keyframes: SettingsAboutAppIconAnimationValues.appIconKeyframes)
  }

  private func toggleShouldDisplayAnimatedCopyAfterDelay() async {
    try? await Task.sleep(nanoseconds: UInt64(1.6 * 1_000_000_000))
    guard !Task.isCancelled else { return }
    shouldDisplayAnimatedCopy = false
  }
}

// MARK: - SettingsAboutAppIconAnimationValues

struct SettingsAboutAppIconAnimationValues {
  var scale: Double = 1
  var vStretch: Double = 1
  var vTranslation: Double = 0

  // MARK: Internal

  @ViewBuilder
  @Sendable
  static func keyframeTransformation(
    content: PlaceholderContentView<some View>,
    values: SettingsAboutAppIconAnimationValues)
    -> some View
  {
    content
      .scaleEffect(values.scale)
      .scaleEffect(y: values.vStretch)
      .offset(y: values.vTranslation)
  }

  @KeyframesBuilder<SettingsAboutAppIconAnimationValues>
  static func appIconKeyframes(start _: SettingsAboutAppIconAnimationValues)
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

// MARK: - SettingsAboutView_Previews

struct SettingsAboutView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAboutView()
      .preferredColorScheme(.dark)
  }
}
