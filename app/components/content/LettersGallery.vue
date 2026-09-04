<script setup>
const lightbox = ref()

// One entry per scan; multi-page items are separate entries.
const letters = [
  { file: 'bourinot.jpg', caption: 'Letter to Arthur Bourinot' },
  { file: 'nowlan.jpg', caption: 'Letter to Alden Nowlan' },
  { file: 'reidpath.jpg', caption: 'Letter to Alan Reidpath' },
  { file: 'saffel.jpg', caption: 'Letter to Hilmur Saffel' },
  { file: 'ashman.jpg', caption: 'Letter to Richard Ashman' },
  { file: 'holmes1.jpg', caption: 'Letter to Lawrence Holmes (p 1/2)' },
  { file: 'holmes2.jpg', caption: 'Letter to Lawrence Holmes (p 2/2)' },
  { file: 'hatfield1.jpg', caption: 'Letter to Richard Hatfield (p 1/2)' },
  { file: 'hatfield2.jpg', caption: 'Letter to Richard Hatfield (p 2/2)' },
  { file: 'webb1.jpg', caption: 'Letter to Phyllis Webb (p 1/4)' },
  { file: 'webb2.jpg', caption: 'Letter to Phyllis Webb (p 2/4)' },
  { file: 'webb3.jpg', caption: 'Letter to Phyllis Webb (p 3/4)' },
  { file: 'webb4.jpg', caption: 'Letter to Phyllis Webb (p 4/4)' },
  { file: 'mcdougall.jpg', caption: 'Letter to Robert McDougall' },
  { file: 'brewster1.jpg', caption: 'Letter to Elizabeth Brewster (p 1/2)' },
  { file: 'brewster2.jpg', caption: 'Letter to Elizabeth Brewster (p 2/2)' },
  { file: 'colombo1.jpg', caption: 'Letter to John Robert Colombo (p 1/2)' },
  { file: 'colombo2.jpg', caption: 'Letter to John Robert Colombo (p 2/2)' },
  { file: 'hayes1.jpg', caption: 'Letter to Miss Hayes (p 1/3)' },
  { file: 'hayes2.jpg', caption: 'Letter to Miss Hayes (p 2/3)' },
  { file: 'hayes3.jpg', caption: 'Letter to Miss Hayes (p 3/3)' },
  { file: 'orlovitz1.jpg', caption: 'Letter to Gil Orlovitz (p 1/2)' },
  { file: 'orlovitz2.jpg', caption: 'Letter to Gil Orlovitz (p 2/2)' },
  { file: 'livesay.jpg', caption: 'Letter to Dorothy Livesay' },
]
</script>

<template>
  <div>
    <ul class="letters-grid">
      <li v-for="(letter, i) in letters" :key="letter.file">
        <figure>
          <a
            :href="`/images/letters/${letter.file}`"
            :title="letter.caption"
            @click.prevent="lightbox?.open(i)"
          >
            <img
              :src="`/images/letters/thumbs/${letter.file}`"
              :alt="letter.caption"
              width="170"
              height="220"
              loading="lazy"
            >
          </a>
          <figcaption>{{ letter.caption }}</figcaption>
        </figure>
      </li>
    </ul>
    <GalleryLightbox ref="lightbox" :images="letters" src-base="/images/letters" />
  </div>
</template>
