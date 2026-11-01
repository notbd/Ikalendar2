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

/// `Date+Ext` reads `Locale.current`, `TimeZone.current` and `Calendar.current` internally,
/// and none of them can be overridden for one test without mutating process-wide state that
/// parallel suites share. So instead:
/// - fixtures are wall-clock times in the runner's own time zone on a Gregorian calendar,
///   which is the same instant to the code under test on every runner;
/// - locale-dependent pieces come from `DateFormatter(ikaType:)` and
///   `TimeLength.localizedDescription()` with their defaults, whose exact per-locale output
///   is pinned in DateFormatterExtensionTests and TimeLengthTests;
/// - relative-day words are looked up by key in the main bundle, as the code under test does.
///
/// Everything `Date+Ext` adds on top is pinned exactly: which branch fires for which day,
/// separators, ordering, the duration breakdown and the string-key templates.
@Suite("Date Extensions")
struct DateExtensionTests {
  // MARK: - Date Subtraction Tests

  @Suite("Date Subtraction")
  struct DateSubtractionTests {
    @Test
    func `Date subtraction returns correct time interval`() {
      let date1: Date = .init(timeIntervalSince1970: 1000)
      let date2: Date = .init(timeIntervalSince1970: 500)

      let result = date1 - date2
      #expect(result == 500.0, "Date subtraction should return the correct time interval")
    }

    @Test
    func `Date subtraction with same dates returns zero`() {
      let date: Date = .init(timeIntervalSince1970: 1_700_000_000)
      let result = date - date
      #expect(result == 0.0, "Subtracting same date should return zero")
    }

    @Test
    func `Date subtraction with past date returns negative value`() {
      let futureDate: Date = .init(timeIntervalSince1970: 1000)
      let pastDate: Date = .init(timeIntervalSince1970: 2000)

      let result = futureDate - pastDate
      #expect(result == -1000.0, "Subtracting a future date from a past date should return negative value")
    }
  }

  // MARK: - Remove Minutes Tests

  @Suite("Remove Minutes")
  struct RemoveMinutesTests {
    @Test
    func `Remove minutes truncates to the exact start of the hour`() throws {
      // The sub-second part must go too.
      let original: Date = try localDate(DateComponents(
        year: 2023, month: 12, day: 25,
        hour: 14, minute: 30, second: 45, nanosecond: 500_000_000))
      let hourStart: Date = try localDate(DateComponents(year: 2023, month: 12, day: 25, hour: 14))

      #expect(original.removeMinutes() == hourStart)
    }
  }

  // MARK: - Battle & Salmon Time String Tests

  @Suite("Battle and Salmon Time Strings")
  struct TimeStringTests {
    /// 2023-12-25 12:00 in the runner's time zone.
    private let referenceComponents: DateComponents = .init(year: 2023, month: 12, day: 25, hour: 12)

    @Test(arguments: [
      DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30),
      DateComponents(year: 2023, month: 12, day: 27, hour: 9, minute: 5),
    ])
    func `Without the date flag both render the time only`(components: DateComponents) throws {
      let date: Date = try localDate(components)
      let reference: Date = try localDate(referenceComponents)
      let time: String = DateFormatter(ikaType: .time).string(from: date)

      #expect(date.toBattleTimeString() == time)
      #expect(date.toSalmonTimeString() == time)
      #expect(date.toBattleTimeString(shouldIncludeDate: false, currentTime: reference) == time)
      #expect(date.toSalmonTimeString(shouldIncludeDate: false, currentTime: reference) == time)
    }

    /// Calendar days, not 24-hour windows: 00:30 on the next day is "Tomorrow" although it
    /// is only 12.5 hours after the reference.
    @Test(arguments: [
      (DateComponents(year: 2023, month: 12, day: 24, hour: 23, minute: 59), "Yesterday"),
      (DateComponents(year: 2023, month: 12, day: 25, hour: 0, minute: 0), "Today"),
      (DateComponents(year: 2023, month: 12, day: 25, hour: 14, minute: 30), "Today"),
      (DateComponents(year: 2023, month: 12, day: 25, hour: 23, minute: 59), "Today"),
      (DateComponents(year: 2023, month: 12, day: 26, hour: 0, minute: 30), "Tomorrow"),
    ])
    func `Adjacent days are prefixed with the relative day`(components: DateComponents, wordKey: String) throws {
      let date: Date = try localDate(components)
      let reference: Date = try localDate(referenceComponents)
      let word: String = Bundle.main.localizedString(forKey: wordKey, value: nil, table: nil)
      let expected: String = word + " " + DateFormatter(ikaType: .time).string(from: date)

      #expect(date.toBattleTimeString(shouldIncludeDate: true, currentTime: reference) == expected)
      #expect(date.toSalmonTimeString(shouldIncludeDate: true, currentTime: reference) == expected)
    }

    /// Battles never start more than a day away, so other days get no date; salmon runs
    /// can, so they get the date prepended (the date pattern supplies the separator).
    @Test(arguments: [
      DateComponents(year: 2023, month: 12, day: 23, hour: 10, minute: 45),
      DateComponents(year: 2023, month: 12, day: 27, hour: 10, minute: 45),
    ])
    func `Other days add the date for salmon only`(components: DateComponents) throws {
      let date: Date = try localDate(components)
      let reference: Date = try localDate(referenceComponents)
      let time: String = DateFormatter(ikaType: .time).string(from: date)
      let day: String = DateFormatter(ikaType: .date).string(from: date)

      #expect(date.toBattleTimeString(shouldIncludeDate: true, currentTime: reference) == time)
      #expect(date.toSalmonTimeString(shouldIncludeDate: true, currentTime: reference) == day + time)
    }

    /// Without a reference the current time is used. A fixture decades in the past is never
    /// today, yesterday or tomorrow, so the result does not depend on when the test runs.
    @Test
    func `A missing reference time falls back to now`() throws {
      let date: Date = try localDate(DateComponents(year: 2000, month: 1, day: 1, hour: 10, minute: 45))
      let time: String = DateFormatter(ikaType: .time).string(from: date)
      let day: String = DateFormatter(ikaType: .date).string(from: date)

      #expect(date.toBattleTimeString(shouldIncludeDate: true) == time)
      #expect(date.toSalmonTimeString(shouldIncludeDate: true) == day + time)
    }
  }

  // MARK: - Countdown String Key Tests

  /// Keys are compared through `keyParts(_:)`, not `==` (see there for why).
  @Suite("Time Remaining and Time Until String Keys")
  struct CountdownStringKeyTests {
    private let base: Date = .init(timeIntervalSince1970: 1_700_000_000)

    @Test(arguments: [-1.0, -59.5, -86400.0])
    func `Past deadlines read Time's Up`(offset: TimeInterval) throws {
      let deadline: Date = base.addingTimeInterval(offset)

      let remaining = try keyParts(base.toTimeRemainingStringKey(until: deadline))
      #expect(remaining.template == "Time's Up")
      #expect(remaining.arguments.isEmpty)

      let until = try keyParts(base.toTimeUntilStringKey(until: deadline))
      #expect(until.template == "Time's Up")
      #expect(until.arguments.isEmpty)
    }

    /// The interval is truncated toward zero, so a deadline less than a second ago still
    /// reads as a zero duration instead of "Time's Up".
    @Test(arguments: [
      (-0.5, DateComponents(day: 0, hour: 0, minute: 0, second: 0)),
      (0.0, DateComponents(day: 0, hour: 0, minute: 0, second: 0)),
      (59.9, DateComponents(day: 0, hour: 0, minute: 0, second: 59)),
      (60.0, DateComponents(day: 0, hour: 0, minute: 1, second: 0)),
      (3601.0, DateComponents(day: 0, hour: 1, minute: 0, second: 1)),
      (86399.0, DateComponents(day: 0, hour: 23, minute: 59, second: 59)),
      (86400.0, DateComponents(day: 1, hour: 0, minute: 0, second: 0)),
      (90061.0, DateComponents(day: 1, hour: 1, minute: 1, second: 1)),
      (1_000_000.0, DateComponents(day: 11, hour: 13, minute: 46, second: 40)),
    ])
    func `Future deadlines carry the exact breakdown`(offset: TimeInterval, breakdown: DateComponents) throws {
      let deadline: Date = base.addingTimeInterval(offset)
      let timeLength: TimeLength = .init(
        days: breakdown.day ?? 0,
        hours: breakdown.hour ?? 0,
        minutes: breakdown.minute ?? 0,
        seconds: breakdown.second ?? 0)
      let duration: String = timeLength.localizedDescription()

      let remaining = try keyParts(base.toTimeRemainingStringKey(until: deadline))
      #expect(remaining.template == "remaining %@")
      #expect(remaining.arguments == [duration])

      let until = try keyParts(base.toTimeUntilStringKey(until: deadline))
      #expect(until.template == "%@ until")
      #expect(until.arguments == [duration])
    }
  }
}

// MARK: - Helpers

/// A wall-clock time in the runner's own time zone on a Gregorian calendar: the same instant
/// that `Calendar.current` and a default-zone `DateFormatter` see, whatever the runner's zone.
private func localDate(_ components: DateComponents) throws -> Date {
  var calendar: Calendar = .init(identifier: .gregorian)
  calendar.timeZone = .current
  return try #require(calendar.date(from: components))
}

/// The template and String arguments of a `LocalizedStringKey`.
///
/// `LocalizedStringKey ==` compares interpolated String arguments by storage rather than by
/// value: two keys interpolating equal heap-allocated strings compare unequal, so `==` would
/// make these tests pass or fail by string length. Reflection reads the actual parts.
private func keyParts(_ key: LocalizedStringKey) throws -> (template: String, arguments: [String]) {
  let mirror: Mirror = .init(reflecting: key)
  let template = try #require(mirror.descendant("key") as? String)
  let arguments = try #require(mirror.descendant("arguments") as? [Any])
  let strings: [String] = try arguments.map { argument in
    try #require(Mirror(reflecting: argument).descendant("storage", "value", ".0") as? String)
  }
  return (template, strings)
}
