//
//  SeededRandomGenerator.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import GameplayKit

/// `SeededRandomGenerator` is a deterministic random number generator that produces a sequence of random
/// values based on a specified seed.
/// The seed can be set using either an integer or a string, and the generator provides functions to produce
/// random integers within a specified range.
/// The generator's state can also be reset, allowing for the exact same sequence of random values to be
/// reproduced.
///
/// Example usage:
///
/// ```swift
/// let generator = SeededRandomGenerator(seed: 42)
/// let randomValue1 = generator.nextInt(bound: 20)
/// generator.reset()
/// let randomValue2 = generator.nextInt(bound: 20) // Will be the same as randomValue1
/// ```
final public class SeededRandomGenerator {
  private var originalSeed: Data
  private var randomSource: GKARC4RandomSource

  /// Initializes the generator with an integer seed.
  public init(seed: Int) {
    let seedData = Data("\(seed)".utf8)
    originalSeed = seedData
    randomSource = GKARC4RandomSource(seed: seedData)
  }

  /// Initializes the generator with a string seed.
  public init(seed: String) {
    let seedData = Data(seed.utf8)
    originalSeed = seedData
    randomSource = GKARC4RandomSource(seed: seedData)
  }

  /// Generates a random integer within the range from 0 to the specified bound (exclusive).
  /// - Parameter bound: The upper bound of the range (exclusive).
  /// - Returns: A random integer within the range from 0 to the bound (exclusive).
  public func nextInt(bound: Int) -> Int {
    let distribution = GKRandomDistribution(
      randomSource: randomSource,
      lowestValue: 0,
      highestValue: bound - 1)
    return distribution.nextInt()
  }

  /// Resets the generator, so that subsequent calls to `nextInt(bound:)` will repeat the same sequence.
  public func reset() {
    randomSource = GKARC4RandomSource(seed: originalSeed)
  }
}
