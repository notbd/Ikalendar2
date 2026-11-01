//
//  IkaOpenSourceLicenseTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Testing
@testable import Ikalendar2

// MARK: - IkaOpenSourceLicenseTests

/// GitHub URL parsing for the Credits license screen. Owner and repo names may contain
/// `-` and `.`; the three credited repos must keep mapping exactly as before.
@Suite("Open source license URLs")
struct IkaOpenSourceLicenseTests {
  private func license(repoURL: String) -> IkaOpenSourceLicense {
    .init(repoURL: repoURL, type: "MIT", typeDescription: "MIT License", content: "")
  }

  @Test(arguments: [
    ("https://github.com/SwiftyJSON/SwiftyJSON", "https://api.github.com/repos/SwiftyJSON/SwiftyJSON/license"),
    ("https://github.com/notbd/SimpleHaptics", "https://api.github.com/repos/notbd/SimpleHaptics/license"),
    ("https://github.com/sparrowcode/AlertKit", "https://api.github.com/repos/sparrowcode/AlertKit/license"),
    ("https://github.com/apple/swift-collections", "https://api.github.com/repos/apple/swift-collections/license"),
    ("https://github.com/misenhower/splatoon2.ink", "https://api.github.com/repos/misenhower/splatoon2.ink/license"),
  ])
  func `Repo URL maps to the license API URL`(repoURL: String, apiURL: String) {
    #expect(IkaOpenSourceLicense.githubAPIURLString(fromRepoURL: repoURL) == apiURL)
  }

  @Test(arguments: [
    ("https://api.github.com/repos/SwiftyJSON/SwiftyJSON", "https://github.com/SwiftyJSON/SwiftyJSON"),
    ("https://api.github.com/repos/apple/swift-collections", "https://github.com/apple/swift-collections"),
    ("https://api.github.com/repos/misenhower/splatoon2.ink", "https://github.com/misenhower/splatoon2.ink"),
  ])
  func `API URL maps back to the repo URL`(apiURL: String, repoURL: String) {
    #expect(IkaOpenSourceLicense.githubRepoURLString(fromAPIURL: apiURL) == repoURL)
  }

  @Test
  func `Non-GitHub URLs do not parse`() {
    #expect(IkaOpenSourceLicense.githubAPIURLString(fromRepoURL: "https://example.com/owner/repo") == nil)
    #expect(IkaOpenSourceLicense.githubRepoURLString(fromAPIURL: "https://example.com/no-repos-here") == nil)
  }

  @Test
  func `Owner and repo come from the repo URL`() {
    let simpleHaptics: IkaOpenSourceLicense = license(repoURL: "https://github.com/notbd/SimpleHaptics")
    #expect(simpleHaptics.ownerAndRepo == "notbd/SimpleHaptics")

    let dotted: IkaOpenSourceLicense = license(repoURL: "https://github.com/misenhower/splatoon2.ink")
    #expect(dotted.ownerAndRepo == "misenhower/splatoon2.ink")

    let hyphenated: IkaOpenSourceLicense = license(repoURL: "https://github.com/sparrow-code/swift-collections")
    #expect(hyphenated.ownerAndRepo == "sparrow-code/swift-collections")
  }

  @Test
  func `Non-GitHub repo URL falls back to the unknown placeholder`() {
    let unknown: IkaOpenSourceLicense = license(repoURL: "")
    #expect(unknown.ownerAndRepo == Constants.Key.Placeholder.unknown)
  }
}
