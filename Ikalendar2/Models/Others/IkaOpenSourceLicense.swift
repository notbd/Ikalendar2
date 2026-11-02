//
//  IkaOpenSourceLicense.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// License info of an open source library, as fetched from the GitHub API.
struct IkaOpenSourceLicense {
  let repoURL: String
  let type: String
  let typeDescription: String
  let content: String

  var ownerAndRepo: String {
    ownerRepoPair.map { "\($0.owner)/\($0.repo)" } ?? Constants.Key.Placeholder.unknown
  }

  /// The owner and repo parsed from `repoURL`, or `nil` if it is not a GitHub repo URL.
  /// GitHub names may contain `-` and `.` (e.g. `misenhower/splatoon2.ink`).
  /// - Note: computed (not stored) so the struct keeps its memberwise initializer.
  private var ownerRepoPair: (owner: Substring, repo: Substring)? {
    guard let (_, owner, repo) = repoURL.firstMatch(of: /github.com\/([\w.-]+)\/([\w.-]+)/)?.output
    else { return nil }

    return (owner, repo)
  }

  /// Transform from
  /// `https://github.com/SwiftyJSON/SwiftyJSON`
  /// to
  /// `https://api.github.com/repos/SwiftyJSON/SwiftyJSON/license`
  ///
  static func githubAPIURLString(fromRepoURL repoURLString: String) -> String? {
    let regex = /github.com\/([\w.-]+\/[\w.-]+)/

    guard let (_, ownerAndRepo) = repoURLString.firstMatch(of: regex)?.output
    else { return nil }

    return "https://api.github.com/repos/" + ownerAndRepo + "/license"
  }

  /// Transform from
  /// `https://api.github.com/repos/SwiftyJSON/SwiftyJSON/license`
  /// to
  /// `https://github.com/SwiftyJSON/SwiftyJSON`
  ///
  static func githubRepoURLString(fromAPIURL apiURLString: String) -> String? {
    let regex = /api.github.com\/repos\/([\w.-]+\/[\w.-]+)/
    guard let (_, ownerAndRepo) = apiURLString.firstMatch(of: regex)?.output
    else { return nil }

    return "https://github.com/" + ownerAndRepo
  }
}
