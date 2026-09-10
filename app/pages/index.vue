<script setup>
useHead({ title: 'Home' })
</script>

<template>
  <main>
    <h1>Welcome</h1>
    <p>
      Welcome to <em>Fred Cogswell: The Many-Dimensioned Self</em>. This digital
      volume is both a Selected Works of Cogswell and a Critical Appraisal of his
      creative and cultural work. As such, it offers a broad entry to and
      assessment of the work of one of Canada’s most important literary
      modernists.
    </p>
    <p>
      The digital interface enables multiple points of access and use. Readers
      can use the PDF continuous-scrolling book immediately below. For more
      functionality, use the links above for quick access to the book text in
      searchable form. Students and scholars will find that function especially
      useful.
    </p>
    <embed
      src="/files/cogswell.pdf#view=FitV&amp;zoom=page-height"
      width="100%"
      height="800"
      type="application/pdf"
      class="shadow-md"
    >
    <p>
      The volume may be read online above, or downloaded as a
      <a href="/files/cogswell.pdf">PDF</a>.
    </p>
    <p>
      <NuxtLink to="/copyright">
        Copyright and Citation Information
      </NuxtLink>
    </p>
  </main>
</template>
