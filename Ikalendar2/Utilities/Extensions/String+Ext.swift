//
//  String+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension String {
  var localizedStringKey: LocalizedStringKey { LocalizedStringKey(self) }
}

extension String {
  /// Creates a shortened URL string by optionally removing a base URL and adding a new prefix.
  ///
  /// This function takes an optional base URL string and an optional new prefix. It first removes the base
  /// URL from the original URL string, if specified. It then adds the new prefix to the remaining URL, if
  /// provided. Trailing and leading slashes ("/") are also removed from the shortened URL.
  ///
  /// - Parameters:
  ///  - baseURLString: The base URL string to remove from the original URL. Default value is `nil`.
  ///  - newPrefix: The new prefix to add to the shortened URL. Default value is `nil`.
  ///
  /// - Returns: A shortened URL string with the base URL and leading/trailing slashes removed, optionally
  /// prefixed with `newPrefix`, or `nil` if the operation cannot be performed (e.g., invalid URL format, the
  /// receiver doesn't start with the base URL).
  ///
  /// - Example:
  ///  ```
  ///  let urlString = "https://www.example.com/page/1/"
  ///  let shortened = urlString.shortenedURL(base: "https://www.example.com/", newPrefix: "Page:")
  ///  // shortened will be "Page:1"
  ///  ```
  ///
  /// - Note: If `baseURLString` is `nil`, the function will return the host + path of the original URL.
  ///
  func shortenedURL(
    base baseURLString: String? = nil,
    newPrefix: String? = nil)
    -> String?
  {
    guard let url = URL(string: self) else { return nil }

    let host = url.host ?? ""
    let path = url.path
    var hostAndPath = host + path
    if hostAndPath.hasSuffix("/") { hostAndPath = String(hostAndPath.dropLast()) }

    guard let baseURLString else { return hostAndPath }
    guard URL(string: baseURLString) != nil else { return nil }

    guard hasPrefix(baseURLString) else { return nil }

    var result = replacingOccurrences(of: baseURLString, with: "")
    if result.hasPrefix("/") { result = String(result.dropFirst()) }
    if result.hasSuffix("/") { result = String(result.dropLast()) }
    if let newPrefix, !newPrefix.isEmpty { result = newPrefix + result }

    return result
  }
}
