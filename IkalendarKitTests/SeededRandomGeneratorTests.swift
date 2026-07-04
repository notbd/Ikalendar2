//
//  SeededRandomGeneratorTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import IkalendarKit

// MARK: - SeededRandomGeneratorTests

/// Determinism guarantees for the alt-stage-image picker: the same rotation
/// (seed) must always resolve to the same image variant.
@Suite("SeededRandomGenerator")
struct SeededRandomGeneratorTests {
  private func drawSequence(_ generator: SeededRandomGenerator, count: Int = 20, bound: Int = 100) -> [Int] {
    (0 ..< count).map { _ in generator.nextInt(bound: bound) }
  }

  @Test
  func `Same integer seed produces the same sequence`() {
    let first = drawSequence(SeededRandomGenerator(seed: 42))
    let second = drawSequence(SeededRandomGenerator(seed: 42))
    #expect(first == second)
  }

  @Test
  func `Same string seed produces the same sequence`() {
    let first = drawSequence(SeededRandomGenerator(seed: "squid"))
    let second = drawSequence(SeededRandomGenerator(seed: "squid"))
    #expect(first == second)
  }

  @Test
  func `Integer and equivalent string seeds share a stream`() {
    // Pins the implementation detail that integer seeds are stringified.
    let fromInt = drawSequence(SeededRandomGenerator(seed: 42))
    let fromString = drawSequence(SeededRandomGenerator(seed: "42"))
    #expect(fromInt == fromString)
  }

  @Test
  func `Different seeds produce different sequences`() {
    let first = drawSequence(SeededRandomGenerator(seed: 1))
    let second = drawSequence(SeededRandomGenerator(seed: 999_999))
    #expect(first != second)
  }

  @Test
  func `Draws respect the bound`() {
    // Note: bound 0 is a documented crash (GKRandomDistribution lowest > highest) - never call it.
    let generator: SeededRandomGenerator = .init(seed: 7)
    for _ in 0 ..< 500 {
      let draw = generator.nextInt(bound: 7)
      #expect((0 ..< 7).contains(draw))
    }

    let unitGenerator: SeededRandomGenerator = .init(seed: 7)
    for _ in 0 ..< 10 {
      #expect(unitGenerator.nextInt(bound: 1) == 0)
    }
  }

  @Test
  func `Reset replays the stream from the start`() {
    let generator: SeededRandomGenerator = .init(seed: "reset-me")
    let first = drawSequence(generator, count: 10)
    generator.reset()
    let second = drawSequence(generator, count: 10)
    #expect(first == second)
  }
}
