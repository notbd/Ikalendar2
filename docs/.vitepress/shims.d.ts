// virtual module provided by the UnoCSS vite plugin
declare module 'virtual:uno.css'

// vitepress ships this composable without types; DependenciesGrid.vue reuses its sponsor grid layout
declare module 'vitepress/dist/client/theme-default/composables/sponsor-grid.js' {
  export function useSponsorsGrid(options: { el: import('vue').Ref<HTMLElement | null>, size?: string }): void
}
