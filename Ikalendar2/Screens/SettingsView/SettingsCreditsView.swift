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
@MainActor
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
      urlString: Constants.Key.URL.SPLATOON2_INK_DATA_ACCESS_POLICY,
      shouldShowURL: true)
  }

  private var rowJelonzoBot: some View {
    CreditsExternalLinkCell(
      name: "JelonzoBot",
      urlString: Constants.Key.URL.JELONZOBOT,
      shouldShowURL: true)
  }

  private var rowSwiftyJSON: some View {
    CreditsOpenSourceLibCell(
      name: "SwiftyJSON",
      urlString: Constants.Key.URL.GITHUB_SWIFTY_JSON,
      isLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "SwiftyJSON",
        repoURLString: Constants.Key.URL.GITHUB_SWIFTY_JSON,
        isLinkable: true))
  }

  private var rowSimpleHaptics: some View {
    CreditsOpenSourceLibCell(
      name: "SimpleHaptics",
      urlString: Constants.Key.URL.GITHUB_SIMPLE_HAPTICS,
      isLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "SimpleHaptics",
        repoURLString: Constants.Key.URL.GITHUB_SIMPLE_HAPTICS,
        isLinkable: true))
  }

  private var rowAlertKit: some View {
    CreditsOpenSourceLibCell(
      name: "AlertKit",
      urlString: Constants.Key.URL.GITHUB_ALERT_KIT,
      isLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "AlertKit",
        repoURLString: Constants.Key.URL.GITHUB_ALERT_KIT,
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
    Text(Constants.Key.Slogan.COPYRIGHT.localizedStringKey)
      .ikaFont(
        .ika2,
        size: Scoped.DISCLAIMER_FONT_SIZE,
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
            ? Scoped.CELL_SPACING_V
            : Scoped.CELL_SPACING_V_SMALL)
        {
          Text(name.localizedStringKey)
            .foregroundStyle(Color.primary)
            .font(Scoped.CELL_CONTENT_FONT_PRIMARY)

          if shouldShowURL {
            Text(urlString.shortenedURL()!)
              .foregroundStyle(Color.secondary)
              .font(Scoped.CELL_CONTENT_FONT_SECONDARY)
          }
        }
        .padding(.vertical, Scoped.CELL_PADDING_V)

        Spacer()

        Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
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
          ? Scoped.CELL_SPACING_V
          : Scoped.CELL_SPACING_V_SMALL)
      {
        Text(name)
          .foregroundStyle(Color.primary)
          .font(Scoped.CELL_CONTENT_FONT_PRIMARY)

        Text(urlString.shortenedURL(base: Constants.Key.URL.GITHUB_BASE, newPrefix: "@")!)
          .foregroundStyle(Color.secondary)
          .font(Scoped.CELL_CONTENT_FONT_SECONDARY)
      }
      .padding(.vertical, Scoped.CELL_PADDING_V)
    }
    .if(isLinkable) {
      $0
        .swipeActions {
          Button {
            guard let url = URL(string: urlString) else { return }

            openURL(url)
          } label: {
            Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
          }
          .tint(Color.accentColor)
        }
    }
  }
}

// MARK: - SettingsCreditsView_Previews

struct SettingsCreditsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsCreditsView()
  }
}
