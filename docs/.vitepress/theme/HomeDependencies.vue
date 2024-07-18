<script setup lang="ts">
import DependenciesDisplay from './DependenciesDisplay.vue'

export type GridSize = 'xmini' | 'mini' | 'small' | 'medium' | 'big'

export type Dependencies = {
  message?: string
  content: DependencyCategory[]
}

export type DependencyCategory = {
  tier: string
  size?: GridSize
  items: Dependency[]
}

export type Dependency = {
  name: string
  url: string
  icon?: string
  description?: string
}

defineProps<{
  dependencies: Dependencies
}>()
</script>

<template>
  <section
    class="VPHomeSponsors"
  >
    <div
      class="container"
      m="0 auto"
      max="w-[1152px]"
    >
      <div class="header">
        <div class="love">
          <span class="vpi-heart icon" />
        </div>
        <h2 v-if="dependencies.message" class="message">
          {{ dependencies.message }}
        </h2>
      </div>

      <div class="sponsors">
        <DependenciesDisplay :data="dependencies.content" />
      </div>
    </div>
  </section>
</template>

<style scoped>
.VPHomeSponsors {
  margin: 96px 0;
  padding: 0 24px;
}

@media (min-width: 768px) {
  .VPHomeSponsors {
    margin: 128px 0;
    padding: 0 48px;
  }
}

@media (min-width: 960px) {
  .VPHomeSponsors {
    padding: 0 64px;
  }
}

.container {
  padding-top: 88px !important;
  border-top: 1px solid var(--vp-c-divider);
}

.love {
  margin: 0 auto;
  width: fit-content;
  font-size: 28px;
  color: var(--vp-c-text-3);
}

.icon {
  display: inline-block;
}

.message {
  margin: 0 auto;
  padding-top: 10px;
  max-width: 320px;
  text-align: center;
  line-height: 24px;
  font-size: 16px;
  font-weight: 500;
  color: var(--vp-c-text-2);
}

.sponsors {
  padding-top: 32px;
}

.action {
  padding-top: 40px;
  text-align: center;
}
</style>
