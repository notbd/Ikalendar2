<script setup lang="ts">
import { useData } from 'vitepress'
import HomeDemo from './theme/HomeDemo.vue'
import HomeDependencies from './theme/HomeDependencies.vue'

const { frontmatter } = useData()
const dependencies = frontmatter.value.dependencies
</script>

<template>
  <HomeDemo />
  <HomeDependencies
    v-if="dependencies"
    :dependencies="dependencies"
  />
</template>
