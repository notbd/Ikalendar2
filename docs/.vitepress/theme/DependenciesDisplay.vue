<script setup lang="ts">
import type { DependencyCategory } from './HomeDependencies.vue'
import DependenciesGrid from './DependenciesGrid.vue'

const props = defineProps<{
  data: DependencyCategory[]
}>()

const dependencyCategories = props.data
</script>

<template>
  <div class="VPSponsors vp-sponsor normal">
    <section
      v-for="(category, index) in dependencyCategories"
      :key="index"
      class="vp-sponsor-section"
    >
      <h2
        v-if="category.tier"
        class="vp-sponsor-tier"
      >
        {{ category.tier }}
      </h2>
      <DependenciesGrid :size="category.size" :data="category.items" />
    </section>
  </div>
</template>
