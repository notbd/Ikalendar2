//
//  ModeBadge.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ModeBadge

/// The small glass badge at the trailing end of the compact-width nav bar that the mode stamp
/// docks into while the list scrolls up. It shows the stamp's image upright, like a toolbar icon.
struct ModeBadge: View {
  typealias Scoped = Constants.Style.Overlay.ModeIcon

  /// The asset images redrawn at badge size, keyed by name, point size and display scale.
  @MainActor static private var resampledImages: [String: UIImage] = [:]

  @Environment(\.displayScale) private var displayScale

  let flatMode: FlatMode

  var body: some View {
    badgeImage
      .frame(
        width: imageSize,
        height: imageSize)
      .offset(y: imageOffsetY)
      .frame(
        width: Scoped.badgeSize,
        height: Scoped.badgeSize)
      // Mr. Grizz's antenna reaches past the circle once his body is centered.
      .clipShape(.circle)
      // Not interactive: the badge is decoration, so it must not react to touches.
      .adaptiveGlassEffect(isInteractive: false, in: .circle)
      // The navigation title already names the mode.
      .accessibilityHidden(true)
  }

  /// The image as resampled for the badge, drawn pixel for pixel; the plain asset only if the
  /// asset cannot be loaded as a UIImage.
  @ViewBuilder
  private var badgeImage: some View {
    if let image = Self.resampled(imageName, toFit: imageSize, scale: displayScale) {
      Image(uiImage: image)
    }
    else {
      Image(decorative: imageName)
        .ikaFitted()
    }
  }

  private var imageName: String {
    flatMode.battleMode?.imageNameLarge ?? Scoped.iconImageNameSalmon
  }

  /// Sized so the visible artwork looks the same size in every mode: its area matches, then the
  /// regular image is taken down and Mr. Grizz up a step by eye, since the regular image's bold
  /// white arrow reads larger and the dark statue reads smaller than the ranked and league shields.
  private var imageSize: CGFloat {
    switch flatMode {
      case .regular:
        Scoped.badgeImageSizeRegular
      case .gachi,
           .league:
        Scoped.badgeImageSize
      case .salmon:
        Scoped.badgeImageSizeSalmon
    }
  }

  /// Mr. Grizz sits in the lower part of his canvas (under his antenna), so he is lifted to put his
  /// body in the middle of the badge; the other images are centered in theirs.
  private var imageOffsetY: CGFloat {
    flatMode == .salmon ? Scoped.badgeImageOffsetYSalmon : 0
  }

  /// The asset redrawn to fit a `side`-point square at `scale` with high-quality resampling, cached.
  /// The artwork is 256 to 447 px across; shrunk to badge size by `resizable()`, the GPU's filter
  /// samples only a few of the source pixels behind each screen pixel and leaves jagged edges.
  @MainActor
  static private func resampled(_ name: String, toFit side: CGFloat, scale: CGFloat) -> UIImage? {
    let key = "\(name)@\(side)x\(scale)"
    if let cached = resampledImages[key] { return cached }
    guard let source = UIImage(named: name) else { return nil }

    let fit: CGFloat = min(side / source.size.width, side / source.size.height)
    let size: CGSize = .init(width: source.size.width * fit, height: source.size.height * fit)
    let format: UIGraphicsImageRendererFormat = .init()
    format.scale = scale
    let image: UIImage = UIGraphicsImageRenderer(size: size, format: format).image { context in
      context.cgContext.interpolationQuality = .high
      source.draw(in: CGRect(origin: .zero, size: size))
    }
    resampledImages[key] = image
    return image
  }
}

#Preview {
  ModeBadge(flatMode: .gachi)
}
