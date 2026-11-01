//
//  DateTimeZoneTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import IkalendarKit

// MARK: - DateTimeZoneTests

/// The cached rotation-time formatters must follow device time-zone changes (they used to
/// keep the zone they were created in until the app was killed). The zone is passed in
/// explicitly instead of changing `NSTimeZone.default`: that is process-wide state, and
/// `.serialized` would not stop other suites (e.g. DateFormatterExtensionTests) from
/// reading it mid-change.
@Suite("Date formatting time zones")
struct DateTimeZoneTests {
  /// 2023-11-14 22:13:20 UTC: Wed 7:13 AM in Tokyo, Tue 5:13 PM in New York.
  private let instant: Date = .init(timeIntervalSince1970: 1_700_000_000)

  private func freshString(_ type: DateFormatter.IkaDateFormatterType, in timeZone: TimeZone) -> String {
    let formatter: DateFormatter = .init(ikaType: type)
    formatter.timeZone = timeZone
    return formatter.string(from: instant)
  }

  @Test
  func `Cached time formatter follows a time zone change`() throws {
    let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
    let newYork = try #require(TimeZone(identifier: "America/New_York"))

    let inTokyo: String = instant.ikaTimeString(in: tokyo)
    let inNewYork: String = instant.ikaTimeString(in: newYork)

    #expect(inTokyo != inNewYork)
    #expect(inTokyo == freshString(.time, in: tokyo))
    #expect(inNewYork == freshString(.time, in: newYork))
    #expect(instant.ikaTimeString(in: tokyo) == inTokyo)
  }

  @Test
  func `Cached date formatter follows a time zone change`() throws {
    let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
    let newYork = try #require(TimeZone(identifier: "America/New_York"))

    let inTokyo: String = instant.ikaDateString(in: tokyo)
    let inNewYork: String = instant.ikaDateString(in: newYork)

    #expect(inTokyo != inNewYork)
    #expect(inTokyo == freshString(.date, in: tokyo))
    #expect(inNewYork == freshString(.date, in: newYork))
    #expect(instant.ikaDateString(in: tokyo) == inTokyo)
  }

  @Test
  func `Public time strings render in the current time zone`() {
    #expect(instant.toBattleTimeString() == freshString(.time, in: .current))
    #expect(instant.toSalmonTimeString() == freshString(.time, in: .current))
  }
}
