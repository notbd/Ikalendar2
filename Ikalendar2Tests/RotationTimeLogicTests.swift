//
//  RotationTimeLogicTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - RotationTimeLogicTests

/// Pins the exact boundary semantics of the rotation time predicates:
/// isCurrent is [start, end), isExpired is end-inclusive, isNext uses strict `<`.
/// These invariants drive every countdown and list-filtering decision in the app.
@Suite("Rotation time logic")
struct RotationTimeLogicTests {
  // MARK: - BattleRotation

  @Suite("Battle Rotation Boundaries")
  struct BattleRotationBoundaryTests {
    /// [anchor, anchor+2h)
    private let rotation: BattleRotation = TestData.battleRotation(startOffset: 0, endOffset: 2 * 3600)

    @Test
    func `isCurrent is true exactly at start time`() {
      #expect(rotation.isCurrent(rotation.startTime))
    }

    @Test
    func `isCurrent is false exactly at end time`() {
      #expect(!rotation.isCurrent(rotation.endTime))
    }

    @Test
    func `isCurrent is true mid-window and false before start`() {
      #expect(rotation.isCurrent(rotation.startTime.addingTimeInterval(3600)))
      #expect(!rotation.isCurrent(rotation.startTime.addingTimeInterval(-1)))
    }

    @Test
    func `isExpired is true exactly at end time`() {
      #expect(rotation.isExpired(rotation.endTime))
      #expect(!rotation.isExpired(rotation.endTime.addingTimeInterval(-1)))
      #expect(rotation.isExpired(rotation.endTime.addingTimeInterval(1)))
    }

    @Test
    func `isFuture is false exactly at start time`() {
      #expect(!rotation.isFuture(rotation.startTime))
      #expect(rotation.isFuture(rotation.startTime.addingTimeInterval(-1)))
    }

    @Test
    func `isNext window uses strict comparisons`() {
      let now: Date = TestData.anchor

      // Starts exactly 2h out: startTime < now+2h is FALSE at the boundary.
      let exactlyTwoHoursOut: BattleRotation = TestData.battleRotation(startOffset: 2 * 3600, endOffset: 4 * 3600)
      #expect(!exactlyTwoHoursOut.isNext(now))

      // Starts 1h out, ends 3h out: now+2h falls strictly inside.
      let upcoming: BattleRotation = TestData.battleRotation(startOffset: 3600, endOffset: 3 * 3600)
      #expect(upcoming.isNext(now))

      // Currently active ([-1h, +1h]): now+2h is past its end.
      let current: BattleRotation = TestData.battleRotation(startOffset: -3600, endOffset: 3600)
      #expect(!current.isNext(now))
    }
  }

  // MARK: - Rotation Equality

  @Suite("Rotation Equality")
  struct RotationEqualityTests {
    @Test
    func `Identical battle rotations are equal`() {
      let lhs: BattleRotation = TestData.battleRotation(startOffset: 0, endOffset: 7200)
      let rhs: BattleRotation = TestData.battleRotation(startOffset: 0, endOffset: 7200)
      #expect(lhs == rhs)
    }

    @Test
    func `Changing any battle field breaks equality`() {
      let base: BattleRotation = TestData.battleRotation(startOffset: 0, endOffset: 7200)
      let differentRule: BattleRotation = TestData.battleRotation(startOffset: 0, endOffset: 7200, rule: .rainmaker)
      let differentStage: BattleRotation = TestData.battleRotation(startOffset: 0, endOffset: 7200, stageA: .kelpDome)
      #expect(base != differentRule)
      #expect(base != differentStage)
    }

    @Test
    func `Salmon reward apparel participates in equality`() {
      // The auto-loader relies on this: attaching the reward gear must register as
      // "new data from server" (Rotation.== hashes the description, which includes it).
      let plain: SalmonRotation = TestData.salmonRotation(startOffset: 0, endOffset: 42 * 3600)
      var withApparel: SalmonRotation = TestData.salmonRotation(startOffset: 0, endOffset: 42 * 3600)
      withApparel.rewardApparel = .head(.oceanicHardHat)
      #expect(plain != withApparel)
    }
  }

  // MARK: - BattleRotationDict

  @Suite("Battle Rotation Dict")
  struct BattleRotationDictTests {
    @Test
    func `Custom init creates all modes with empty arrays`() {
      let dict: BattleRotationDict = .init()
      #expect(dict.count == BattleMode.allCases.count)
      #expect(dict.hasEmptyMode)
    }

    @Test
    func `hasEmptyMode is false when fully populated`() {
      #expect(!TestData.battleDict().hasEmptyMode)
    }

    @Test
    func `hasEmptyMode is true when any single mode is empty`() {
      var dict: BattleRotationDict = TestData.battleDict()
      dict[.league] = []
      #expect(dict.hasEmptyMode)
    }

    @Test
    func `isOutdated boundary is strict at the gachi end time`() throws {
      let dict: BattleRotationDict = TestData.battleDict(reference: TestData.anchor)
      let gachiEnd = try #require(dict[.gachi]?.first?.endTime)

      #expect(!dict.isOutdated(gachiEnd.addingTimeInterval(-1)))
      #expect(!dict.isOutdated(gachiEnd)) // strict `<`: not outdated at the exact boundary
      #expect(dict.isOutdated(gachiEnd.addingTimeInterval(1)))
    }

    @Test
    func `Empty dict is never outdated`() {
      // Pre-hardening, an all-empty dict force-unwrapped and crashed here.
      #expect(!BattleRotationDict().isOutdated(.distantFuture))
      let empty: BattleRotationDict = [:]
      #expect(!empty.isOutdated(.distantFuture))
    }

    @Test
    func `isOutdated keys off gachi only`() throws {
      // Documents current semantics: all three modes rotate together, so the
      // check deliberately consults .gachi alone.
      var dict: BattleRotationDict = TestData.battleDict(reference: TestData.anchor)
      let regularFirst = try #require(dict[.regular]?.first)
      dict[.regular]?[0] = TestData.battleRotation(
        mode: .regular,
        startOffset: -7200,
        endOffset: -3600) // regular already expired
      _ = regularFirst

      let gachiEnd = try #require(dict[.gachi]?.first?.endTime)
      #expect(!dict.isOutdated(gachiEnd.addingTimeInterval(-1)))
    }
  }
}
