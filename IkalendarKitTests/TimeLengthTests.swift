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
    func `Initialize with zero values`() {
      let timeLength: TimeLength = .init(days: 0, hours: 0, minutes: 0, seconds: 0)

      #expect(timeLength.days == 0)
      #expect(timeLength.hours == 0)
      #expect(timeLength.minutes == 0)
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

  @Suite("Localized Description")
  struct LocalizedDescriptionTests {
    @Test
    func `Description with all components present`() {
      let timeLength: TimeLength = .init(days: 1, hours: 2, minutes: 3, seconds: 4)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Description should not be empty")
      // Should contain all components
      #expect(description.contains("1"), "Should contain days value")
      #expect(description.contains("2"), "Should contain hours value")
      #expect(description.contains("3"), "Should contain minutes value")
      #expect(description.contains("4"), "Should contain seconds value")
    }

    @Test
    func `Description with only seconds`() {
      let timeLength: TimeLength = .init(seconds: 30)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Description should not be empty")
      #expect(description.contains("30"), "Should contain seconds value")
    }

    @Test
    func `Description with zero seconds shows seconds`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 0)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(description.contains("0"), "Should always include seconds, even when zero")
    }

    @Test
    func `Description excludes zero components except seconds`() {
      let timeLength: TimeLength = .init(days: 0, hours: 0, minutes: 0, seconds: 45)
      let description = timeLength.getLocalizedDescriptionString()

      // Should only show seconds since other components are zero
      #expect(description.contains("45"), "Should show seconds value")
      // Should be relatively short since only seconds is included
      #expect(description.count < 20, "Should be short when only seconds is present")
    }
  }

  // MARK: - Locale-Specific Formatting Tests

  @Suite("Locale-Specific Formatting")
  struct LocaleSpecificFormattingTests {
    @Test
    func `English locale uses spaces between components`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 45)
      let englishLocale: Locale = .init(identifier: "en_US")
      let description = timeLength.getLocalizedDescriptionString(locale: englishLocale)

      #expect(description.contains(" "), "English format should contain spaces")
    }

    @Test
    func `Japanese locale joins components without spaces`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 45)
      let japaneseLocale: Locale = .init(identifier: "ja_JP")
      let description = timeLength.getLocalizedDescriptionString(locale: japaneseLocale)

      // Japanese format should not have spaces between components
      let hasSpaces = description.contains(" ")
      #expect(!hasSpaces, "Japanese format should not contain spaces")
    }

    @Test
    func `Simplified Chinese locale joins components without spaces`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 45)
      let chineseSimplifiedLocale: Locale = .init(identifier: "zh_Hans")
      let description = timeLength.getLocalizedDescriptionString(locale: chineseSimplifiedLocale)

      // Chinese format should not have spaces between components
      let hasSpaces = description.contains(" ")
      #expect(!hasSpaces, "Simplified Chinese format should not contain spaces")
    }

    @Test
    func `Traditional Chinese locale joins components without spaces`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 45)
      let chineseTraditionalLocale: Locale = .init(identifier: "zh_Hant")
      let description = timeLength.getLocalizedDescriptionString(locale: chineseTraditionalLocale)

      // Chinese format should not have spaces between components
      let hasSpaces = description.contains(" ")
      #expect(!hasSpaces, "Traditional Chinese format should not contain spaces")
    }

    @Test
    func `Unknown locale defaults to English format`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 45)
      let unknownLocale: Locale = .init(identifier: "xx_XX")
      let description = timeLength.getLocalizedDescriptionString(locale: unknownLocale)

      #expect(description.contains(" "), "Unknown locale should default to English format with spaces")
    }

    @Test
    func `Different locales produce different output formats`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 45)

      let englishDescription = timeLength.getLocalizedDescriptionString(locale: Locale(identifier: "en_US"))
      let japaneseDescription = timeLength.getLocalizedDescriptionString(locale: Locale(identifier: "ja_JP"))

      #expect(englishDescription != japaneseDescription, "Different locales should produce different formats")
    }
  }

  // MARK: - Edge Cases Tests

  @Suite("Edge Cases")
  struct EdgeCasesTests {
    @Test
    func `Large values handled correctly`() {
      let timeLength: TimeLength = .init(days: 999, hours: 23, minutes: 59, seconds: 59)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Should handle large values")
      #expect(description.contains("999"), "Should contain large days value")
      #expect(description.contains("23"), "Should contain hours value")
      #expect(description.contains("59"), "Should contain minutes value")
    }

    @Test
    func `Negative values handled correctly`() {
      let timeLength: TimeLength = .init(days: -1, hours: -2, minutes: -30, seconds: -45)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Should handle negative values")
      // The description should include the negative values
      #expect(description.contains("-"), "Should contain negative indicators")
    }

    @Test
    func `Zero time length shows only seconds`() {
      let timeLength: TimeLength = .init()
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Description should not be empty for zero time")
      #expect(description.contains("0"), "Should show zero seconds")
    }

    @Test
    func `Single unit values work correctly`() {
      let dayOnly: TimeLength = .init(days: 5)
      let hourOnly: TimeLength = .init(hours: 3)
      let minuteOnly: TimeLength = .init(minutes: 45)
      let secondOnly: TimeLength = .init(seconds: 30)

      let dayDescription = dayOnly.getLocalizedDescriptionString()
      let hourDescription = hourOnly.getLocalizedDescriptionString()
      let minuteDescription = minuteOnly.getLocalizedDescriptionString()
      let secondDescription = secondOnly.getLocalizedDescriptionString()

      #expect(dayDescription.contains("5"), "Day-only should work")
      #expect(hourDescription.contains("3"), "Hour-only should work")
      #expect(minuteDescription.contains("45"), "Minute-only should work")
      #expect(secondDescription.contains("30"), "Second-only should work")

      // All should also include seconds (always shown)
      #expect(dayDescription.contains("0"), "Day-only should include zero seconds")
      #expect(hourDescription.contains("0"), "Hour-only should include zero seconds")
      #expect(minuteDescription.contains("0"), "Minute-only should include zero seconds")
    }
  }

  // MARK: - Consistency Tests

  @Suite("Consistency Tests")
  struct ConsistencyTests {
    @Test
    func `Same values produce same description`() {
      let timeLength1: TimeLength = .init(days: 1, hours: 2, minutes: 3, seconds: 4)
      let timeLength2: TimeLength = .init(days: 1, hours: 2, minutes: 3, seconds: 4)

      let description1 = timeLength1.getLocalizedDescriptionString()
      let description2 = timeLength2.getLocalizedDescriptionString()

      #expect(description1 == description2, "Same values should produce identical descriptions")
    }

    @Test
    func `Multiple calls produce consistent results`() {
      let timeLength: TimeLength = .init(hours: 1, minutes: 30, seconds: 45)

      let description1 = timeLength.getLocalizedDescriptionString()
      let description2 = timeLength.getLocalizedDescriptionString()
      let description3 = timeLength.getLocalizedDescriptionString()

      #expect(description1 == description2, "Multiple calls should be consistent")
      #expect(description2 == description3, "Multiple calls should be consistent")
    }

    @Test
    func `Current locale default works correctly`() {
      let timeLength: TimeLength = .init(hours: 2, minutes: 15, seconds: 30)

      let defaultDescription = timeLength.getLocalizedDescriptionString()
      let explicitCurrentDescription = timeLength.getLocalizedDescriptionString(locale: .current)

      #expect(defaultDescription == explicitCurrentDescription, "Default locale should match explicit current locale")
    }
  }
}
