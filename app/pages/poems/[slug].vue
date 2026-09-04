<script setup>
const route = useRoute()

const { data: poem } = await useAsyncData(`poem-${route.params.slug}`, () =>
  queryCollection('poems').path(route.path).first())

if (!poem.value) {
  throw createError({ statusCode: 404, statusMessage: 'Poem not found' })
}

useHead({ title: poem.value.title })
</script>

<template>
  <main class="book-body">
    <h1>{{ poem.title }}</h1>
    <div class="poem">
      <ContentRenderer :value="poem" />
    </div>
    <p class="poem-attribution">
      From <em>{{ poem.book }}</em>. Reprinted with permission of Kathleen
      Forsythe, Cogswell's literary executor.
      <NuxtLink to="/book/selected-poems">
        Back to Selected Poems
      </NuxtLink>
    </p>
    <BookPager collection="poems" :path="poem.path" :fields="['title']" />
  </main>
</template>
