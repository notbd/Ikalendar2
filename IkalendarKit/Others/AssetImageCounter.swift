//
//  AssetImageCounter.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import os
import UIKit

/// A utility for counting images in the asset catalog that follow a specific naming convention.
///
/// This enum provides a static method to count images, which is useful for dynamically
/// determining the number of available assets, such as alternative app icons or image sets.
public enum AssetImageCounter {
  /// Memoized counts: the asset catalog cannot change at runtime, and callers sit on
  /// per-second refresh paths (rotation cards re-evaluate alt-image names every tick).
  /// OSAllocatedUnfairLock keeps the cache safe from any isolation domain (iOS 17+).
  static private let countCache: OSAllocatedUnfairLock<[String: Int]> = .init(initialState: [:])

  /// Counts the number of images in the asset catalog that start with a given prefix,
  /// followed by a number.
  ///
  /// This function assumes that the images are named in a sequence, e.g., "prefix0", "prefix1", etc.
  /// It checks for the existence of up to 10 images (from "prefix0" to "prefix9").
  ///
  /// - Important: 10 is a hard upper bound: assets named "prefix10" and beyond are NOT counted.
  ///   Raise the bound here before adding more than 10 alt images for any single prefix.
  ///
  /// - Parameter prefix: The prefix to search for.
  /// - Returns: The number of images found with the specified prefix.
  static public func countImagesWithPrefix(_ prefix: String) -> Int {
    if let cached = countCache.withLock({ $0[prefix] }) { return cached }

    var count = 0

    // List of image names with a specific prefix, assuming a known pattern in naming
    let imageNamesWithPrefix = (0 ..< 10).map { "\(prefix)\($0)" }

    // Iterate through image names to check if they are present in the Asset catalog
    for imageName in imageNamesWithPrefix
      where UIImage(named: imageName) != nil
    {
      count += 1
    }

    let finalCount = count
    countCache.withLock { $0[prefix] = finalCount }
    return finalCount
  }
}
