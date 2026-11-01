//
//  DateFormatterExtensionTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import IkalendarKit

// MARK: - DateFormatterExtensionTests

/// Every test passes an explicit locale, and rendering tests pin both the formatter and the
/// fixture to GMT on a Gregorian calendar, so no output depends on the runner's settings.
@Suite("DateFormatter Extensions")
struct DateFormatterExtensionTests {
  // MARK: - Format Patterns

  /// Only identifiers starting with "ja" get the Japanese patterns; every other locale,
  /// including Chinese, falls back to the English patterns.
  @Test(arguments: [
    ("en_US", "h:mm a"),
    ("xx_XX", "h:mm a"),
    ("zh_Hans", "h:mm a"),
    ("fr_FR", "h:mm a"),
    ("ja_JP", "ah:mm"),
    ("ja", "ah:mm"),
  ])
  func `Time formatter picks the pattern per locale`(localeID: String, pattern: String) {
    let formatter: DateFormatter = .init(ikaType: .time, locale: Locale(identifier: localeID))

    #expect(formatter.dateFormat == pattern)
    #expect(formatter.locale.identifier == Locale(identifier: localeID).identifier)
  }

  /// The trailing space is part of the pattern: callers append the time string directly.
  @Test(arguments: [
    ("en_US", "E, M/d, "),
    ("xx_XX", "E, M/d, "),
    ("zh_Hans", "E, M/d, "),
    ("fr_FR", "E, M/d, "),
    ("ja_JP", "M/d(E) "),
    ("ja", "M/d(E) "),
  ])
  func `Date formatter picks the pattern per locale`(localeID: String, pattern: String) {
    let formatter: DateFormatter = .init(ikaType: .date, locale: Locale(identifier: localeID))

    #expect(formatter.dateFormat == pattern)
    #expect(formatter.locale.identifier == Locale(identifier: localeID).identifier)
  }

  @Test
  func `Omitting the locale uses the current locale`() {
    let implicitTime: DateFormatter = .init(ikaType: .time)
    let implicitDate: DateFormatter = .init(ikaType: .date)

    #expect(implicitTime.locale.identifier == Locale.current.identifier)
    #expect(implicitTime.dateFormat == DateFormatter(ikaType: .time, locale: .current).dateFormat)
    #expect(implicitDate.locale.identifier == Locale.current.identifier)
    #expect(implicitDate.dateFormat == DateFormatter(ikaType: .date, locale: .current).dateFormat)
  }

  // MARK: - Rendering

  @Test(arguments: [
    (DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30), "2:30 PM"),
    (DateComponents(year: 2023, month: 12, day: 25, hour: 9, minute: 5), "9:05 AM"),
    (DateComponents(year: 2023, month: 12, day: 25, hour: 0, minute: 0), "12:00 AM"),
    (DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0), "12:00 PM"),
  ])
  func `English time renders exactly`(components: DateComponents, expected: String) throws {
    let rendered: String = try render(.time, localeID: "en_US", components)

    #expect(rendered == expected)
  }

  @Test(arguments: [
    (DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30), "午後2:30"),
    (DateComponents(year: 2023, month: 12, day: 25, hour: 9, minute: 5), "午前9:05"),
    (DateComponents(year: 2023, month: 12, day: 25, hour: 0, minute: 0), "午前12:00"),
    (DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0), "午後12:00"),
  ])
  func `Japanese time renders exactly`(components: DateComponents, expected: String) throws {
    let rendered: String = try render(.time, localeID: "ja_JP", components)

    #expect(rendered == expected)
  }

  @Test(arguments: [
    (DateComponents(year: 2023, month: 10, day: 28, hour: 12), "Sat, 10/28, "),
    (DateComponents(year: 2024, month: 1, day: 5, hour: 12), "Fri, 1/5, "),
  ])
  func `English date renders exactly`(components: DateComponents, expected: String) throws {
    let rendered: String = try render(.date, localeID: "en_US", components)

    #expect(rendered == expected)
  }

  @Test(arguments: [
    (DateComponents(year: 2023, month: 10, day: 28, hour: 12), "10/28(土) "),
    (DateComponents(year: 2024, month: 1, day: 5, hour: 12), "1/5(金) "),
  ])
  func `Japanese date renders exactly`(components: DateComponents, expected: String) throws {
    let rendered: String = try render(.date, localeID: "ja_JP", components)

    #expect(rendered == expected)
  }

  // MARK: - Helpers

  private func render(
    _ type: DateFormatter.IkaDateFormatterType,
    localeID: String,
    _ components: DateComponents) throws
    -> String
  {
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .gmt
    let date: Date = try #require(calendar.date(from: components))

    let formatter: DateFormatter = .init(ikaType: type, locale: Locale(identifier: localeID))
    formatter.timeZone = .gmt
    return formatter.string(from: date)
  }
}
