---
layout: home

hero:
  image:
    src: /assets/icon-squircle-1024.png
    alt: Logo for ikalendar2
  name: ikalendar2
  text: Track Splatoon 2 Rotations with Style and Ease
  tagline: Fast · Intuitive · Customizable
  appStoreLink: https://apps.apple.com/app/id1529193361
  appStoreImageDark: /assets/download-app-store-EN-black.svg
  appStoreImageLight: /assets/download-app-store-EN-white.svg
  compatibility: Requires iOS and iPadOS 17.0 or later.
  actions:
    # first action button will be replaced by the App Store badge
    - theme: brand
      text: Download on the App Store
      link: https://apps.apple.com/app/id1529193361
    - theme: brand
      text: View on GitHub
      link: https://github.com/notbd/Ikalendar2

features:
  - icon: <span class="i-gravity-ui:compass"/>
    title: Your Companion
    details: ikalendar2 is your ideal companion for tracking Splatoon 2 schedules. Keep yourself up-to-date with a clear glance at the latest rotation info whether you are on iPhone or iPad.
  - icon: <span class="i-tabler:brand-swift"/>
    title: Clean and Swifty
    details: Unlike the clutter and clumsiness from traditional sources, ikalendar2 is built with a clean interface in SwiftUI, leveraging the latest APIs to deliver a fast and modern app experience.
  - icon: <span class="i-gravity-ui:cloud-check"/>
    title: Auto Refresh
    details: The seamless auto-refresh system always fetches the latest available info on your behalf so that you will never mistime a match in the future. Peace of mind. Phew.
  - icon: <span class="i-ic:round-animation"/>
    title: Animated
    details: Find game-inspired aesthetics and animations throughout the app. Rotation tracking doesn't have to be boring! :)
  - icon: <span class="i-gravity-ui:palette"/>
    title: Customization
    details: Plenty of customization options let you tweak the look and layout of the app to best suit your playstyle.
  - icon: <span class="i-hugeicons:translate"/>
    title: Multi-Language Support
    details: App localization is available for English and Japanese.

dependencies:
  message: ikalendar2 is free and open source, made possible by these following projects.
  content:
    - tier: Data Sources
      size: big
      items:
        - name: misenhower/splatoon2.ink
          url: https://github.com/misenhower/splatoon2.ink/wiki/Data-access-policy#data-urls
          icon: github
        - name: JelenzoBot
          url: https://splatoon.oatmealdome.me/about
    - tier: Open Source Libraries
      size: big
      items:
        - name: SwiftyJSON/SwiftyJSON
          url: https://github.com/SwiftyJSON/SwiftyJSON
          icon: github
          description: The better way to deal with JSON data in Swift.
        - name: notbd/SimpleHaptics
          url: https://github.com/notbd/SimpleHaptics
          icon: github
          description: Simple and easy haptics generation.
        - name: sparrowcode/AlertKit
          url: https://github.com/sparrowcode/AlertKit
          icon: github
          description: Alerts that resemble native style from Apple Music.

demo:
  image:
    src: /assets/demo-universal.webp
    alt: ikalendar2 in action on iPhone and iPad
  imageCompact:
    phoneSrc: /assets/demo-phone-duo.webp
    phoneAlt: ikalendar2 in action on iPhone
    tabletSrc: /assets/demo-tablet.webp
    tabletAlt: ikalendar2 in action on iPad
---

<!-- markdownlint-disable MD033 -->
<HomeCustomBody />
