//
//  DetailsLicenseView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - DetailsLicenseView

struct DetailsLicenseView: View {
  typealias Scoped = Constants.Style.Settings.License

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(\.openURL) private var openURL

  let repoName: String
  let repoURLString: String
  let ifLinkable: Bool

  @State private var licenseViewModel: IkaOpenSourceLicense?
  @State private var ifError: Bool = false

  var body: some View {
    ScrollView {
      VStack(spacing: Scoped.CONTENT_SPACING_V) {
        licenseTypeBanner
        licenseContentText
      }
      .padding()
      .redacted(reason: licenseViewModel != nil || ifError ? [] : .placeholder)
    }
    .navigationTitle(repoName)
    .navigationBarTitleDisplayMode(.large)
    .if(ifLinkable) {
      $0.navigationBarItems(trailing: externalLinkButton)
    }
    .onAppear {
      Task {
        try? await Task.sleep(
          nanoseconds:
          UInt64(Constants.Config.License.licenseLoadedDelay * 1_000_000_000))
        do {
          licenseViewModel = try await IkaNetworkManager.shared.fetchLicense(from: repoURLString)
          SimpleHaptics.generateTask(.light)
        }
        catch {
          ifError = true
        }
      }
    }
    .animation(
      .bouncy,
      value: licenseViewModel != nil)
  }

  private var licenseTypeBanner: some View {
    HStack {
      Image(systemName: !ifError ? Scoped.LICENSE_SFSYMBOL : Scoped.ERROR_SFSYMBOL)
        .font(Scoped.LICENSE_ICON_FONT)
        .fontWeight(Scoped.LICENSE_ICON_FONT_WEIGHT)

      VStack(alignment: .leading) {
        if !ifError {
          Text(
            licenseViewModel != nil
              ? String(localized: "\(licenseViewModel!.gist) be licensed under")
              : Constants.Key.Placeholder.UNKNOWN)
            .foregroundStyle(Color.secondary)
            .font(Scoped.LICENSE_CAPTION_FONT)
            .scaledLimitedLine()
        }

        Text(
          !ifError
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
      if ifError { return Constants.Key.Error.Message.LICENSE_FETCH_ERROR }
      return
        licenseViewModel != nil
          ? licenseViewModel!.content
          : Constants.Key.Placeholder.LICENSE_TEMPLATE_MIT
    }

    var contentFont: Font {
      ifError || !isHorizontalCompact
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
    }
  }
}

// MARK: - LicenseDetailsView_Previews

struct LicenseDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    DetailsLicenseView(
      repoName: "SwiftyJSON",
      repoURLString: "https://github.com/SwiftyJSON/SwiftyJSON",
      ifLinkable: true)
  }
}
