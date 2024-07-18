<script setup lang="ts">
import { ref } from 'vue'
import { useSponsorsGrid } from 'vitepress/dist/client/theme-default/composables/sponsor-grid.js'
import type { Dependency, GridSize } from './HomeDependencies.vue'

type Props = {
  size?: GridSize
  data: Dependency[]
}

const props = withDefaults(defineProps<Props>(), {
  size: 'medium',
})

const el = ref(null)

useSponsorsGrid({ el, size: props.size })
</script>

<template>
  <div ref="el" class="VPSponsorsGrid vp-sponsor-grid" :class="[size]">
    <div
      v-for="dependency in data"
      :key="dependency.name"
      class="vp-sponsor-grid-item"
    >
      <a
        class="vp-sponsor-grid-link"
        :href="dependency.url"
        target="_blank"
        rel="noreferrer noopener"
      >
        <article
          class="vp-sponsor-grid-box"
          text="md zinc-500 dark:zinc-400"
          font="mono semibold"
          hover:text="zinc-700 dark:zinc-700"
          transition-colors
        >
          <div
            :class="dependency.icon
              ? 'i-mingcute-github-line'
              : 'i-mingcute-link-2-line'"
            text-xl
            mr-2
          />
          {{ " " }}
          {{ dependency.name }}
        </article>
      </a>
    </div>
  </div>
</template>
