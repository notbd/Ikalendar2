<script setup lang="ts">
import { useData } from 'vitepress'
import HomeDependencies from './theme/HomeDependencies.vue'

const { frontmatter } = useData()
const dependencies = frontmatter.value.dependencies
</script>

<template>
  <HomeDependencies
    v-if="dependencies"
    :dependencies="dependencies"
  />
</template>
