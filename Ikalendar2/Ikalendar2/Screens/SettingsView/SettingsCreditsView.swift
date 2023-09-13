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
  var body: some View {
    List {
      Section(header: Text("Data Source")) {
        rowSplatoon2Ink
        rowJelonzoBot
      }

      Section(header: Text("Open Source Libraries")) {
        rowSwiftyJSON
        rowSimpleHaptics
      }
    }
    .navigationTitle("Credits")
    .navigationBarTitleDisplayMode(.large)
    .listStyle(.insetGrouped)
  }

  private var rowSplatoon2Ink: some View {
    CreditsDataSourceCell(
      name: "Splatoon2.ink",
      urlString: "https://splatoon2.ink/about")
  }

  private var rowJelonzoBot: some View {
    CreditsDataSourceCell(
      name: "JelonzoBot",
      urlString: "https://splatoon.oatmealdome.me/about")
  }

  private var rowSwiftyJSON: some View {
    CreditsOpenSourceLibCell(
      name: "SwiftyJSON",
      urlString: "https://github.com/SwiftyJSON/SwiftyJSON",
      destination:
      DetailsLicenseView(
        repoName: "SwiftyJSON",
        repoURLString: "https://github.com/SwiftyJSON/SwiftyJSON"))
  }

  private var rowSimpleHaptics: some View {
    CreditsOpenSourceLibCell(
      name: "SimpleHaptics",
      urlString: "https://github.com/notbd/SimpleHaptics",
      destination:
      DetailsLicenseView(
        repoName: "SimpleHaptics",
        repoURLString: "https://github.com/notbd/SimpleHaptics"))
  }
}

// MARK: - CreditsDataSourceCell

struct CreditsDataSourceCell: View {
  typealias Scoped = Constants.Style.Settings.Credits

  @Environment(\.openURL) private var openURL

  let name: String
  let urlString: String

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
          Text(name)
            .foregroundColor(.primary)
            .font(.system(Scoped.CONTENT_FONT_PRIMARY, design: .rounded))

          Text(urlString.shortenedURL()!)
            .foregroundColor(.secondary)
            .font(.system(Scoped.CONTENT_FONT_SECONDARY, design: .rounded))
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
  let destination: Destination

  var body: some View {
    NavigationLink(destination: destination) {
      VStack(
        alignment: .leading,
        spacing: Scoped.CELL_SPACING_V)
      {
        Text(name)
          .foregroundColor(.primary)
          .font(.system(Scoped.CONTENT_FONT_PRIMARY, design: .rounded))

        Text(urlString.shortenedURL(base: Constants.Key.URL.GITHUB_BASE, newPrefix: "@")!)
          .foregroundColor(.secondary)
          .font(.system(Scoped.CONTENT_FONT_SECONDARY, design: .rounded))
      }
    }
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

// MARK: - SettingsCreditsView_Previews

struct SettingsCreditsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsCreditsView()
  }
}
