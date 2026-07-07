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
      return Constants.Key.Placeholder.unknown
    }
  }

  var repoName: String {
    do {
      guard let (_, _, repo) = try infoSearchRegex.firstMatch(in: repoURL)?.output
      else { throw IkaError.unknownError }

      return String(repo)
    }
    catch {
      return Constants.Key.Placeholder.unknown
    }
  }

  var gist: String {
    do {
      guard let (_, user, repo) = try infoSearchRegex.firstMatch(in: repoURL)?.output
      else { throw IkaError.unknownError }

      return "\(user)/\(repo)"
    }
    catch {
      return Constants.Key.Placeholder.unknown
    }
  }

  //  Note: lookbehind is not supported yet as of iOS 17.0 SDK

  ///  equivalent to /github.com\/(\w+)\/(\w+)/
  /// - Note: computed (not stored) so the struct stays Sendable - `Regex` is not Sendable.
  private var infoSearchRegex: Regex<(Substring, Substring, Substring)> {
    Regex {
      "github.com/"
      Capture { OneOrMore(.word) }
      "/"
      Capture { OneOrMore(.word) }
    }
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
