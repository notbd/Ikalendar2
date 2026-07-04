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
      VStack(spacing: Scoped.contentSpacingV) {
        licenseTypeBanner
        licenseContentText
      }
      .padding()
      .redacted(reason: licenseViewModel != nil || hasErrored ? [] : .placeholder)
    }
    .navigationTitle(repoName)
    .navigationBarTitleDisplayMode(.large)
    .if(isLinkable) {
      $0.toolbar {
        ToolbarItem(placement: .topBarTrailing) { externalLinkButton }
      }
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
      Image(systemName: !hasErrored ? Scoped.licenseSFSymbol : Scoped.errorSFSymbol)
        .font(Scoped.licenseIconFont)
        .fontWeight(Scoped.licenseIconFontWeight)

      VStack(alignment: .leading) {
        if !hasErrored {
          Text(
            licenseViewModel.map { String(localized: "\($0.gist) be licensed under") }
              ?? Constants.Key.Placeholder.unknown)
            .foregroundStyle(Color.secondary)
            .font(Scoped.licenseCaptionFont)
            .scaledLimitedLine()
        }

        Text(
          !hasErrored
            ? licenseViewModel?.typeDescription.localizedStringKey
              ?? Constants.Key.Placeholder.unknown.localizedStringKey
            : Constants.Key.Error.Title.licenseFetchError.localizedStringKey)
          .font(Scoped.licenseTypeFont)
          .fontWeight(.bold)
          .scaledLimitedLine()
      }
    }
    .hAlignment(.leading)
  }

  private var licenseContentText: some View {
    var contentText: String {
      if hasErrored { return Constants.Key.Error.Message.licenseFetchError }
      return licenseViewModel?.content ?? Constants.Key.Placeholder.licenseTemplateMit
    }

    var contentFont: Font {
      hasErrored || !isHorizontalCompact
        ? Scoped.licenseContentFontRegular
        : Scoped.licenseContentFontCompact
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
      Constants.Style.Global.externalLinkJumpIcon
        .foregroundStyle(Color.primary)
    }
  }
}

#Preview {
  DetailsLicenseView(
    repoName: "SimpleHaptics",
    repoURLString: "https://github.com/notbd/SimpleHaptics",
    isLinkable: true)
}
