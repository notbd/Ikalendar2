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
    static let SOURCE_CODE_REPO = "https://github.com/zhang13music/ikalendar-2"
    static let PRIVACY_POLICY = "https://github.com/zhang13music/ikalendar-2/wiki/Privacy-Policy"

    static let THE_GOOD_STUFF = "https://www.youtube.com/watch?v=dQw4w9WgXcQ" // Good stuff indeed!
  }

  enum Error {
    enum Title {
      static let UNABLE_TO_COMPLETE = "Connection Error"
      static let INVALID_RESPONSE = "Server Error"
      static let INVALID_DATA = "Server Error"
      static let UNKNOWN_ERROR = "Unknown Error"
    }

    enum Message {
      static let UNABLE_TO_COMPLETE =
        """
        Cannot connect to the server.
        Please check your internet connection and tap the mode icon to refresh.
        """
      static let INVALID_RESPONSE =
        """
        Invalid response from the server.
        If this persists, please contact support.
        """
      static let INVALID_DATA =
        """
        The data received from the server was invalid.
        Please try again later or contact support.
        """
      static let UNKNOWN_ERROR =
        """
        Ooops...
        An unknown error was encountered ¯\\_(ツ)_/¯
        """
    }
  }
}
