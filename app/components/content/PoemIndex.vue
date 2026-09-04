<script setup>
// Grouped index built from the poems collection, so it cannot drift out of step
// with the poem pages themselves.
const { data: poems } = await useAsyncData('poem-index', () =>
  queryCollection('poems')
    .order('bookOrder', 'ASC')
    .select('path', 'title', 'book', 'bookOrder')
    .all())

const books = computed(() => {
  const grouped = new Map()
  for (const poem of poems.value ?? []) {
    if (!grouped.has(poem.book))
      grouped.set(poem.book, [])
    grouped.get(poem.book).push(poem)
  }
  return [...grouped].map(([title, entries]) => ({ title, entries }))
})
</script>

<template>
  <div class="poem-index">
    <template v-for="book in books" :key="book.title">
      <p class="poem-index__book">
        {{ book.title }}
      </p>
      <ul class="poem-index__poems">
        <li v-for="poem in book.entries" :key="poem.path">
          <NuxtLink :to="poem.path">
            {{ poem.title }}
          </NuxtLink>
        </li>
      </ul>
    </template>
  </div>
</template>
