import { defineCollection, defineContentConfig, z } from '@nuxt/content'

export default defineContentConfig({
  collections: {
    // Prose pages. Filenames are numbered so `stem` sorts into reading order,
    // which is what the prev/next pager walks.
    book: defineCollection({
      type: 'page',
      source: 'book/*.md',
      schema: z.object({
        title: z.string(),
        // Short label for pager and contents links, where `title` is too long.
        navTitle: z.string().optional(),
        // Path this page had on the previous version of the site; the basis
        // for redirects, which are not configured yet.
        oldPath: z.string(),
      }),
    }),
    // Poems, grouped for the index by the work each belongs to.
    poems: defineCollection({
      type: 'page',
      source: 'poems/*.md',
      schema: z.object({
        title: z.string(),
        // Title of the work this poem belongs to.
        book: z.string(),
        // Position of that work in the index.
        bookOrder: z.number(),
        oldPath: z.string(),
      }),
    }),
  },
})
