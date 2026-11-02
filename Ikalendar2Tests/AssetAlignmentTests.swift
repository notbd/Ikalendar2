//
//  AssetAlignmentTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import IkalendarKit
import Testing
import UIKit
@testable import Ikalendar2

// MARK: - AssetAlignmentTests

/// Every image name the models can produce must resolve in the app's asset catalog: a
/// missing or misspelled asset ships as a blank image, and nothing else would notice.
/// The bundle is hosted, so `UIImage(named:)` and `AssetImageCounter` resolve against the
/// real app bundle. Pure lookups with no shared state, so the suite runs in parallel.
@Suite("Asset alignment")
struct AssetAlignmentTests {
  // MARK: - Battle stages

  @Test(arguments: BattleStage.allCases)
  func `Battle stage base image exists`(stage: BattleStage) {
    expectAsset(stage.imageName)
  }

  @Test(arguments: BattleStage.allCases.filter { $0 != .shiftyStation })
  func `General alt images are contiguous and under the ceiling`(stage: BattleStage) {
    expectContiguousAltImages(prefix: stage.imageName + "_Alt_", allowsNone: false)
  }

  @Test(arguments: BattleStage.allCases, BattleRule.allCases)
  func `Rule-specific alt images are contiguous and under the ceiling`(stage: BattleStage, rule: BattleRule) {
    expectContiguousAltImages(prefix: stage.imageName + "_Alt+\(rule.abbreviation)_", allowsNone: true)
  }

  @Test(arguments: BattleStage.allCases.filter { $0 != .shiftyStation }, BattleRule.allCases)
  func `Battle alt image names resolve to real assets`(stage: BattleStage, rule: BattleRule) {
    // Several rotations per pair, so the seeded pick lands on more than one index.
    for index in 0 ..< 8 {
      let rotation: BattleRotation = TestData.battleRotation(
        startOffset: TimeInterval(index) * 7200,
        endOffset: TimeInterval(index + 1) * 7200,
        rule: rule,
        stageA: stage,
        stageB: stage)
      expectAsset(rotation.stageAAltImageName)
      expectAsset(rotation.stageBAltImageName)
    }
  }

  /// Known gap, pinned on purpose: Shifty Station ships no alt images at all, so the
  /// tests above exclude it. This deliberately does not assert what the alt image name
  /// resolves to for it; update it consciously once alt images are added.
  @Test
  func `Shifty Station has no alt images`() {
    let prefix: String = BattleStage.shiftyStation.imageName + "_Alt"

    #expect(AssetImageCounter.countImagesWithPrefix(prefix + "_") == 0)
    for rule in BattleRule.allCases {
      #expect(AssetImageCounter.countImagesWithPrefix(prefix + "+\(rule.abbreviation)_") == 0)
    }
  }

  // MARK: - Salmon stages

  @Test(arguments: SalmonStage.allCases)
  func `Salmon stage base and large images exist`(stage: SalmonStage) {
    expectAsset(stage.imageName)
    expectAsset(stage.imageNameLarge)
  }

  @Test(arguments: SalmonStage.allCases)
  func `Salmon alt images are contiguous and come with large copies`(stage: SalmonStage) {
    let prefix: String = stage.imageName + "_Alt_"
    expectContiguousAltImages(prefix: prefix, allowsNone: false)

    let numberOfImages: Int = AssetImageCounter.countImagesWithPrefix(prefix)
    for index in 0 ..< numberOfImages {
      expectAsset("\(prefix)\(index)_Large")
    }
  }

  @Test(arguments: SalmonStage.allCases)
  func `Salmon alt image names resolve to real assets`(stage: SalmonStage) throws {
    // Several rotations per stage, so the seeded pick lands on more than one index.
    for index in 0 ..< 8 {
      let rotation: SalmonRotation = TestData.salmonRotation(
        startOffset: TimeInterval(index) * 172_800,
        endOffset: TimeInterval(index + 1) * 172_800,
        stage: stage)
      let altImageName: String = try #require(rotation.stageAltImageName)
      let altImageNameLarge: String = try #require(rotation.stageAltImageNameLarge)
      expectAsset(altImageName)
      expectAsset(altImageNameLarge)
    }
  }

  // MARK: - Modes and rules

  @Test(arguments: BattleRule.allCases)
  func `Battle rule images exist`(rule: BattleRule) {
    expectAsset(rule.imageNameMid)
    expectAsset(rule.imageNameLarge)
  }

  @Test(arguments: BattleMode.allCases)
  func `Battle mode stamp image exists`(mode: BattleMode) {
    expectAsset(mode.imageNameLarge)
  }

  // MARK: - Weapons

  @Test(arguments: IkaWeapon.allCases)
  func `Weapon images exist`(weapon: IkaWeapon) {
    expectAsset(weapon.imageName)
    expectAsset(weapon.imageNameSmall)
  }

  @Test(arguments: GrizzcoWeapon.allCases)
  func `Grizzco weapon images exist`(weapon: GrizzcoWeapon) {
    expectAsset(weapon.imageName)
    expectAsset(weapon.imageNameSmall)
  }

  @Test(arguments: MysteryWeapon.allCases)
  func `Mystery weapon images exist`(weapon: MysteryWeapon) {
    expectAsset(weapon.imageName)
    expectAsset(weapon.imageNameSmall)
  }

  // MARK: - Apparel

  @Test(arguments: HeadApparel.allCases)
  func `Head apparel images exist`(apparel: HeadApparel) {
    expectAsset(apparel.imageName)
    expectAsset(apparel.imageNameSmall)
  }

  @Test(arguments: BodyApparel.allCases)
  func `Body apparel images exist`(apparel: BodyApparel) {
    expectAsset(apparel.imageName)
    expectAsset(apparel.imageNameSmall)
  }

  @Test(arguments: FootApparel.allCases)
  func `Foot apparel images exist`(apparel: FootApparel) {
    expectAsset(apparel.imageName)
    expectAsset(apparel.imageNameSmall)
  }

  // MARK: - App icons

  @Test(arguments: IkaAppIcon.allCases)
  func `App icon preview images exist for every color and size`(icon: IkaAppIcon) {
    let sizes: [IkaAppIcon.DisplaySizeVariant] = [.large, .mid, .small]
    for color in IkaAppIcon.ColorVariant.allCases {
      for size in sizes {
        expectAsset(icon.imageName(for: .init(color: color, size: size)))
      }
    }
  }

  @Test
  func `Default app icon is the bundle's primary icon`() throws {
    let icons: [String: Any] = try bundleIcons()
    let primary: [String: Any] = try #require(icons["CFBundlePrimaryIcon"] as? [String: Any])

    #expect(primary["CFBundleIconName"] as? String == IkaAppIcon.default.iconSetName)
  }

  /// `setAlternateIconName` fails silently at runtime for a name the bundle does not register.
  @Test(arguments: IkaAppIcon.allCases.compactMap(\.alternateIconName))
  func `Alternate app icon is registered in the bundle`(name: String) throws {
    let icons: [String: Any] = try bundleIcons()
    let alternates: [String: Any] = try #require(icons["CFBundleAlternateIcons"] as? [String: Any])

    #expect(alternates[name] != nil)
  }

  // MARK: - Helpers

  private func bundleIcons() throws -> [String: Any] {
    try #require(Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any])
  }

  private func expectAsset(_ name: String, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(UIImage(named: name) != nil, "missing asset \"\(name)\"", sourceLocation: sourceLocation)
  }

  /// `AssetImageCounter` counts which of `prefix0` ... `prefix9` exist, and callers pick an
  /// index below that count. So the assets must be exactly `prefix0` ..< `prefix<count>`
  /// (a gap would let the pick land on a missing name), and the count must stay below the
  /// counter's documented ceiling of 10 (anything past it would silently never show).
  private func expectContiguousAltImages(
    prefix: String,
    allowsNone: Bool,
    sourceLocation: SourceLocation = #_sourceLocation)
  {
    let numberOfImages: Int = AssetImageCounter.countImagesWithPrefix(prefix)

    #expect(numberOfImages < 10, "\"\(prefix)\" reached the counter's ceiling", sourceLocation: sourceLocation)
    if !allowsNone {
      #expect(numberOfImages > 0, "no alt images for \"\(prefix)\"", sourceLocation: sourceLocation)
    }
    for index in 0 ..< numberOfImages {
      expectAsset("\(prefix)\(index)", sourceLocation: sourceLocation)
    }
  }
}
