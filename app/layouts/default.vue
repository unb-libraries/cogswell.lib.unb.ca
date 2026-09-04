<script setup>
const route = useRoute()
const isHome = computed(() => route.path === '/')

const nav = [
  { to: '/', label: 'Home' },
  { to: '/book/preface-acknowledgements', label: 'Preface & Acknowledgements' },
  { to: '/book/biography', label: 'Biography' },
  { to: '/book/poetry-and-poetics', label: 'Poetry & Poetics' },
  { to: '/book/correspondence', label: 'Correspondence' },
  { to: '/book/bibliography', label: 'Bibliography' },
  { to: '/book/works-cited', label: 'Works Cited' },
]

// Only the linked page itself is highlighted, not the pages below it, so match
// exactly.
const isCurrent = to => route.path === to

const contact = `mailto:tremblay@stu.ca?subject=${encodeURIComponent('Fred Cogswell: The Many-Dimensioned Self')}`

// Below `md` (768px) the menu collapses behind a toggle. BannerSlideshow gates
// its images on the same breakpoint — keep the two in step.
const isMenuOpen = ref(false)
watch(() => route.path, () => {
  isMenuOpen.value = false
})
</script>

<template>
  <div class="min-h-screen bg-page">
    <NuxtRouteAnnouncer />
    <!-- One gutter for the whole column, so the navbar band and the banner end
         flush with the site title and the body text. -->
    <div class="mx-auto max-w-[1400px] px-6">
      <header class="pt-6">
        <component :is="isHome ? 'h1' : 'p'" class="mb-0 border-0 pb-0 font-header text-3xl">
          <NuxtLink to="/">
            Fred Cogswell: The Many-Dimensioned Self
          </NuxtLink>
        </component>
        <p class="mt-1 mb-4 font-header text-muted">
          by Tony Tremblay
        </p>
      </header>
      <nav aria-label="Main navigation" class="bg-navbar font-header text-sm">
        <!-- A 22px three-bar icon in a 10px/9px padded box, inset 15px from
             the band's edge. -->
        <div class="flex justify-end md:hidden">
          <button
            type="button"
            class="my-2 mr-[15px] rounded border border-rule px-[10px] py-[9px]"
            :aria-expanded="isMenuOpen"
            aria-controls="main-menu"
            @click="isMenuOpen = !isMenuOpen"
          >
            <span class="sr-only">Toggle navigation</span>
            <!-- the bars get their own flex parent, so the gap applies between
                 them and not after the screen-reader label -->
            <span aria-hidden="true" class="flex flex-col gap-[4px]">
              <span
                v-for="bar in 3"
                :key="bar"
                class="h-[2px] w-[22px] rounded-[1px] bg-toggle-bar"
              />
            </span>
          </button>
        </div>
        <!-- px-3 on the list plus px-3 on each link gives "Home" the same 24px
             lead-in as the gap between menu items. -->
        <ul
          id="main-menu"
          class="m-0 list-none p-0 md:flex md:flex-wrap md:px-3 md:py-0"
          :class="isMenuOpen ? 'block' : 'hidden'"
        >
          <li v-for="item in nav" :key="item.to">
            <NuxtLink
              :to="item.to"
              :aria-current="isCurrent(item.to) ? 'page' : undefined"
              class="block px-[15px] py-2.5 no-underline hover:bg-navbar-hover hover:no-underline md:px-3 md:py-2"
              :class="isCurrent(item.to) ? 'text-link' : 'text-white hover:text-white'"
            >
              {{ item.label }}
            </NuxtLink>
          </li>
          <li>
            <a
              :href="contact"
              class="block px-[15px] py-2.5 text-white no-underline hover:bg-navbar-hover hover:text-white hover:no-underline md:px-3 md:py-2"
            >
              Contact
            </a>
          </li>
        </ul>
      </nav>
      <BannerSlideshow v-if="isHome" />
      <div class="bg-content py-6">
        <slot />
      </div>
    </div>
  </div>
</template>
