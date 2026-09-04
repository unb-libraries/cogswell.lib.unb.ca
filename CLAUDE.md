# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A static Nuxt 4 site presenting Tony Tremblay's *Fred Cogswell: The Many-Dimensioned Self*
for UNB Libraries — a digital volume that is both a Selected Works of Fred Cogswell and a
critical appraisal of his work. There is no backend, API, database, or state management —
this is content, not an application.

94 pages: 33 prose pages and 57 poems from `content/`, two hand-written pages, and the
error pages.

## Commands

Package manager is pnpm (`packageManager: pnpm@11.10.0`). The host may not have a new
enough Node — `docker compose up` brings its own Node and pnpm and is the reliable way to
run this repo.

- `pnpm dev` — start dev server, using `NUXT_SITE_URI`/`NUXT_PORT` from `.env` for the
  public URL and allowed host (defaults to `localhost:3000` if unset)
- `pnpm build` — production build (SSR output)
- `pnpm generate` — static site generation (this is what the Docker production image uses)
- `pnpm preview` — preview a production build locally
- `pnpm lint` / `pnpm lint:fix` — ESLint (`@antfu/eslint-config`) over the whole repo
- `pnpm install` runs `nuxt prepare` via `postinstall` (`scripts/postinstall.mjs`), which skips itself when `CI=true` or `NODE_ENV=production`. That guard lets the Dockerfile install dependencies from the manifests alone, before copying `app/` and `content/`, so a content edit does not reinstall `node_modules`.

There is no test setup configured in this repo. Linting and commit messages are enforced
via Husky git hooks: `pre-commit` runs `lint-staged` (ESLint `--fix` on staged files),
`commit-msg` runs `commitlint`, which expects the team's `JIRA-123 subject` format rather
than Conventional Commits.

## Architecture

- **Nuxt 4 app directory layout**: source lives under `app/` (`app/layouts/`, `app/pages/`,
  `app/components/`, `app/assets/`), not the Nuxt 3-style root layout. There is no
  `app/app.vue` — the default layout is the shell.
- **Content lives in `content/`, not in components.** The volume's prose is Markdown files
  containing blocks of HTML, read through `@nuxt/content` v3. `content.config.ts` defines
  two collections:
  - `book` (`content/book/*.md`) — the 33 prose pages, in reading order.
  - `poems` (`content/poems/*.md`) — the 57 reprinted poems.

  **Filenames are numbered** (`04.biography.md`, `01.valley-folk.md`) because ordering is
  load-bearing: `queryCollectionItemSurroundings` walks `stem`, so the number is what makes
  the prev/next pager follow the volume's reading order instead of the alphabet. The
  numeric prefix is stripped from the route (`/book/biography`).
- **Frontmatter fields** are validated by the Zod schemas in `content.config.ts`:
  `title`, optional `navTitle` (short label for pagers and contents lists, where `title` is
  too long), and `oldPath` (the page's path on the previous version of the site, the basis
  for redirects if they are ever added). Poems additionally carry `book` and `bookOrder`,
  which group and order them in the index.
- **Routing**: `app/pages/book/[slug].vue` and `app/pages/poems/[slug].vue` render a
  collection entry; `index.vue` and `copyright.vue` are hand-written. Each page sets its
  own title with `useHead`; the global template (`%s | Fred Cogswell: The
  Many-Dimensioned Self`) is in `nuxt.config.ts`.
- **`BookPager` serves both collections** via its `collection` prop. Its `fields` prop is
  not decoration: `queryCollectionItemSurroundings` selects real SQL columns, so asking a
  collection for a field its schema doesn't declare fails at query time — `navTitle` exists
  on `book` only, which is why the poem page passes `:fields="['title']"`. This failure
  does **not** fail the build: `pnpm generate` still reports success while logging
  `no such column` and rendering empty pagers. If you touch the pager, check a poem page
  and a chapter page actually have prev/next links in `.output/public`.
- **MDC components must be global.** `PoemIndex` and `LettersGallery` are used from inside
  Markdown (`::poem-index`), which only resolves globally-registered components, so
  `nuxt.config.ts` registers everything in `app/components/content/` with `global: true`.
  Anything not used from Markdown belongs in `app/components/` instead.
- **`PoemIndex` is derived, not written out.** It queries the `poems` collection and
  groups on `book`/`bookOrder`, so the index cannot drift out of step with the poem
  pages.
- **Styling**: Tailwind CSS v4 via the `@tailwindcss/vite` plugin (no `tailwind.config.js`
  — v4 uses CSS-based config). Theme tokens are in `app/assets/css/main.css` under
  `@theme` and consumed as utility classes (`bg-navbar`, `text-link`, `font-header`).
  Colours belong in `@theme`, not as arbitrary values in templates.
- **The content HTML depends on component classes in `main.css`**, not on utility classes
  in templates: `.stanza`/`.line` (verse), `.citation` (bibliography hanging indent),
  `.footnote`/`.footnotes`/`.footnote-ref`/`.footnote-backref`, `.align-right`
  (epigraphs), `.indent`/`.indent-2` (block quotations). Removing one of these silently
  breaks the pages that use it, and nothing in the templates will show that.
- **That list is the whole set**, and the only `<span>` class in `content/` is `line`.
- **Bibliography hanging indents are page-driven.** The seven `bibliography-*` sub-pages
  and `works-cited` are pure lists of entries, so every paragraph carries `.citation`
  (Works Cited's leading note excepted). `/book/bibliography` is a contents page, not an
  entry list, and correctly has none.
- **Footnotes are numbered continuously across the whole site**, not per page, and
  anchors are keyed on that number (`#fn3` / `#fnref3`) so they are unique site-wide.
- **Static assets** live in `public/` and are referenced by absolute path
  (`/files/cogswell.pdf`, `/images/letters/thumbs/webb1.jpg`). Letter thumbnails and the
  1400×240 banners are committed derivatives, because the site is served by static nginx
  with no image server.

## Local development

- `NUXT_PORT` (3086) and `NUXT_SITE_URI` in `.env` drive the dev server's host/port, public
  URL, and the Vite HMR websocket (which listens on `NUXT_PORT * 10`, 30860).
- `docker-compose.yml` runs the `development` target of the `Dockerfile`, bind-mounting
  `app/`, `content/`, `public/`, `content.config.ts`, `nuxt.config.ts` and `.nuxt`. Note
  that `content/` **must** be mounted for content edits to appear.

## Deployment

- **CI**: `.github/workflows/deployment-workflow.yaml` calls
  `unb-libraries/github-workflows/.github/workflows/build-push-deploy-notify.yaml@1.x` —
  build → push to GHCR → `kubectl set image` → prune → Slack. Two tags per build: the
  immutable `<short-sha>-<timestamp>` that the deploy pins, and the mutable `:dev` the Helm
  chart names for a cold start.
- **`Dockerfile`**: `base` is pure toolchain (no `COPY`, so it stays cached); `build`
  installs from the manifests *before* copying the rest, so editing `content/` does not
  reinstall `node_modules`; the final stage is `ghcr.io/unb-libraries/nuxt-ssg:3.23.x`,
  which carries the nginx config — `try_files`, the `/health` endpoint the chart's probes
  require, gzip, and the asset cache. There is no per-repo nginx config.
- **The build fails on the silent-pager failure below.** `pnpm run generate` is piped through
  `tee` under `pipefail` and the log is grepped for `no such column`, because that error
  leaves generate exiting 0 with empty pagers. `scripts/verify-generate.mjs` then asserts
  every page implied by `content/` was prerendered.
- **Kubernetes**: `unb-libraries/kubernetes-metadata`,
  `services/cogswell.lib.unb.ca/02_frontend_nuxt/`, chart `unblib-daemon-nuxt-ssg`, serving
  `dev-cogswell.lib.unb.ca`. The `prod` branch still holds the Drupal build and deploys the
  `unblib-daemon-drupal` component.
- Because the site is generated statically, any change to pages or content requires a
  rebuild to take effect — there is no server-side rendering at runtime.

## Gotchas

- **`display: none` does not stop an `<img>` from downloading**, and neither does adding
  `loading="lazy"` — measured against a request log, a hidden lazy `<img>` was still
  fetched at every viewport. That is why `BannerSlideshow` uses `<picture>` with a
  `media`-gated `<source>` and a 1×1 data-URI fallback: the data URI is the candidate the
  browser picks below the breakpoint, so nothing is requested. The breakpoint therefore
  appears twice in that component — as the Tailwind `md:` variant that drops the element,
  and as the `WIDE` media query that gates the download. Keep them in step.
- **`watch(() => route.path)` in the layout fires once during hydration**, not only on
  navigation. It closes the mobile menu, so the spurious fire is harmless — but it means
  you cannot test the open state by defaulting `isMenuOpen` to `true`: SSR renders it open
  and hydration immediately closes it again. Disable the watch too if you need to inspect
  the open panel.
- **`html { scrollbar-gutter: stable }` in `main.css` is load-bearing**, not cosmetic:
  without it the centred column jumps sideways by the scrollbar's width when you navigate
  between a page that scrolls and one that does not.
- **The shell is `max-w-[1400px]`, deliberately.** It matches the banner images' native
  width. Prose runs long at that width (~200 chars/line) — a chosen trade-off, not an
  oversight, so don't narrow the shell to "fix" it. If the measure is ever addressed, do it
  with a centred `max-width` on `.book-body` and leave the shell alone.
- **The header column has exactly one gutter.** `px-6` sits on the single wrapper in
  `default.vue`, so the navbar band, the banner and the body text all end flush with the
  site title. Nothing inside that wrapper should add its own horizontal padding.
- The nav `<ul>` carries `px-3`, which combines with each link's own `px-3` to give
  "Home" the same 24px lead-in as the gap between two menu items. The gap between items is
  two lots of link padding, so if you change the link padding, change the list's to match
  or the first item stops looking evenly spaced.
- **`public/files/cogswell.pdf` is ~50 MB** and is embedded on the home page. It dominates
  both the repository size and the home page's first paint.
- **No redirects from the previous URLs yet.** Every page records `oldPath`, but nothing
  consumes it. See README.md for what a redirect pass has to cover.
