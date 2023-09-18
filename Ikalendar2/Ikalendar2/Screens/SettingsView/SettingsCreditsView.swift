//
//  SettingsCreditsView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsCreditsView

/// The Credits page in App Settings.
struct SettingsCreditsView: View {
  @Environment(\.locale) private var currentLocale

  var body: some View {
    List {
      Section(header: Text("Data Source")) {
        rowSplatoon2Ink
        rowJelonzoBot
      }

      Section(header: Text("Open Source Libraries")) {
        rowSwiftyJSON
        rowSimpleHaptics
        rowVariableBlurView
      }

      Section(
        header: Text("Splatoon™ 2"),
        footer: disclaimer)
      {
        rowSplatoon2Site
        rowNintendoSite
      }
    }
    .navigationTitle("Credits")
    .navigationBarTitleDisplayMode(.large)
    .listStyle(.insetGrouped)
  }

  private var rowSplatoon2Ink: some View {
    CreditsExternalLinkCell(
      name: "Splatoon2.ink",
      urlString: "https://splatoon2.ink/about",
      ifShowURL: true)
  }

  private var rowJelonzoBot: some View {
    CreditsExternalLinkCell(
      name: "JelonzoBot",
      urlString: "https://splatoon.oatmealdome.me/about",
      ifShowURL: true)
  }

  private var rowSwiftyJSON: some View {
    CreditsOpenSourceLibCell(
      name: "SwiftyJSON",
      urlString: "https://github.com/SwiftyJSON/SwiftyJSON",
      ifLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "SwiftyJSON",
        repoURLString: "https://github.com/SwiftyJSON/SwiftyJSON",
        ifLinkable: true))
  }

  private var rowSimpleHaptics: some View {
    CreditsOpenSourceLibCell(
      name: "SimpleHaptics",
      urlString: "https://github.com/notbd/SimpleHaptics",
      ifLinkable: true,
      destination:
      DetailsLicenseView(
        repoName: "SimpleHaptics",
        repoURLString: "https://github.com/notbd/SimpleHaptics",
        ifLinkable: true))
  }

  private var rowVariableBlurView: some View {
    CreditsOpenSourceLibCell(
      name: "VariableBlurView",
      urlString: "https://github.com/aheze/VariableBlurView/",
      ifLinkable: false,
      destination:
      DetailsLicenseView(
        repoName: "VariableBlurView",
        repoURLString: "https://github.com/aheze/VariableBlurView/",
        ifLinkable: false))
  }

  private var rowSplatoon2Site: some View {
    CreditsExternalLinkCell(
      name: "Splatoon™ 2 Official Website",
      urlString: currentLocale.toIkaLocale().splatoon2Site,
      ifShowURL: true)
  }

  private var rowNintendoSite: some View {
    CreditsExternalLinkCell(
      name: "Nintendo® Official Website",
      urlString: currentLocale.toIkaLocale().nintendoSite,
      ifShowURL: true)
  }

  private var disclaimer: some View {
    Text(Constants.Key.Disclaimer.COPYRIGHT.localizedStringKey)
      .ikaFont(
        .ika2,
        size: 12,
        relativeTo: .footnote)
  }
}

// MARK: - CreditsExternalLinkCell

struct CreditsExternalLinkCell: View {
  typealias Scoped = Constants.Style.Settings.Credits

  @Environment(\.openURL) private var openURL

  let name: String
  let urlString: String
  let ifShowURL: Bool

  var body: some View {
    Button {
      guard let url = URL(string: urlString) else { return }
      openURL(url)
    } label: {
      HStack {
        VStack(
          alignment: .leading,
          spacing: Scoped.CELL_SPACING_V)
        {
          Text(name.localizedStringKey)
            .foregroundColor(.primary)
            .font(.system(Scoped.CONTENT_FONT_PRIMARY, design: .rounded).bold())

          if ifShowURL {
            Text(urlString.shortenedURL()!)
              .foregroundColor(.secondary)
              .font(.system(Scoped.CONTENT_FONT_SECONDARY, design: .rounded))
          }
        }

        Spacer()

        Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
      }
    }
  }
}

// MARK: - CreditsOpenSourceLibCell

struct CreditsOpenSourceLibCell<Destination: View>: View {
  typealias Scoped = Constants.Style.Settings.Credits

  @Environment(\.openURL) private var openURL

  let name: String
  let urlString: String
  let ifLinkable: Bool
  let destination: Destination

  var body: some View {
    NavigationLink(destination: destination) {
      VStack(
        alignment: .leading,
        spacing: Scoped.CELL_SPACING_V)
      {
        Text(name)
          .foregroundColor(.primary)
          .font(.system(Scoped.CONTENT_FONT_PRIMARY, design: .rounded).bold())

        Text(urlString.shortenedURL(base: Constants.Key.URL.GITHUB_BASE, newPrefix: "@")!)
          .foregroundColor(.secondary)
          .font(.system(Scoped.CONTENT_FONT_SECONDARY, design: .rounded))
      }
    }
    .if(ifLinkable) {
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
