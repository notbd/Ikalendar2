//
//  TimeLengthTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import IkalendarKit

// MARK: - TimeLengthTests

@Suite("TimeLength")
struct TimeLengthTests {
  // MARK: - Initialization Tests

  @Suite("Initialization")
  struct InitializationTests {
    @Test
    func `Initialize with all default values`() {
      let timeLength: TimeLength = .init()

      #expect(timeLength.days == 0)
      #expect(timeLength.hours == 0)
      #expect(timeLength.minutes == 0)
      #expect(timeLength.seconds == 0)
    }

    @Test
    func `Initialize with specific values`() {
      let timeLength: TimeLength = .init(days: 2, hours: 5, minutes: 30, seconds: 45)

      #expect(timeLength.days == 2)
      #expect(timeLength.hours == 5)
      #expect(timeLength.minutes == 30)
      #expect(timeLength.seconds == 45)
    }

    @Test
    func `Initialize with partial values`() {
      let timeLength: TimeLength = .init(hours: 3, minutes: 15)

      #expect(timeLength.days == 0)
      #expect(timeLength.hours == 3)
      #expect(timeLength.minutes == 15)
      #expect(timeLength.seconds == 0)
    }

    @Test
    func `Initialize with negative values`() {
      let timeLength: TimeLength = .init(days: -1, hours: -2, minutes: -30, seconds: -45)

      #expect(timeLength.days == -1)
      #expect(timeLength.hours == -2)
      #expect(timeLength.minutes == -30)
      #expect(timeLength.seconds == -45)
    }
  }

  // MARK: - Localized Description Tests

  /// Exact golden strings. Every test passes an explicit locale, because the default
  /// argument reads `Locale.current`, which differs from runner to runner.
  @Suite("Localized Description")
  struct LocalizedDescriptionTests {
    /// One locale per branch of `localizedSuffixes(for:)` and `separator(for:)`.
    /// zh_CN and zh_TW pin a current quirk: they are on the no-separator list but not on
    /// the suffix list, so they join English suffixes without spaces.
    @Test(arguments: [
      ("en_US", "1d 2h 3m 4s"),
      ("xx_XX", "1d 2h 3m 4s"),
      ("ja_JP", "1日2時間3分4秒"),
      ("ja", "1日2時間3分4秒"),
      ("zh_Hans", "1天2小时3分4秒"),
      ("zh-Hans", "1天2小时3分4秒"),
      ("zh_Hant", "1天2小時3分4秒"),
      ("zh-Hant", "1天2小時3分4秒"),
      ("zh_CN", "1d2h3m4s"),
      ("zh_TW", "1d2h3m4s"),
    ])
    func `Full duration renders exactly per locale`(localeID: String, expected: String) {
      let timeLength: TimeLength = .init(days: 1, hours: 2, minutes: 3, seconds: 4)

      #expect(timeLength.localizedDescription(locale: Locale(identifier: localeID)) == expected)
    }

    /// Components that are not positive are dropped, except seconds, which always render
    /// (with their sign). Covers each component alone, gaps, and large values.
    @Test(arguments: [
      DescriptionRow(timeLength: .init(), english: "0s", japanese: "0秒"),
      DescriptionRow(timeLength: .init(seconds: 45), english: "45s", japanese: "45秒"),
      DescriptionRow(timeLength: .init(minutes: 45), english: "45m 0s", japanese: "45分0秒"),
      DescriptionRow(timeLength: .init(hours: 3), english: "3h 0s", japanese: "3時間0秒"),
      DescriptionRow(timeLength: .init(days: 5), english: "5d 0s", japanese: "5日0秒"),
      DescriptionRow(
        timeLength: .init(hours: 1, minutes: 30),
        english: "1h 30m 0s", japanese: "1時間30分0秒"),
      DescriptionRow(timeLength: .init(days: 2, seconds: 7), english: "2d 7s", japanese: "2日7秒"),
      DescriptionRow(
        timeLength: .init(days: 999, hours: 23, minutes: 59, seconds: 59),
        english: "999d 23h 59m 59s", japanese: "999日23時間59分59秒"),
      DescriptionRow(
        timeLength: .init(days: -1, hours: -2, minutes: -30, seconds: -45),
        english: "-45s", japanese: "-45秒"),
    ])
    func `Only positive components render and seconds always render`(row: DescriptionRow) {
      #expect(row.timeLength.localizedDescription(locale: Locale(identifier: "en_US")) == row.english)
      #expect(row.timeLength.localizedDescription(locale: Locale(identifier: "ja_JP")) == row.japanese)
    }

    @Test
    func `Default locale is the current locale`() {
      let timeLength: TimeLength = .init(hours: 2, minutes: 15, seconds: 30)

      #expect(timeLength.localizedDescription() == timeLength.localizedDescription(locale: .current))
    }
  }
}

// MARK: - DescriptionRow

/// One golden row for `localizedDescription(locale:)`.
struct DescriptionRow: Sendable, CustomTestStringConvertible {
  let timeLength: TimeLength
  let english: String
  let japanese: String

  var testDescription: String { english }
}
