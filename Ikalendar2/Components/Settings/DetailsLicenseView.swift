//
//  DetailsLicenseView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - DetailsLicenseView

struct DetailsLicenseView: View {
  typealias Scoped = Constants.Style.Settings.License

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(\.openURL) private var openURL
  @Environment(\.ikaNetworkService) private var ikaNetworkService

  let repoName: String
  let repoURLString: String
  let isLinkable: Bool

  @State private var licenseViewModel: IkaOpenSourceLicense?
  @State private var hasErrored: Bool = false

  var body: some View {
    ScrollView {
      VStack(spacing: Scoped.CONTENT_SPACING_V) {
        licenseTypeBanner
        licenseContentText
      }
      .padding()
      .redacted(reason: licenseViewModel != nil || hasErrored ? [] : .placeholder)
    }
    .navigationTitle(repoName)
    .navigationBarTitleDisplayMode(.large)
    .if(isLinkable) {
      $0.navigationBarItems(trailing: externalLinkButton)
    }
    .task {
      // .task (unlike .onAppear + Task) is cancelled when the view disappears,
      // so a dismissed screen no longer keeps the request alive.
      try? await Task.sleep(
        nanoseconds:
        UInt64(Constants.Config.License.licenseLoadedDelay * 1_000_000_000))
      guard !Task.isCancelled else { return }

      do {
        licenseViewModel = try await ikaNetworkService.fetchLicense(from: repoURLString)
        SimpleHaptics.generateTask(.light)
      }
      catch is CancellationError {
        // view disappeared - no error state
      }
      catch {
        hasErrored = true
      }
    }
    .animation(
      .default,
      value: licenseViewModel != nil)
  }

  private var licenseTypeBanner: some View {
    HStack {
      Image(systemName: !hasErrored ? Scoped.LICENSE_SFSYMBOL : Scoped.ERROR_SFSYMBOL)
        .font(Scoped.LICENSE_ICON_FONT)
        .fontWeight(Scoped.LICENSE_ICON_FONT_WEIGHT)

      VStack(alignment: .leading) {
        if !hasErrored {
          Text(
            licenseViewModel.map { String(localized: "\($0.gist) be licensed under") }
              ?? Constants.Key.Placeholder.UNKNOWN)
            .foregroundStyle(Color.secondary)
            .font(Scoped.LICENSE_CAPTION_FONT)
            .scaledLimitedLine()
        }

        Text(
          !hasErrored
            ? licenseViewModel?.typeDescription.localizedStringKey
              ?? Constants.Key.Placeholder.UNKNOWN.localizedStringKey
            : Constants.Key.Error.Title.LICENSE_FETCH_ERROR.localizedStringKey)
          .font(Scoped.LICENSE_TYPE_FONT)
          .fontWeight(.bold)
          .scaledLimitedLine()
      }
    }
    .hAlignment(.leading)
  }

  private var licenseContentText: some View {
    var contentText: String {
      if hasErrored { return Constants.Key.Error.Message.LICENSE_FETCH_ERROR }
      return licenseViewModel?.content ?? Constants.Key.Placeholder.LICENSE_TEMPLATE_MIT
    }

    var contentFont: Font {
      hasErrored || !isHorizontalCompact
        ? Scoped.LICENSE_CONTENT_FONT_REGULAR
        : Scoped.LICENSE_CONTENT_FONT_COMPACT
    }

    return
      Text(contentText.localizedStringKey)
        .multilineTextAlignment(.leading)
        .font(contentFont)
        .drawingGroup()
        .hAlignment(.leading)
  }

  private var externalLinkButton: some View {
    Button {
      guard let url = URL(string: repoURLString) else { return }

      openURL(url)
    } label: {
      Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
        .foregroundStyle(Color.primary)
    }
  }
}

// MARK: - LicenseDetailsView_Previews

struct LicenseDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    DetailsLicenseView(
      repoName: "SwiftyJSON",
      repoURLString: "https://github.com/SwiftyJSON/SwiftyJSON",
      isLinkable: true)
  }
}
