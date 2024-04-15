//
//  AssetImageCounter.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import UIKit

enum AssetImageCounter {
  /// Returns the total number of images in the App Asset folder that have a certain prefix in their file
  /// name. Assume number of images no greater than 10.
  ///
  /// - Parameter prefix: The prefix to search for in the image filenames.
  /// - Returns: The total count of images that have the given prefix in their name.
  static func countImagesWithPrefix(_ prefix: String) -> Int {
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
