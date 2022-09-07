//
//  SettingsAboutView.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import StoreKit
import SwiftUI

// MARK: - SettingsAboutView

/// The About page in App Settings.
struct SettingsAboutView: View {
  @Environment(\.openURL) var openURL
//  @Environment(\.requestReview) var requestReview

  @State var appStoreOverlayPresented = false

  var body: some View {
    Form {
      Section(header: Spacer()) {
        iconContent
      }
      .listRowBackground(Color.clear)

      Section(header: Text("Share")) {
        rowShare
      }

      Section(header: Text("Contact")) {
        rowDeveloperTwitter
        rowDeveloperEmail
      }

      Section(header: Text("Review")) {
        rowAppStoreOverlay
        rowGiveRate
        rowLeaveReview
      }

      Section(header: Text("Others")) {
        rowSourceCode
        rowPrivacyPolicy
      }
    }
    .navigationTitle("About")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Components ↓↓↓

  // MARK: - Icon Section

  var iconContent: some View {
    HStack {
      Spacer()

      iconLabel

      Spacer()
    }
  }

  var iconLabel: some View {
    var iconImage: some View {
      Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
        .resizable()
        .scaledToFit()
        .frame(width: 120, height: 120)
        .cornerRadius(16)
    }

    var iconTitle: some View {
      let title = "ikalendar2"
      let text =
        Text(title)
          .foregroundColor(.accentColor)
          .fontWeight(.bold)
          .font(.system(.largeTitle, design: .rounded))
      return text
    }

    var iconSubtitle: some View {
      let versionNumber = Constants.Keys.appVersion
      let buildNumber = Constants.Keys.appBuildNumber
      let subtitle = "Version \(versionNumber) (\(buildNumber))"
      let text =
        Text(subtitle)
          .foregroundColor(.secondary)
          .fontWeight(.regular)
          .font(.system(.subheadline, design: .monospaced))
      return text
    }

    return
      VStack(alignment: .center) {
        iconImage
        iconTitle
        iconSubtitle
      }
  }

  // MARK: - Share Section

  var rowShare: some View {
    // NOTE: could not find error handling for invalid URL ShareLink as of iOS 16
    // NOTE: could not find a way to trigger haptics when tapped ShareLink as of iOS 16
    let shareURL = URL(string: Constants.Keys.URL.APP_STORE_PAGE_US)!

    return
      ShareLink(item: shareURL) {
        Label {
          Text("Share ikalendar2")
            .foregroundColor(.primary)
        }
        icon: {
          Image(systemName: "square.and.arrow.up")
        }
      }
  }

  // MARK: - Contact Section

  var rowDeveloperTwitter: some View {
    let twitterURLString = Constants.Keys.URL.DEVELOPER_TWITTER
    let twitterHandle =
      twitterURLString.replacingOccurrences(
        of: "https://twitter.com/",
        with: "@")

    return
      Button {
        Haptics.generate(.selection)
        if let url = URL(string: twitterURLString) {
          openURL(url)
        }
      } label: {
        Label {
          HStack {
            Text("Developer")
              .foregroundColor(.primary)

            Spacer()

            Text(twitterHandle)
              .foregroundColor(.secondary)
          }
        }
        icon: {
          Image("twitter_xsmall")
            .resizable()
            .scaledToFit()
            .frame(width: 16)
        }
      }
  }

  var rowDeveloperEmail: some View {
    Button {
      Haptics.generate(.selection)
      if let url = URL(string: Constants.Keys.URL.DEVELOPER_EMAIL) {
        openURL(url)
      }
    } label: {
      Label {
        Text("Send Feedback Email")
          .foregroundColor(.primary)
      }
      icon: {
        Image(systemName: "envelope")
      }
    }
  }

  // MARK: - Review Section

  var rowAppStoreOverlay: some View {
    Button {
      Haptics.generate(.selection)
      appStoreOverlayPresented.toggle()
    } label: {
      Label {
        Text("View ikalendar2 on the App Store")
          .foregroundColor(.primary)
      }
      icon: {
        Image(systemName: "doc.text.fill.viewfinder")
      }
    }
    .appStoreOverlay(isPresented: $appStoreOverlayPresented) {
      SKOverlay.AppConfiguration(appIdentifier: "1529193361", position: .bottom)
    }
  }

  var rowGiveRate: some View {
    Button {
      Haptics.generate(.selection)
      didTapRate()
    } label: {
      Label {
        Text("Rate on the App Store")
          .foregroundColor(.primary)
      }
      icon: {
        Image(systemName: "star.bubble")
      }
    }
  }

  var rowLeaveReview: some View {
    Button {
      Haptics.generate(.selection)
      if let url = URL(string: Constants.Keys.URL.APP_STORE_REVIEW) {
        openURL(url)
      }
    } label: {
      Label {
        Text("Leave a Review")
          .foregroundColor(.primary)
      }
      icon: {
        Image(systemName: "highlighter")
      }
    }
  }

  // MARK: - Others Section

  var rowSourceCode: some View {
    Button {
      Haptics.generate(.selection)
      if let url = URL(string: Constants.Keys.URL.SOURCE_CODE_REPO) {
        openURL(url)
      }
    } label: {
      Label {
        Text("Source Code")
          .foregroundColor(.primary)
      }
      icon: {
        Image(systemName: "chevron.left.slash.chevron.right")
      }
    }
  }

  var rowPrivacyPolicy: some View {
    Button {
      Haptics.generate(.selection)
      if let url = URL(string: Constants.Keys.URL.PRIVACY_POLICY) {
        openURL(url)
      }
    } label: {
      Label {
        Text("Privacy Policy")
          .foregroundColor(.primary)
      }
      icon: {
        Image(systemName: "hand.raised.fill")
      }
    }
  }

  // MARK: - End Components ↑↑↑

  // MARK: Internal

  /// Handle the tap on the share button. [Deprecated since iOS 16]
//  func didTapShare() {
//    guard let shareURL = URL(string: Constants.Keys.URL.APP_STORE_PAGE_US) else { return }
//    let activityVC =
//      UIActivityViewController(
//        activityItems: [shareURL],
//        applicationActivities: nil)
//    let keyWindow = UIApplication.shared.windows.filter(\.isKeyWindow).first
//    if var topController = keyWindow?.rootViewController {
//      while let presentedViewController = topController.presentedViewController {
//        topController = presentedViewController
//      }
//      topController.present(
//        activityVC,
//        animated: true,
//        completion: nil)
//    }
//  }

  /// Handle the tap on the rate button.
  func didTapRate() {
//    requestReview()
    if
      let scene =
      UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    {
      SKStoreReviewController.requestReview(in: scene)
    }
  }
}

// MARK: - SettingsAboutView_Previews

struct SettingsAboutView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SettingsAboutView()
        .preferredColorScheme(.dark)
    }
  }
}
