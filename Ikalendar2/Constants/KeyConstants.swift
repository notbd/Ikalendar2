//
//  KeyConstants.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Constant data holding `keys` for the app.
extension Constants.Keys {
  static let appBundleName =
    Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "UNKNOWN"
  static let appDisplayName =
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "UNKNOWN"
  static let appVersion =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  static let appBuildNumber =
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
  static let appStoreIdentifier = "1529193361"

  enum AppStorage {
    static let DEFAULT_GAME_MODE = "PREF_DEFAULT_GAME_MODE"
    static let DEFAULT_BATTLE_MODE = "PREF_DEFAULT_BATTLE_MODE"

    static let COLOR_SCHEME = "PREF_COLOR_SCHEME"

    static let IF_REVERSE_TOOLBAR_PICKERS = "PREF_IF_REVERSE_TOOLBAR_PICKERS"
  }

  enum URL {
    static let BATTLE_ROTATIONS = "https://splatoon2.ink/data/schedules.json"
    static let OATMEALDOME = "https://files.oatmealdome.me/bcat/coop.json"
    static let SALMON_ROTATIONS = "https://splatoon2.ink/data/coop-schedules.json"
    static let TIMELINE = "https://splatoon2.ink/data/timeline.json"

    static let NINTENDO_SPLATOON2_PAGE =
      "https://www.nintendo.com/store/products/splatoon-2-switch/"
    static let DEVELOPER_TWITTER = "https://twitter.com/zhang13music"
    static let DEVELOPER_EMAIL = "mailto:zhang13music@outlook.com"
    static let APP_STORE_PAGE = "https://apps.apple.com/app/id1529193361"
    static let APP_STORE_PAGE_US = "https://apps.apple.com/us/app/ikalendar2/id1529193361"
    static let APP_STORE_REVIEW = "https://apps.apple.com/app/id1529193361?action=write-review"
    static let SOURCE_CODE_REPO = "https://github.com/zhang13music/Ikalendar2"
    static let PRIVACY_POLICY = "https://github.com/zhang13music/Ikalendar2/wiki/Privacy-Policy"

    static let SOME_GOOD_STUFF = "https://www.youtube.com/watch?v=dQw4w9WgXcQ" // Good stuff indeed!
  }

  enum Error {
    enum Title {
      static let SERVER_ERROR = "Server Error"
      static let CONNECTION_ERROR = "Connection Error"
      static let UNKNOWN_ERROR = "Unknown Error"

      static let BAD_RESPONSE = "BAD_STATUS_CODE"
      static let BAD_DATA = "BAD_DATA"
    }

    enum Message {
      static let SERVER_ERROR = { (type: String) in
        """
        The response from the server was invalid. \(type)
        Please try again later or contact support.
        """
      }

      static let CONNECTION_ERROR =
        """
        Unable to connect.
        Please check your internet connection and refresh.
        """
      static let UNKNOWN_ERROR = { (error: String) in
        """
        Ooops...
        An unknown error was encountered ¯\\_(ツ)_/¯
        \(error)
        """
      }

    }
  }
}
