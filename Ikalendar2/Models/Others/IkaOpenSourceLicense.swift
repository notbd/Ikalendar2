//
//  IkaOpenSourceLicense.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import RegexBuilder

struct IkaOpenSourceLicense {
  let repoURL: String
  let type: String
  let typeDescription: String
  let content: String

  var userName: String {
    do {
      guard let (_, user, _) = try infoSearchRegex.firstMatch(in: repoURL)?.output
      else { throw IkaError.unknownError }

      return String(user)
    }
    catch {
      return Constants.Key.Placeholder.UNKNOWN
    }
  }

  var repoName: String {
    do {
      guard let (_, _, repo) = try infoSearchRegex.firstMatch(in: repoURL)?.output
      else { throw IkaError.unknownError }

      return String(repo)
    }
    catch {
      return Constants.Key.Placeholder.UNKNOWN
    }
  }

  var gist: String {
    do {
      guard let (_, user, repo) = try infoSearchRegex.firstMatch(in: repoURL)?.output
      else { throw IkaError.unknownError }

      return "\(user)/\(repo)"
    }
    catch {
      return Constants.Key.Placeholder.UNKNOWN
    }
  }

  //  Note: lookbehind is not supported yet as of iOS 17.0 SDK

  ///  private let infoSearchRegex = /github.com\/(\w+)\/(\w+)/
  private let infoSearchRegex = Regex {
    "github.com/"
    Capture { OneOrMore(.word) }
    "/"
    Capture { OneOrMore(.word) }
  }

  /// Transform from
  /// `https://github.com/SwiftyJSON/SwiftyJSON`
  /// to
  /// `https://api.github.com/repos/SwiftyJSON/SwiftyJSON/license`
  ///
  static func parseGithubAPIURLString(from repoURLString: String) -> String? {
    let regex = /github.com\/(\w+\/\w+)/

    guard let (_, gist) = repoURLString.firstMatch(of: regex)?.output
    else { return nil }

    return "https://api.github.com/repos/" + gist + "/license"
  }

  /// Transform from
  /// `https://api.github.com/repos/SwiftyJSON/SwiftyJSON/license`
  /// to
  /// `https://github.com/SwiftyJSON/SwiftyJSON`
  ///
  static func parseGithubRepoURLString(from apiURLString: String) -> String? {
    let regex = /api.github.com\/repos\/(\w+\/\w+)/
    guard let (_, gist) = apiURLString.firstMatch(of: regex)?.output
    else { return nil }

    return "https://github.com/" + gist
  }
}
