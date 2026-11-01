import { URL, fileURLToPath } from 'node:url'
import { defineConfig } from 'vitepress'
import type { DefaultTheme, HeadConfig } from 'vitepress'
import UnoCSS from 'unocss/vite'
import { extractIosAppVersion } from './utils/extractIosAppVersion'

const title = 'ikalendar2'
const description = 'Track Splatoon 2 Rotations with Style and Ease'
const version = extractIosAppVersion()
const baseDomain = 'ikalendar.app'
const baseUrl = `https://${baseDomain}`
const authorName = 'Tianwei Zhang'
const head: HeadConfig[] = [
  ['link', { rel: 'icon', href: '/favicon.ico' }],
  ['link', { rel: 'apple-touch-icon', href: '/apple-touch-icon.png', sizes: '180x180' }],
  ['meta', { name: 'viewport', content: 'width=device-width, initial-scale=1' }],
  ['meta', { name: 'author', content: authorName }],
  ['meta', { name: 'creator', content: authorName }],
  ['meta', { name: 'keywords', content: 'ikalendar, ikalendar2, splatoon, splatoon2, rotation, schedule, tracker, salmon run' }],
  ['meta', { property: 'og:type', content: 'website' }],
  ['meta', { property: 'og:title', content: `${title} · ${baseDomain}` }],
  ['meta', { property: 'og:description', content: description }],
  ['meta', { property: 'og:site_name', content: baseDomain }],
  ['meta', { property: 'og:image', content: `${baseUrl}/assets/app-icon-1024.png` }],
  ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
  ['meta', { name: 'twitter:title', content: `${title} · ${baseDomain}` }],
  ['meta', { name: 'twitter:description', content: description }],
  ['meta', { name: 'twitter:site', content: '@ikalendar_app' }],
  ['meta', { name: 'twitter:creator', content: '@ikalendar_app' }],
  ['meta', { name: 'twitter:creator:id', content: '1565930842802851843' }],
  ['meta', { name: 'twitter:image', content: `${baseUrl}/assets/banner-2_1-1024.png` }],
]

const Nav: DefaultTheme.NavItem[] = [
  { text: 'Home', link: '/' },
  { text: 'Privacy Policy', link: '/privacy-policy' },
  { text: 'License', link: 'https://github.com/notbd/Ikalendar2/blob/main/LICENSE' },
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

const Sidebar: DefaultTheme.SidebarItem[] = [
  {
    text: 'Docs',
    items: [
      { text: 'Privacy Policy', link: '/privacy-policy' },
    ],
  },
]

const Footer: DefaultTheme.Footer = {
  message: 'ikalendar2 is a third-party companion app for Splatoon 2 and is not affiliated with Nintendo.<br>All associated item names, logos, and trademarks are the property of their respective owners.<br>——<br>Released under the GPL-3.0 License.',
  copyright: 'Copyright © 2020-present Tianwei Zhang',
}

const SocialLinks: DefaultTheme.SocialLink[] = [
  { icon: 'github', link: 'https://github.com/notbd/Ikalendar2' },
  { icon: 'twitter', link: 'https://twitter.com/ikalendar_app' },
]

// https://vitepress.dev/reference/site-config
export default defineConfig({
  lang: 'en',
  title,
  description,
  head,
  // keep the GitHub-facing README out of the published site
  srcExclude: ['README.md'],
  sitemap: { hostname: baseUrl },
  cleanUrls: true,
  transformPageData(pageData) {
    // per-page canonical URL and og:url
    const canonicalUrl = `${baseUrl}/${pageData.relativePath}`
      .replace(/index\.md$/, '')
      .replace(/\.md$/, '')
    pageData.frontmatter.head ??= []
    pageData.frontmatter.head.push(
      ['link', { rel: 'canonical', href: canonicalUrl }],
      ['meta', { property: 'og:url', content: canonicalUrl }],
    )
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: '/assets/app-icon-128.png',
    search: { provider: 'local' },
    nav: Nav,
    sidebar: Sidebar,
    footer: Footer,
    socialLinks: SocialLinks,
  },
  vite: {
    plugins: [
      UnoCSS(),
    ],

    resolve: {
      alias: [
        // replace the default with custom implementations
        {
          find: /^.*\/VPHomeHero\.vue$/,
          replacement: fileURLToPath(
            new URL('./theme/CustomVPHomeHero.vue', import.meta.url),
          ),
        },
        {
          find: /^.*\/VPFeature\.vue$/,
          replacement: fileURLToPath(
            new URL('./theme/CustomVPFeature.vue', import.meta.url),
          ),
        },
      ],
    },
  },
})
