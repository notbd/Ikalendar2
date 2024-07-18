<script setup lang="ts">
import { useData } from 'vitepress'
import HomeDependencies from './theme/HomeDependencies.vue'
import HomeDemo from './theme/HomeDemo.vue'

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
