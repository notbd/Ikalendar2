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

@Suite("DateFormatter Extensions")
struct DateFormatterExtensionTests {
  // MARK: - IkaDateFormatterType Tests

  @Suite("Time Formatter Type")
  struct TimeFormatterTypeTests {
    @Test("Time formatter with English locale produces expected format")
    func timeFormatterWithEnglishLocaleProducesExpectedFormat() throws {
      let formatter: DateFormatter = .init(ikaType: .time, locale: Locale(identifier: "en_US"))

      // Create a specific test date: 2:30 PM
      let testDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30)),
        "Should create valid test date")

      let result = formatter.string(from: testDate)

      // Expected format: "h:mm a" -> "2:30 PM"
      #expect(result == "2:30 PM", "English time format should be '2:30 PM'")
    }

    @Test("Time formatter with Japanese locale produces expected format")
    func timeFormatterWithJapaneseLocaleProducesExpectedFormat() throws {
      let formatter: DateFormatter = .init(ikaType: .time, locale: Locale(identifier: "ja_JP"))

      // Create a specific test date: 2:30 PM
      let testDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30)),
        "Should create valid test date")

      let result = formatter.string(from: testDate)

      // Expected format: "ah:mm" -> "午後2:30"
      #expect(result == "午後2:30", "Japanese time format should be '午後2:30'")
    }

    @Test("Time formatter sets correct date format for English")
    func timeFormatterSetsCorrectDateFormatForEnglish() {
      let formatter: DateFormatter = .init(ikaType: .time, locale: Locale(identifier: "en_US"))

      #expect(formatter.dateFormat == "h:mm a", "English time formatter should use 'h:mm a' format")
    }

    @Test("Time formatter sets correct date format for Japanese")
    func timeFormatterSetsCorrectDateFormatForJapanese() {
      let formatter: DateFormatter = .init(ikaType: .time, locale: Locale(identifier: "ja_JP"))

      #expect(formatter.dateFormat == "ah:mm", "Japanese time formatter should use 'ah:mm' format")
    }
  }

  @Suite("Date Formatter Type")
  struct DateFormatterTypeTests {
    @Test("Date formatter with English locale produces expected format")
    func dateFormatterWithEnglishLocaleProducesExpectedFormat() throws {
      let formatter: DateFormatter = .init(ikaType: .date, locale: Locale(identifier: "en_US"))

      // Create a specific test date: Saturday, October 28, 2023
      let testDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 28)),
        "Should create valid test date")

      let result = formatter.string(from: testDate)

      // Expected format: "E, M/d, " -> "Sat, 10/28, "
      #expect(result == "Sat, 10/28, ", "English date format should be 'Sat, 10/28, '")
    }

    @Test("Date formatter with Japanese locale produces expected format")
    func dateFormatterWithJapaneseLocaleProducesExpectedFormat() throws {
      let formatter: DateFormatter = .init(ikaType: .date, locale: Locale(identifier: "ja_JP"))

      // Create a specific test date: Saturday, October 28, 2023
      let testDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 28)),
        "Should create valid test date")

      let result = formatter.string(from: testDate)

      // Expected format: "M/d(E) " -> "10/28(土) "
      #expect(result == "10/28(土) ", "Japanese date format should be '10/28(土) '")
    }

    @Test("Date formatter sets correct date format for English")
    func dateFormatterSetsCorrectDateFormatForEnglish() {
      let formatter: DateFormatter = .init(ikaType: .date, locale: Locale(identifier: "en_US"))

      #expect(formatter.dateFormat == "E, M/d, ", "English date formatter should use 'E, M/d, ' format")
    }

    @Test("Date formatter sets correct date format for Japanese")
    func dateFormatterSetsCorrectDateFormatForJapanese() {
      let formatter: DateFormatter = .init(ikaType: .date, locale: Locale(identifier: "ja_JP"))

      #expect(formatter.dateFormat == "M/d(E) ", "Japanese date formatter should use 'M/d(E) ' format")
    }
  }

  @Suite("Formatter Type Distinction")
  struct FormatterTypeDistinctionTests {
    @Test("Time and date formatters produce different formats")
    func timeAndDateFormattersProduceDifferentFormats() {
      let timeFormatter: DateFormatter = .init(ikaType: .time)
      let dateFormatter: DateFormatter = .init(ikaType: .date)

      #expect(
        timeFormatter.dateFormat != dateFormatter.dateFormat,
        "Time and date formatters should have different date format strings")
    }

    @Test("Time and date formatters produce different outputs for same date")
    func timeAndDateFormattersProduceDifferentOutputsForSameDate() {
      let timeFormatter: DateFormatter = .init(ikaType: .time)
      let dateFormatter: DateFormatter = .init(ikaType: .date)

      let testDate: Date = .init()

      let timeResult = timeFormatter.string(from: testDate)
      let dateResult = dateFormatter.string(from: testDate)

      #expect(timeResult != dateResult, "Time and date formatters should produce different outputs")
    }
  }
}
