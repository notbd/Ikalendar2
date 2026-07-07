//
//  KeyConstants.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Constant data holding `key`s for the app.
extension Constants.Key {
  enum BundleInfo {
    static let appBundleName =
      Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Constants.Key.Placeholder.unknown
    static let appDisplayName =
      Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Constants.Key.Placeholder.unknown
    static let appVersion =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? Constants.Key.Placeholder
        .unknown
    static let appBuild =
      Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? Constants.Key.Placeholder.unknown
    static let appStoreIdentifier = "1529193361"
  }

  enum AppStorage {
    static let preferredDefaultFlatMode = "pref.preferred_default.flat_mode"
    static let preferredDefaultGameMode = "pref.preferred_default.game_mode"
    static let preferredDefaultBattleMode = "pref.preferred_default.battle_mode"
    static let preferredAppColorScheme = "pref.preferred_app_color_scheme"
    static let preferredAppIcon = "pref.preferred_app_icon"

    static let shouldMinimizeTabBar = "pref.if_should_minimize_tab_bar"
    static let shouldSwapBottomToolbarPickers = "pref.if_should_swap_bottom_toolbar_pickers"
    static let shouldUseAltStageImages = "pref.if_should_use_alt_stage_images"

    /// Log
    static let shouldShowOnboarding = "pref.if_should_show_onboarding"
    static let hasDiscoveredRating = "pref.if_has_discovered_rating"
    static let hasDiscoveredAltAppIcon = "pref.if_has_discovered_alt_app_icon"
    static let hasDiscoveredEasterEgg = "pref.if_has_discovered_easter_egg"
  }

  enum URLs {
    static let battleRotations = "https://splatoon2.ink/data/schedules.json"
    static let salmonRotations = "https://splatoon2.ink/data/coop-schedules.json"
    static let salmonApparelInfo = "https://splatoon2.ink/data/timeline.json"

    static let twitterBase = "https://twitter.com"
    static let githubBase = "https://github.com"

    static let ikalendar2Website = "https://ikalendar.app"
    static let twitterProfile = "https://twitter.com/ikalendar_app"
    static let developerEmail = "mailto:ikalendar2@tianwei.io"
    static let appStorePage = "https://apps.apple.com/app/id1529193361"
    static let appStorePageUS = "https://apps.apple.com/us/app/ikalendar2/id1529193361"
    static let appStoreReview = "https://apps.apple.com/app/id1529193361?action=write-review"
    static let sourceCodeRepo = "https://github.com/notbd/Ikalendar2"
    static let privacyPolicy = "https://ikalendar.app/privacy-policy"

    static let theGoodStuff = "https://yout-ube.com/watch?v=dQw4w9WgXcQ" // good stuff indeed!
    static let theGoodStuffCN = "https://bilibili.com/video/BV1GJ411x7h7"

    static let splatoon2InkDataAccessPolicy =
      "https://github.com/misenhower/splatoon2.ink/wiki/Data-access-policy#data-urls"
    static let jelonzobot = "https://splatoon.oatmealdome.me/about"

    static let githubSwiftyJson = "https://github.com/SwiftyJSON/SwiftyJSON"
    static let githubSimpleHaptics = "https://github.com/notbd/SimpleHaptics"
    static let githubAlertKit = "https://github.com/sparrowcode/AlertKit"

    enum Splatoon2Site {
      static let en = "https://nintendo.com/my/switch/aab6/index.html"
      static let ja = "https://nintendo.co.jp/switch/aab6a/index.html"
      static let zhHans = "https://nintendo.tw/splatoon2/"
      static let zhHant = "https://nintendo.tw/splatoon2/"
    }

    enum NintendoSite {
      static let en = "https://nintendo.com/"
      static let ja = "https://nintendo.co.jp/"
      static let zhHans = "https://nintendoswitch.com.cn/"
      static let zhHant = "https://nintendo.tw/"
    }
  }

  enum Locale {
    static let en = "English"
    static let ja = "日本語"
    static let zhHans = "简体中文(beta)"
    static let zhHant = "繁體中文(beta)"
  }

  enum Slogan {
    static let copyright = "key.slogan.copyright"
    static let ikalendar3 = "key.slogan.ikalendar3"
  }

  enum Error {
    enum Title {
      static let serverError = "key.title.server_error"
      static let connectionError = "key.title.connection_error"
      static let unknownError = "key.title.unknown_error"
      static let maxAttemptsExceeded = "key.title.max_attempts_exceeded" // not used for now
      static let licenseFetchError = "key.title.license_fetch_error"
    }

    enum Message {
      static let serverErrorBadResponse = "key.message.server_error.bad_response"
      static let serverErrorBadData = "key.message.server_error.bad_data"
      static let connectionError = "key.message.connection_error"
      static let unknownError = "key.message.unknown_error"
      static let maxAttemptsExceeded = "key.message.max_attempts_exceeded" // not used for now
      static let licenseFetchError = "key.message.license_fetch_error"
    }
  }

  enum Placeholder {
    static let unknown = "Unknown"
    static let error = "Error"
    static let licenseTemplateMit = """
      MIT License

      Copyright (c) <YEAR> <COPYRIGHT HOLDER>

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in all
      copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      SOFTWARE.

      """
  }
}
