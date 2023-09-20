//
//  SettingsAboutView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

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

  @State private var appStoreOverlayPresented = false

  var body: some View {
    List {
      Section {
        rowAppInfo
      }
      .listRowBackground(Color.clear)

      Section(header: Text("Share")) {
        rowShare
      }

      Section(header: Text("Review")) {
        rowRating
        rowLeavingReview
        rowAppStoreOverlay
      }

      Section(header: Text("Contact")) {
        rowDeveloperTwitter
        rowDeveloperEmail
      }

      Section(header: Text("Others")) {
        rowSourceCode
        rowPrivacyPolicy
      }
    }
    .navigationTitle("About")
    .navigationBarTitleDisplayMode(.inline)
    .listStyle(.insetGrouped)
  }

  // MARK: - Icon Section

  private var rowAppInfo: some View {
    var appIconImage: some View {
      Image(IkaAppIcon.defaultIcon.getImageName(.mid))
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .frame(
          width: IkaAppIcon.DisplayMode.mid.sideLen,
          height: IkaAppIcon.DisplayMode.mid.sideLen)
        .clipShape(
          IkaAppIcon.DisplayMode.mid.clipShape)
        .overlay(
          IkaAppIcon.DisplayMode.mid.clipShape
            .stroke(Scoped.STROKE_COLOR, lineWidth: Scoped.STROKE_LINE_WIDTH)
            .opacity(Scoped.STROKE_OPACITY))
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
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
    // NOTE: could not find a way to trigger haptics when tapped ShareLink as of iOS 16
    let shareURL = URL(string: Constants.Key.URL.APP_STORE_PAGE_US)!

    return
      ShareLink(item: shareURL) {
        Label {
          Text("Share ikalendar2")
            .foregroundStyle(Color.primary)
        }
        icon: {
          Image(systemName: Scoped.SHARE_SFSYMBOL)
            .font(.subheadline)
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Color.accentColor)
        }
      }
  }

  // MARK: - Review Section

  private var rowRating: some View {
    Button {
      SimpleHaptics.generateTask(.selection)
      Task { await requestReview() }
    } label: {
      Label {
        Text("Rate ikalendar2")
          .foregroundStyle(Color.primary)
      }
      icon: {
        Image(systemName: Scoped.RATING_SFSYMBOL)
          .font(.subheadline)
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(Color.accentColor)
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
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

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
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
    .appStoreOverlay(isPresented: $appStoreOverlayPresented) {
      SKOverlay.AppConfiguration(
        appIdentifier: Constants.Key.BundleInfo.APP_STORE_IDENTIFIER,
        position: .bottom)
    }
  }

  // MARK: - Contact Section

  private var rowDeveloperTwitter: some View {
    let twitterURLString = Constants.Key.URL.DEVELOPER_TWITTER
    let twitterHandle = twitterURLString
      .shortenedURL(base: Constants.Key.URL.TWITTER_BASE, newPrefix: "@")!

    return
      Button {
        guard let url = URL(string: twitterURLString) else { return }
        openURL(url)
      } label: {
        HStack {
          Label {
            Text("Developer's Twitter")
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
          .font(.subheadline)
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
        ifLinkable: true)

    return
      NavigationLink(destination: destination) {
        Label {
          Text("Source Code")
            .foregroundStyle(.primary)
        }
        icon: {
          Image(systemName: Scoped.SOURCE_CODE_SFSYMBOL)
            .font(.subheadline)
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
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
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
