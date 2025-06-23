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
    @Test("Initialize with all default values")
    func initializeWithAllDefaultValues() async throws {
      let timeLength = TimeLength()

      #expect(timeLength.days == 0)
      #expect(timeLength.hours == 0)
      #expect(timeLength.minutes == 0)
      #expect(timeLength.seconds == 0)
    }

    @Test("Initialize with specific values")
    func initializeWithSpecificValues() async throws {
      let timeLength = TimeLength(days: 2, hours: 5, minutes: 30, seconds: 45)

      #expect(timeLength.days == 2)
      #expect(timeLength.hours == 5)
      #expect(timeLength.minutes == 30)
      #expect(timeLength.seconds == 45)
    }

    @Test("Initialize with partial values")
    func initializeWithPartialValues() async throws {
      let timeLength = TimeLength(hours: 3, minutes: 15)

      #expect(timeLength.days == 0)
      #expect(timeLength.hours == 3)
      #expect(timeLength.minutes == 15)
      #expect(timeLength.seconds == 0)
    }

    @Test("Initialize with zero values")
    func initializeWithZeroValues() async throws {
      let timeLength = TimeLength(days: 0, hours: 0, minutes: 0, seconds: 0)

      #expect(timeLength.days == 0)
      #expect(timeLength.hours == 0)
      #expect(timeLength.minutes == 0)
      #expect(timeLength.seconds == 0)
    }

    @Test("Initialize with negative values")
    func initializeWithNegativeValues() async throws {
      let timeLength = TimeLength(days: -1, hours: -2, minutes: -30, seconds: -45)

      #expect(timeLength.days == -1)
      #expect(timeLength.hours == -2)
      #expect(timeLength.minutes == -30)
      #expect(timeLength.seconds == -45)
    }
  }

  // MARK: - Localized Description Tests

  @Suite("Localized Description")
  struct LocalizedDescriptionTests {
    @Test("Description with all components present")
    func descriptionWithAllComponentsPresent() async throws {
      let timeLength = TimeLength(days: 1, hours: 2, minutes: 3, seconds: 4)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Description should not be empty")
      // Should contain all components
      #expect(description.contains("1"), "Should contain days value")
      #expect(description.contains("2"), "Should contain hours value")
      #expect(description.contains("3"), "Should contain minutes value")
      #expect(description.contains("4"), "Should contain seconds value")
    }

    @Test("Description with only seconds")
    func descriptionWithOnlySeconds() async throws {
      let timeLength = TimeLength(seconds: 30)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Description should not be empty")
      #expect(description.contains("30"), "Should contain seconds value")
    }

    @Test("Description with zero seconds shows seconds")
    func descriptionWithZeroSecondsShowsSeconds() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 0)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(description.contains("0"), "Should always include seconds, even when zero")
    }

    @Test("Description excludes zero components except seconds")
    func descriptionExcludesZeroComponentsExceptSeconds() async throws {
      let timeLength = TimeLength(days: 0, hours: 0, minutes: 0, seconds: 45)
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
    @Test("English locale uses spaces between components")
    func englishLocaleUsesSpacesBetweenComponents() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 45)
      let englishLocale = Locale(identifier: "en_US")
      let description = timeLength.getLocalizedDescriptionString(locale: englishLocale)

      #expect(description.contains(" "), "English format should contain spaces")
    }

    @Test("Japanese locale joins components without spaces")
    func japaneseLocaleJoinsComponentsWithoutSpaces() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 45)
      let japaneseLocale = Locale(identifier: "ja_JP")
      let description = timeLength.getLocalizedDescriptionString(locale: japaneseLocale)

      // Japanese format should not have spaces between components
      let hasSpaces = description.contains(" ")
      #expect(!hasSpaces, "Japanese format should not contain spaces")
    }

    @Test("Simplified Chinese locale joins components without spaces")
    func simplifiedChineseLocaleJoinsComponentsWithoutSpaces() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 45)
      let chineseSimplifiedLocale = Locale(identifier: "zh_Hans")
      let description = timeLength.getLocalizedDescriptionString(locale: chineseSimplifiedLocale)

      // Chinese format should not have spaces between components
      let hasSpaces = description.contains(" ")
      #expect(!hasSpaces, "Simplified Chinese format should not contain spaces")
    }

    @Test("Traditional Chinese locale joins components without spaces")
    func traditionalChineseLocaleJoinsComponentsWithoutSpaces() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 45)
      let chineseTraditionalLocale = Locale(identifier: "zh_Hant")
      let description = timeLength.getLocalizedDescriptionString(locale: chineseTraditionalLocale)

      // Chinese format should not have spaces between components
      let hasSpaces = description.contains(" ")
      #expect(!hasSpaces, "Traditional Chinese format should not contain spaces")
    }

    @Test("Unknown locale defaults to English format")
    func unknownLocaleDefaultsToEnglishFormat() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 45)
      let unknownLocale = Locale(identifier: "xx_XX")
      let description = timeLength.getLocalizedDescriptionString(locale: unknownLocale)

      #expect(description.contains(" "), "Unknown locale should default to English format with spaces")
    }

    @Test("Different locales produce different output formats")
    func differentLocalesProduceDifferentOutputFormats() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 45)

      let englishDescription = timeLength.getLocalizedDescriptionString(locale: Locale(identifier: "en_US"))
      let japaneseDescription = timeLength.getLocalizedDescriptionString(locale: Locale(identifier: "ja_JP"))

      #expect(englishDescription != japaneseDescription, "Different locales should produce different formats")
    }
  }

  // MARK: - Edge Cases Tests

  @Suite("Edge Cases")
  struct EdgeCasesTests {
    @Test("Large values handled correctly")
    func largeValuesHandledCorrectly() async throws {
      let timeLength = TimeLength(days: 999, hours: 23, minutes: 59, seconds: 59)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Should handle large values")
      #expect(description.contains("999"), "Should contain large days value")
      #expect(description.contains("23"), "Should contain hours value")
      #expect(description.contains("59"), "Should contain minutes value")
    }

    @Test("Negative values handled correctly")
    func negativeValuesHandledCorrectly() async throws {
      let timeLength = TimeLength(days: -1, hours: -2, minutes: -30, seconds: -45)
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Should handle negative values")
      // The description should include the negative values
      #expect(description.contains("-"), "Should contain negative indicators")
    }

    @Test("Zero time length shows only seconds")
    func zeroTimeLengthShowsOnlySeconds() async throws {
      let timeLength = TimeLength()
      let description = timeLength.getLocalizedDescriptionString()

      #expect(!description.isEmpty, "Description should not be empty for zero time")
      #expect(description.contains("0"), "Should show zero seconds")
    }

    @Test("Single unit values work correctly")
    func singleUnitValuesWorkCorrectly() async throws {
      let dayOnly = TimeLength(days: 5)
      let hourOnly = TimeLength(hours: 3)
      let minuteOnly = TimeLength(minutes: 45)
      let secondOnly = TimeLength(seconds: 30)

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
    @Test("Same values produce same description")
    func sameValuesProduceSameDescription() async throws {
      let timeLength1 = TimeLength(days: 1, hours: 2, minutes: 3, seconds: 4)
      let timeLength2 = TimeLength(days: 1, hours: 2, minutes: 3, seconds: 4)

      let description1 = timeLength1.getLocalizedDescriptionString()
      let description2 = timeLength2.getLocalizedDescriptionString()

      #expect(description1 == description2, "Same values should produce identical descriptions")
    }

    @Test("Multiple calls produce consistent results")
    func multipleCallsProduceConsistentResults() async throws {
      let timeLength = TimeLength(hours: 1, minutes: 30, seconds: 45)

      let description1 = timeLength.getLocalizedDescriptionString()
      let description2 = timeLength.getLocalizedDescriptionString()
      let description3 = timeLength.getLocalizedDescriptionString()

      #expect(description1 == description2, "Multiple calls should be consistent")
      #expect(description2 == description3, "Multiple calls should be consistent")
    }

    @Test("Current locale default works correctly")
    func currentLocaleDefaultWorksCorrectly() async throws {
      let timeLength = TimeLength(hours: 2, minutes: 15, seconds: 30)

      let defaultDescription = timeLength.getLocalizedDescriptionString()
      let explicitCurrentDescription = timeLength.getLocalizedDescriptionString(locale: .current)

      #expect(defaultDescription == explicitCurrentDescription, "Default locale should match explicit current locale")
    }
  }
}
