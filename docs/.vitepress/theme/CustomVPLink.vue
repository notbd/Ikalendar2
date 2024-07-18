<script lang="ts" setup>
import { computed } from 'vue'

const props = defineProps<{
  tag?: string
  href?: string
  noIcon?: boolean
  target?: string
  rel?: string
}>()

const tag = computed(() => props.tag ?? 'a')
</script>

<template>
  <component
    :is="tag"
    class="VPLink link"
    :class="{
      'no-icon': noIcon,
    }"
  >
    <slot />
  </component>
</template>
