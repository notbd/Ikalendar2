//
//  DateExtensionTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SwiftUI
import Testing
@testable import IkalendarKit

// MARK: - DateExtensionTests

@Suite("Date Extensions")
struct DateExtensionTests {
  // MARK: - Date Subtraction Tests

  @Suite("Date Subtraction")
  struct DateSubtractionTests {
    @Test("Date subtraction returns correct time interval")
    func dateSubtractionReturnsCorrectInterval() {
      let date1: Date = .init(timeIntervalSince1970: 1000)
      let date2: Date = .init(timeIntervalSince1970: 500)

      let result = date1 - date2
      #expect(result == 500.0, "Date subtraction should return the correct time interval")
    }

    @Test("Date subtraction with same dates returns zero")
    func dateSubtractionWithSameDatesReturnsZero() {
      let date: Date = .init()
      let result = date - date
      #expect(result == 0.0, "Subtracting same date should return zero")
    }

    @Test("Date subtraction with past date returns negative value")
    func dateSubtractionWithPastDateReturnsNegative() {
      let futureDate: Date = .init(timeIntervalSince1970: 1000)
      let pastDate: Date = .init(timeIntervalSince1970: 2000)

      let result = futureDate - pastDate
      #expect(result == -1000.0, "Subtracting a future date from a past date should return negative value")
    }
  }

  // MARK: - Remove Minutes Tests

  @Suite("Remove Minutes")
  struct RemoveMinutesTests {
    @Test("Remove minutes sets minutes, seconds, and nanoseconds to zero")
    func removeMinutesSetsToZero() throws {
      let calendar: Calendar = .current
      let originalDate = try #require(calendar.date(from: DateComponents(
        year: 2023, month: 12, day: 25,
        hour: 14, minute: 30, second: 45)))

      let result = try #require(originalDate.removeMinutes(), "removeMinutes should not return nil for valid date")

      let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: result)
      #expect(components.year == 2023)
      #expect(components.month == 12)
      #expect(components.day == 25)
      #expect(components.hour == 14)
      #expect(components.minute == 0)
      #expect(components.second == 0)
    }

    @Test("Remove minutes preserves year, month, day, and hour")
    func removeMinutesPreservesComponents() throws {
      let calendar: Calendar = .current
      let originalDate = try #require(calendar.date(from: DateComponents(
        year: 2024, month: 6, day: 15,
        hour: 9, minute: 45, second: 30)))

      let result = try #require(originalDate.removeMinutes(), "removeMinutes should not return nil for valid date")

      let components = calendar.dateComponents([.year, .month, .day, .hour], from: result)
      #expect(components.year == 2024)
      #expect(components.month == 6)
      #expect(components.day == 15)
      #expect(components.hour == 9)
    }
  }

  // MARK: - Battle Time String Tests

  @Suite("Battle Time String")
  struct BattleTimeStringTests {
    @Test("Battle time string without date returns only time")
    func battleTimeStringWithoutDateReturnsTime() throws {
      let testDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30)),
        "Should be able to create test date")
      let result = testDate.toBattleTimeString()

      // Should not contain localized date words - test by checking it's relatively short (time only)
      #expect(result.count < 20, "Time-only string should be relatively short")
      #expect(!result.isEmpty, "Result should not be empty")
    }

    @Test("Battle time string with date includes 'Today' for today's date")
    func battleTimeStringWithTodayReturnsToday() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      // Create a date that is the same day as our reference
      let todayDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30)),
        "Should be able to create today's date")

      let result = todayDate.toBattleTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      // For today's date, should contain "Today"
      let localizedToday: String = .init(localized: "Today")
      #expect(result.contains(localizedToday), "Should contain localized 'Today' for current date")
      #expect(result.count > 10, "Should be longer than time-only string")
    }

    @Test("Battle time string with date includes 'Yesterday' for yesterday's date")
    func battleTimeStringWithYesterdayReturnsYesterday() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      let yesterdayDate = try #require(
        Calendar.current.date(byAdding: .day, value: -1, to: referenceDate),
        "Should be able to create yesterday's date")

      let result = yesterdayDate.toBattleTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      let localizedYesterday: String = .init(localized: "Yesterday")
      #expect(result.contains(localizedYesterday), "Should contain localized 'Yesterday' for yesterday's date")
    }

    @Test("Battle time string with date includes 'Tomorrow' for tomorrow's date")
    func battleTimeStringWithTomorrowReturnsTomorrow() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      let tomorrowDate = try #require(
        Calendar.current.date(byAdding: .day, value: 1, to: referenceDate),
        "Should be able to create tomorrow's date")

      let result = tomorrowDate.toBattleTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      let localizedTomorrow: String = .init(localized: "Tomorrow")
      #expect(result.contains(localizedTomorrow), "Should contain localized 'Tomorrow' for tomorrow's date")
    }

    @Test("Battle time string with distant date returns time only")
    func battleTimeStringWithDistantDateReturnsTimeOnly() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      // Test with a date that's definitely not today/yesterday/tomorrow relative to reference
      let distantDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 30, hour: 10, minute: 45)),
        "Should be able to create distant date")

      let result = distantDate.toBattleTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      // Should not contain relative date localizations for distant dates
      let localizedToday: String = .init(localized: "Today")
      let localizedYesterday: String = .init(localized: "Yesterday")
      let localizedTomorrow: String = .init(localized: "Tomorrow")

      #expect(!result.contains(localizedToday), "Should not contain 'Today' for distant dates")
      #expect(!result.contains(localizedYesterday), "Should not contain 'Yesterday' for distant dates")
      #expect(!result.contains(localizedTomorrow), "Should not contain 'Tomorrow' for distant dates")
    }

    @Test("Battle time string format consistency across locales")
    func battleTimeStringFormatConsistencyAcrossLocales() throws {
      let testDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30)),
        "Should be able to create test date")

      // Test without date inclusion first
      let timeOnly = testDate.toBattleTimeString(shouldIncludeDate: false)
      #expect(!timeOnly.isEmpty, "Time-only string should not be empty")

      // Test with date inclusion
      let withDate = testDate.toBattleTimeString(shouldIncludeDate: true)
      #expect(withDate.count >= timeOnly.count, "String with date should be at least as long as time-only")
    }
  }

  // MARK: - Salmon Time String Tests

  @Suite("Salmon Time String")
  struct SalmonTimeStringTests {
    @Test("Salmon time string without date returns only time")
    func salmonTimeStringWithoutDateReturnsTime() throws {
      let testDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30)),
        "Should be able to create test date")
      let result = testDate.toSalmonTimeString()

      // Should be relatively short (time only)
      #expect(result.count < 20, "Time-only string should be relatively short")
      #expect(!result.isEmpty, "Result should not be empty")
    }

    @Test("Salmon time string with today's date includes 'Today'")
    func salmonTimeStringWithTodayReturnsToday() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      // Create a date that is the same day as our reference
      let todayDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30)),
        "Should be able to create today's date")

      let result = todayDate.toSalmonTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      let localizedToday: String = .init(localized: "Today")
      #expect(result.contains(localizedToday), "Should contain localized 'Today' for current date")
    }

    @Test("Salmon time string with yesterday's date includes 'Yesterday'")
    func salmonTimeStringWithYesterdayReturnsYesterday() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      let yesterdayDate = try #require(
        Calendar.current.date(byAdding: .day, value: -1, to: referenceDate),
        "Should be able to create yesterday's date")

      let result = yesterdayDate.toSalmonTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      let localizedYesterday: String = .init(localized: "Yesterday")
      #expect(result.contains(localizedYesterday), "Should contain localized 'Yesterday' for yesterday's date")
    }

    @Test("Salmon time string with tomorrow's date includes 'Tomorrow'")
    func salmonTimeStringWithTomorrowReturnsTomorrow() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      let tomorrowDate = try #require(
        Calendar.current.date(byAdding: .day, value: 1, to: referenceDate),
        "Should be able to create tomorrow's date")

      let result = tomorrowDate.toSalmonTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      let localizedTomorrow: String = .init(localized: "Tomorrow")
      #expect(result.contains(localizedTomorrow), "Should contain localized 'Tomorrow' for tomorrow's date")
    }

    @Test("Salmon time string with distant date includes full date")
    func salmonTimeStringWithDistantDateIncludesFullDate() throws {
      // Use a fixed reference date
      let referenceDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create reference date")

      // Test with a date that's definitely not today/yesterday/tomorrow relative to reference
      let distantDate = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 30, hour: 10, minute: 45)),
        "Should be able to create distant date")

      let result = distantDate.toSalmonTimeString(shouldIncludeDate: true, currentTime: referenceDate)

      // Should not contain relative date localizations for distant dates
      let localizedToday: String = .init(localized: "Today")
      let localizedYesterday: String = .init(localized: "Yesterday")
      let localizedTomorrow: String = .init(localized: "Tomorrow")

      #expect(!result.contains(localizedToday), "Should not contain 'Today' for distant dates")
      #expect(!result.contains(localizedYesterday), "Should not contain 'Yesterday' for distant dates")
      #expect(!result.contains(localizedTomorrow), "Should not contain 'Tomorrow' for distant dates")

      // Should contain some form of date information
      #expect(result.count > 10, "Should include full date information for distant dates")
    }
  }

  // MARK: - Time Remaining String Key Tests

  @Suite("Time Remaining String Key")
  struct TimeRemainingStringKeyTests {
    @Test("Time remaining with past deadline returning 'Time's Up' key")
    func timeRemainingWithPastDeadlineReturnsTimesUpKey() throws {
      let baseTime = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create base time")

      let pastResult = baseTime.toTimeRemainingStringKey(until: baseTime.addingTimeInterval(-1))
      let pastResult2 = baseTime.toTimeRemainingStringKey(until: baseTime.addingTimeInterval(-999))

      #expect(pastResult == LocalizedStringKey("Time's Up"), "Past deadline should return 'Time's Up' key")
      #expect(pastResult2 == LocalizedStringKey("Time's Up"), "Past deadline should return 'Time's Up' key")
    }

    @Test("Time remaining with different future deadlines produces different keys")
    func timeRemainingWithDifferentFutureDeadlinesProducesDifferentKeys() throws {
      let baseTime = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create base time")

      let testDurations: [TimeInterval] = [
        60, // 1 minute
        3600, // 1 hour
        86400, // 1 day
        90061, // 1 day, 1 hour, 1 minute, 1 second
      ]

      var results: [LocalizedStringKey] = []
      for duration in testDurations {
        let futureTime = baseTime.addingTimeInterval(duration)
        let result = baseTime.toTimeRemainingStringKey(until: futureTime)
        results.append(result)
      }

      // Each different duration should produce a different key
      for i in 0 ..< results.count {
        for j in (i + 1) ..< results.count {
          #expect(results[i] != results[j], "Different durations should produce different LocalizedStringKeys")
        }
      }
    }
  }

  // MARK: - Time Until String Key Tests

  @Suite("Time Until String Key")
  struct TimeUntilStringKeyTests {
    @Test("Time until with past start time returning 'Time's Up' key")
    func timeUntilWithPastStartTimeReturnsTimesUpKey() throws {
      let baseTime = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create base time")

      let pastResult = baseTime.toTimeUntilStringKey(until: baseTime.addingTimeInterval(-1))
      let pastResult2 = baseTime.toTimeUntilStringKey(until: baseTime.addingTimeInterval(-999))

      #expect(pastResult == LocalizedStringKey("Time's Up"), "Past start time should return 'Time's Up' key")
      #expect(pastResult2 == LocalizedStringKey("Time's Up"), "Past start time should return 'Time's Up' key")
    }

    @Test("Time until with different future start times produces different keys")
    func timeUntilWithDifferentFutureStartTimesProducesDifferentKeys() throws {
      let baseTime = try #require(
        Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25, hour: 12, minute: 0)),
        "Should be able to create base time")

      let testDurations: [TimeInterval] = [
        60, // 1 minute
        3600, // 1 hour
        86400, // 1 day
        90061, // 1 day, 1 hour, 1 minute, 1 second
      ]

      var results: [LocalizedStringKey] = []
      for duration in testDurations {
        let futureTime = baseTime.addingTimeInterval(duration)
        let result = baseTime.toTimeUntilStringKey(until: futureTime)
        results.append(result)
      }

      // Each different duration should produce a different key
      for i in 0 ..< results.count {
        for j in (i + 1) ..< results.count {
          #expect(results[i] != results[j], "Different durations should produce different LocalizedStringKeys")
        }
      }
    }
  }
}
