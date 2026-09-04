<script setup>
const props = defineProps({
  // Which collection to walk. Both are ordered by numbered filename, so the
  // pager follows reading order rather than the alphabet.
  collection: {
    type: String,
    default: 'book',
  },
  path: {
    type: String,
    required: true,
  },
  // Columns to select. `navTitle` exists on `book` only, and asking a
  // collection for a column it has no schema field for is a hard SQL error.
  fields: {
    type: Array,
    default: () => ['title', 'navTitle'],
  },
})

const { data: surroundings } = await useAsyncData(`pager-${props.collection}-${props.path}`, () =>
  queryCollectionItemSurroundings(props.collection, props.path, {
    before: 1,
    after: 1,
    fields: props.fields,
  }))

const previous = computed(() => surroundings.value?.[0] ?? null)
const next = computed(() => surroundings.value?.[1] ?? null)

// Fall back to the full title where no short label is set.
const label = entry => entry.navTitle ?? entry.title
</script>

<template>
  <ul class="book-pager">
    <li>
      <NuxtLink v-if="previous" :to="previous.path">
        &lsaquo; {{ label(previous) }}
      </NuxtLink>
    </li>
    <li class="text-right">
      <NuxtLink v-if="next" :to="next.path">
        {{ label(next) }} &rsaquo;
      </NuxtLink>
    </li>
  </ul>
</template>
