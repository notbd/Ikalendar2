<script setup>
import { onMounted, ref, watch } from 'vue'
import { useData } from 'vitepress'

const props = defineProps(['lightSrc', 'darkSrc', 'alt'])
const { isDark } = useData()
const currentSrc = ref('')

onMounted(() => {
  currentSrc.value = isDark.value ? props.darkSrc : props.lightSrc
})

watch(isDark, (newValue) => {
  currentSrc.value = newValue ? props.darkSrc : props.lightSrc
})
</script>

<template>
  <img v-if="currentSrc" :src="currentSrc" :alt="alt">
</template>
