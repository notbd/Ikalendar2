//
//  AssetImageCounter.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import UIKit

/// A utility for counting images in the asset catalog that follow a specific naming convention.
///
/// This enum provides a static method to count images, which is useful for dynamically
/// determining the number of available assets, such as alternative app icons or image sets.
public enum AssetImageCounter {
  /// Counts the number of images in the asset catalog that start with a given prefix,
  /// followed by a number.
  ///
  /// This function assumes that the images are named in a sequence, e.g., "prefix0", "prefix1", etc.
  /// It checks for the existence of up to 10 images (from "prefix0" to "prefix9").
  ///
  /// - Parameter prefix: The prefix to search for.
  /// - Returns: The number of images found with the specified prefix.
  static public func countImagesWithPrefix(_ prefix: String) -> Int {
    var count = 0

    // List of image names with a specific prefix, assuming a known pattern in naming
    let imageNamesWithPrefix = (0 ..< 10).map { "\(prefix)\($0)" }

    // Iterate through image names to check if they are present in the Asset catalog
    for imageName in imageNamesWithPrefix
      where UIImage(named: imageName) != nil
    {
      count += 1
    }

    return count
  }
}
