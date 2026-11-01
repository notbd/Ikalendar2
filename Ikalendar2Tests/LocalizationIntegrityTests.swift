//
//  LocalizationIntegrityTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing

// MARK: - LocalizationIntegrityTests

/// Guards the compiled Localizable.strings tables the app ships. A stray control character
/// (U+0003) once sat right before "Squiddor Polo" and silently cut parsing short there, so
/// every later key showed its raw key text instead of a translation. The test bundle is
/// hosted by the app, so `Bundle.main` holds the compiled tables.
@Suite("Localization integrity")
struct LocalizationIntegrityTests {
  /// The first key after the old truncation point, a late key and the last key in the file.
  static private let sentinelKeys: [String] = ["Squiddor Polo", "Next", "Mystery Grizzco"]

  @Test
  func `English and Japanese tables have the same keys`() throws {
    let english: Set<String> = try Set(loadTable(for: "en").keys)
    let japanese: Set<String> = try Set(loadTable(for: "ja").keys)

    #expect(english.subtracting(japanese).isEmpty, "missing in ja: \(english.subtracting(japanese).sorted())")
    #expect(japanese.subtracting(english).isEmpty, "missing in en: \(japanese.subtracting(english).sorted())")
  }

  @Test(arguments: ["en", "ja"])
  func `Table parses through to the last key`(localization: String) throws {
    let strings: [String: String] = try loadTable(for: localization)

    for key in Self.sentinelKeys {
      #expect(strings[key] != nil, "\(localization) table is missing \"\(key)\"")
    }
  }

  @Test(arguments: ["en", "ja"])
  func `No key or value contains a control character`(localization: String) throws {
    // Newlines are intentional (e.g. "Welcome to\n%@" and the error messages); every other
    // control or format character is not.
    var forbidden: CharacterSet = .controlCharacters
    forbidden.remove("\n")

    for (key, value) in try loadTable(for: localization) {
      #expect(key.rangeOfCharacter(from: forbidden) == nil, "\(localization) key \(key.debugDescription)")
      #expect(value.rangeOfCharacter(from: forbidden) == nil, "\(localization) value of \(key.debugDescription)")
    }
  }

  /// The compiled table for `localization`. NSDictionary reads both the text and the binary
  /// plist format the strings compiler can emit.
  private func loadTable(for localization: String) throws -> [String: String] {
    let path: String = try #require(
      Bundle.main.path(
        forResource: "Localizable",
        ofType: "strings",
        inDirectory: nil,
        forLocalization: localization),
      "no compiled Localizable.strings for \(localization)")
    return try #require(
      NSDictionary(contentsOfFile: path) as? [String: String],
      "unreadable Localizable.strings for \(localization)")
  }
}
