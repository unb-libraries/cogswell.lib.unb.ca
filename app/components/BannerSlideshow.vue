<script setup lang="ts">
// Banners cross-fading on a timer. Purely decorative, so the slideshow is
// hidden from assistive technology, and it holds still when the visitor prefers
// reduced motion.
const banners = [
  'cogswell.jpg',
  'hatfield.jpg',
  'livesay.jpg',
]

const INTERVAL = 7000

// Below this the banner is not shown at all: the 1400x240 crop would scale down
// to a ~77px sliver that reads as noise rather than an image. It has to be
// stated twice — as a Tailwind `md:` variant to drop the element, and as a media
// query on each <source> so the files are never downloaded — so the two must be
// kept in step. 48rem is Tailwind's `md`.
const WIDE = '(min-width: 48rem)'

// A 1x1 transparent GIF. Below WIDE this is the candidate the browser picks,
// and being a data URI it costs no request; `display: none` alone does not stop
// an <img> from being fetched.
const BLANK = 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACwAAAAAAQABAAACAkQBADs='

const index = ref(0)
let timer: ReturnType<typeof setInterval> | undefined

onMounted(() => {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches)
    return
  timer = setInterval(() => {
    index.value = (index.value + 1) % banners.length
  }, INTERVAL)
})

onBeforeUnmount(() => clearInterval(timer))
</script>

<template>
  <div class="relative hidden aspect-[1400/240] w-full overflow-hidden md:block" aria-hidden="true">
    <picture v-for="(file, i) in banners" :key="file">
      <source :media="WIDE" :srcset="`/images/banners/${file}`">
      <img
        :src="BLANK"
        alt=""
        width="1400"
        height="240"
        class="absolute inset-0 h-full w-full object-cover transition-opacity duration-1000 motion-reduce:transition-none"
        :class="i === index ? 'opacity-100' : 'opacity-0'"
      >
    </picture>
  </div>
</template>
