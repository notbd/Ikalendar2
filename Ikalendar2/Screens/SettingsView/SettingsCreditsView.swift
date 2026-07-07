//
//  SettingsCreditsView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsCreditsView

/// The Credits page in App Settings.
struct SettingsCreditsView: View {
  typealias Scoped = Constants.Style.Settings.Credits

  @Environment(\.locale) private var currentLocale

  var body: some View {
    List {
      Section {
        rowSplatoon2Ink
        rowJelonzoBot
      } header: { Text("Data Source") }

      Section {
        rowSwiftyJSON
        rowSimpleHaptics
        rowAlertKit
      } header: { Text("Open Source Libraries") }

      Section {
        rowSplatoon2Site
        rowNintendoSite
      } header: { Text("Splatoon 2") } footer: { footerDisclaimer }
    }
    .navigationTitle("Credits")
    .navigationBarTitleDisplayMode(.large)
    .listStyle(.insetGrouped)
  }

  private var rowSplatoon2Ink: some View {
    CreditsExternalLinkCell(
      name: "Splatoon2.ink",
      urlString: Constants.Key.URLs.splatoon2InkDataAccessPolicy,
      shouldShowURL: true)
  }

  private var rowJelonzoBot: some View {
    CreditsExternalLinkCell(
      name: "JelonzoBot",
      urlString: Constants.Key.URLs.jelonzobot,
      shouldShowURL: true)
  }

  /// Honorary credit: the decoding layer moved to native Codable, but SwiftyJSON
  /// carried this project's parsing for years and has earned its place here.
  private var rowSwiftyJSON: some View {
    CreditsOpenSourceLibCell(
      name: "SwiftyJSON",
      urlString: Constants.Key.URLs.githubSwiftyJson,
      isLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "SwiftyJSON",
        repoURLString: Constants.Key.URLs.githubSwiftyJson,
        isLinkable: true))
  }

  private var rowSimpleHaptics: some View {
    CreditsOpenSourceLibCell(
      name: "SimpleHaptics",
      urlString: Constants.Key.URLs.githubSimpleHaptics,
      isLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "SimpleHaptics",
        repoURLString: Constants.Key.URLs.githubSimpleHaptics,
        isLinkable: true))
  }

  private var rowAlertKit: some View {
    CreditsOpenSourceLibCell(
      name: "AlertKit",
      urlString: Constants.Key.URLs.githubAlertKit,
      isLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "AlertKit",
        repoURLString: Constants.Key.URLs.githubAlertKit,
        isLinkable: true))
  }

  private var rowSplatoon2Site: some View {
    CreditsExternalLinkCell(
      name: "Splatoon 2 Official Website",
      urlString: currentLocale.toIkaLocale().splatoon2Site,
      shouldShowURL: true)
  }

  private var rowNintendoSite: some View {
    CreditsExternalLinkCell(
      name: "Nintendo Official Website",
      urlString: currentLocale.toIkaLocale().nintendoSite,
      shouldShowURL: true)
  }

  private var footerDisclaimer: some View {
    Text(Constants.Key.Slogan.copyright.localizedStringKey)
      .ikaFont(
        .ika2,
        size: Scoped.disclaimerFontSize,
        relativeTo: .footnote)
      .padding(.vertical)
  }
}

// MARK: - CreditsExternalLinkCell

struct CreditsExternalLinkCell: View {
  typealias Scoped = Constants.Style.Settings.Credits

  @Environment(\.dynamicTypeSize) var dynamicTypeSize
  @Environment(\.openURL) private var openURL

  let name: String
  let urlString: String
  let shouldShowURL: Bool

  var body: some View {
    Button {
      guard let url = URL(string: urlString) else { return }

      openURL(url)
    } label: {
      HStack {
        VStack(
          alignment: .leading,
          spacing: dynamicTypeSize > .small
            ? Scoped.cellSpacingV
            : Scoped.cellSpacingVSmall)
        {
          Text(name.localizedStringKey)
            .foregroundStyle(Color.primary)
            .font(Scoped.cellContentFontPrimary)

          if shouldShowURL {
            Text(urlString.shortenedURL()!)
              .foregroundStyle(Color.secondary)
              .font(Scoped.cellContentFontSecondary)
          }
        }
        .padding(.vertical, Scoped.cellPaddingV)

        Spacer()

        Constants.Style.Global.externalLinkJumpIcon
          .foregroundStyle(Color.secondary)
      }
    }
  }
}

// MARK: - CreditsOpenSourceLibCell

struct CreditsOpenSourceLibCell<Destination: View>: View {
  typealias Scoped = Constants.Style.Settings.Credits

  @Environment(\.dynamicTypeSize) var dynamicTypeSize
  @Environment(\.openURL) private var openURL

  let name: String
  let urlString: String
  let isLinkable: Bool
  let destination: Destination

  var body: some View {
    NavigationLink(destination: destination) {
      VStack(
        alignment: .leading,
        spacing: dynamicTypeSize > .small
          ? Scoped.cellSpacingV
          : Scoped.cellSpacingVSmall)
      {
        Text(name)
          .foregroundStyle(Color.primary)
          .font(Scoped.cellContentFontPrimary)

        Text(urlString.shortenedURL(base: Constants.Key.URLs.githubBase, newPrefix: "@")!)
          .foregroundStyle(Color.secondary)
          .font(Scoped.cellContentFontSecondary)
      }
      .padding(.vertical, Scoped.cellPaddingV)
    }
    .if(isLinkable) {
      $0
        .swipeActions {
          Button {
            guard let url = URL(string: urlString) else { return }

            openURL(url)
          } label: {
            Constants.Style.Global.externalLinkJumpIcon
          }
          .tint(Color.accentColor)
        }
    }
  }
}

#Preview {
  SettingsCreditsView()
}
