import { defineConfig } from 'vitepress'
import type { DefaultTheme } from 'vitepress'

const title = "ikalendar2"
const description = "Track Splatoon 2 Rotations with Style and Ease"
const version = '2.3.2'
const ogUrl = 'https://ikalendar.app'

const Nav: DefaultTheme.NavItem[] = [
  { text: 'Home', link: '/' },
  { text: 'Privacy Policy', link: '/privacy-policy' },
  {
    text: `v${version}`,
    items: [
      {
        text: 'Release Notes',
        link: 'https://github.com/notbd/Ikalendar2/releases',
      },
    ],
  },
]

// https://vitepress.dev/reference/site-config
export default defineConfig({
  lang: 'en',
  title,
  titleTemplate: `:title · ${title}`,
  description,
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico', type: 'image/png', sizes: '128x128' }],
    ['link', { rel: 'apple-touch-icon', href: '/apple-touch-icon.png', sizes: '180x180' }],
    ['meta', { name: 'viewport', content: 'width=device-width, initial-scale=1' }],
    ['meta', { name: 'author', content: 'Tianwei Zhang' }],
    ['meta', { name: 'creator', content: 'Tianwei Zhang' }],
    ['meta', { name: 'generator', content: 'VitePress' }],
    ['meta', { name: 'keywords', content: 'ikalendar, ikalendar2, splatoon, splatoon2, rotation, schedule, tracker, salmon run' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:url', content: ogUrl }],
    ['meta', { name: 'og:title', content: title }],
    ['meta', { name: 'og:description', content: description }],
    ['meta', { name: 'og:sitename', content: 'ikalendar2.app' }],
    ['meta', { property: 'og:image', content: '/assets/icon-square-1024.png' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title', content: title }],
    ['meta', { name: 'twitter:description', content: description }],
    ['meta', { name: 'twitter:creator', content: '@ikalendar_app' }],
    ['meta', { name: 'twitter:creatorId', content: '1565930842802851843' }],
    ['meta', { name: 'twitter:image', content: '/assets/banner-2_1-1024.png' }],
    ['meta', { name: 'twitter:url', content: ogUrl }],
  ],
  cleanUrls: true,
  themeConfig: {
    logo: '/assets/icon-squircle-128.png',
    // https://vitepress.dev/reference/default-theme-config
    nav: Nav,
    sidebar: [
      {
        text: 'Docs',
        items: [
          { text: 'Privacy Policy', link: '/privacy-policy' },
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/notbd/Ikalendar2' },
      { icon: 'twitter', link: 'https://twitter.com/ikalendar_app' }
    ]
  }
})
