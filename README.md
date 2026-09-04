# cogswell.lib.unb.ca

UNB Libraries' presentation of Tony Tremblay's *Fred Cogswell: The
Many-Dimensioned Self* — a digital volume that is both a Selected Works of Fred
Cogswell and a critical appraisal of his creative and cultural work.

A static Nuxt 4 site: 94 pages, no backend, API, or database.

## Getting started

`NUXT_PORT` and `NUXT_SITE_URI` in `.env` drive the dev server's host/port, public URL, and
Vite HMR websocket (defaults to `localhost:3000` if unset).

### Run with Docker

Requires only [Docker](https://www.docker.com) — the container brings its own Node and pnpm.

```bash
docker compose up
```

This bind-mounts `app/`, `content/`, `public/`, `nuxt.config.ts`, `content.config.ts`,
`package.json`, and `pnpm-lock.yaml` into the container and runs `pnpm dev` inside it,
exposing `NUXT_PORT` (3086 by default) and its HMR websocket on `NUXT_PORT * 10` (30860).
Once you have pnpm on the host, `pnpm container:start` is the same command.

### Run locally

Requires [Node.js](https://nodejs.org) `^20.19 || >=22.12` (Vite 7's floor — the Docker
images use Node 26) and [pnpm](https://pnpm.io) 11.10.0.

```bash
pnpm install
pnpm dev
```

pnpm is most easily installed through Corepack, which picks up the version pinned by
`packageManager` in `package.json`:

```bash
corepack enable pnpm
```

If the Node.js your system provides is older than the range above, install a current
release with a version manager such as [fnm](https://github.com/Schniz/fnm),
[nvm](https://github.com/nvm-sh/nvm), [Volta](https://volta.sh), or
[mise](https://mise.jdx.dev) rather than replacing the system package.

### Configuration

Settings live in `nuxt.config.ts`. `NUXT_PORT` and `NUXT_SITE_URI` come from `.env` for
local development; in production they are set as container environment variables in the
`Dockerfile`.

## Development

| Command | Description |
| --- | --- |
| `pnpm dev` | Start the dev server |
| `pnpm build` | Production build (SSR output) |
| `pnpm generate` | Static site generation — this is what the production Docker image uses |
| `pnpm preview` | Preview a production build locally |
| `pnpm lint` / `pnpm lint:fix` | ESLint (`@antfu/eslint-config`) over the whole repo |

Husky git hooks enforce code quality on commit: `pre-commit` runs `lint-staged` (ESLint
`--fix` on staged files), `commit-msg` runs `commitlint` against the team's
`JIRA-123 subject` format.

There is no test setup configured in this repo.

## Structure

The volume's prose is content, not code, so it lives in `content/` as Markdown files
holding blocks of HTML, queried through [`@nuxt/content`](https://content.nuxt.com). Only
the two pages outside the book body (`/`, `/copyright`) are hand-written Vue pages.

- `content.config.ts` — two collections:
  - **`book`** (`content/book/*.md`) — the 33 pages of the volume, in reading order.
    Filenames are numbered (`04.biography.md`) so `stem` sorts into that order; the number
    is stripped from the route, giving `/book/biography`. `navTitle` supplies a short label
    where the full title is a quotation or otherwise unwieldy.
  - **`poems`** (`content/poems/*.md`) — the 57 poems reprinted in Chapter Two, each tagged
    with the Cogswell collection it first appeared in (`book`) and that collection's
    position in the index (`bookOrder`). Also numbered, so prev/next walks the poems in
    index order rather than alphabetically.

  Both carry `oldPath`, the page's path on the previous version of the site, so redirects
  can be generated from the collections. Nothing consumes it yet — see Known gaps.
- `app/pages/book/[slug].vue`, `app/pages/poems/[slug].vue` — render a collection entry
  with `<ContentRenderer>` and a prev/next pager.
- `app/pages/index.vue` — home: welcome text, the embedded PDF, and a contents list built
  from the six chapter openers.
- `app/pages/copyright.vue` — copyright and citation information.
- `app/layouts/default.vue` — the single shell: branding, the dark navbar, the banner
  slideshow (home only), and `<slot />`. Below `md` (768px) the menu collapses behind a
  toggle button and stacks vertically when open.
- `app/components/content/` — components used *from Markdown* via MDC, and so registered
  globally in `nuxt.config.ts`:
  - `PoemIndex.vue` — the Selected Poems index, grouped by collection. Built from the
    `poems` collection so it cannot drift out of step with the poem pages.
  - `LettersGallery.vue` — the grid of letter scans.
- `app/components/BannerSlideshow.vue` — three banners cross-fading on a 7s timer.
  Decorative, so it is hidden from assistive technology and holds still under
  `prefers-reduced-motion`. Not shown below `md`, where the 1400×240 crop would scale to a
  ~77px sliver; each `<picture>` gates its source on the same breakpoint so the three files
  (~175 KB) are not downloaded at those widths either.
- `app/components/GalleryLightbox.vue` — a native `<dialog>` lightbox, which supplies the
  modal overlay, `Esc` to close, focus trapping and top-layer stacking without a
  dependency. Caption plus `{current} of {total}` counter, prev/next (also bound to the
  arrow keys, with neighbours preloaded), a download link, and close on overlay click. The
  thumbnail anchors keep their real `href`, so the grid still resolves to the full-size
  scans without JavaScript.
- `app/components/BookPager.vue` — prev/next through either collection. Takes `collection`
  and `fields` props so the one component serves both the book and the poems.
- `app/assets/css/main.css` — Tailwind CSS v4 theme tokens (`@theme`) and the component
  classes the content HTML relies on (`.stanza`, `.line`, `.citation`, `.footnote`,
  `.align-right`, `.indent`). No `tailwind.config.js` — v4 uses CSS-based config.
- **Page width** is `max-w-[1400px]`, which is also the native width of the banner images.
  Prose therefore runs to ~200 characters a line; if that is ever revisited, a centred
  measure on `.book-body` is the one change needed, and the letters grid falls back to
  three columns.
- `public/files/cogswell.pdf` — the volume as a single PDF (~50 MB), embedded on the home
  page and offered for download.
- `public/images/banners/` — the three header banners, 1400×240.
- `public/images/letters/` — 24 letter scans (~700×900, ~120 KB each), with `thumbs/` for
  the grid at 220px tall. Both sets are committed rather than derived at runtime, since the
  site is served by static nginx with no image server.

## Known gaps

- **No redirects from the previous URLs.** `oldPath` is recorded on every page but nothing
  consumes it. If this site takes over `cogswell.lib.unb.ca`, add route rules (or nginx
  `location` blocks) mapping each `oldPath` to its new route — there are 57 poem paths
  alone. Three old paths have no target here and should 404 or redirect to their parent:
  `/content/reviews` and `/content/acknowledgements` were unlinked placeholder stubs, and
  `/content/preface` an unlinked earlier draft of `/book/preface-acknowledgements`.
- **The PDF is ~50 MB**, which is most of the repository's size and a slow first paint on
  the home page, where it is embedded. Worth a linearised or split derivative.

## Deployment

`.github/workflows/deployment-workflow.yaml` calls the shared pipeline in
[`unb-libraries/github-workflows`](https://github.com/unb-libraries/github-workflows): build
the image, push it to GHCR, then `kubectl set image` on the Kubernetes deployment. A push to
`dev` deploys to the `dev` namespace as `dev-cogswell.lib.unb.ca`; the `prod` branch still
holds the Drupal build and deploys prod on its own workflow.

The `Dockerfile` runs `pnpm generate` in a throw-away stage and serves the result from
[`ghcr.io/unb-libraries/nuxt-ssg`](https://github.com/unb-libraries/docker-nuxt-ssg), which
carries the nginx configuration for a generated Nuxt site. The build fails if the site is
incomplete or if generate logs `no such column` — see the pager gotcha below.

Because the site is generated statically, any change to pages or content requires a
rebuild to take effect — there is no server-side rendering at runtime.

## Entry points

- `/` — home page: welcome text, embedded PDF, contents.
- `/book/preface-acknowledgements` — Preface & Acknowledgements, and the start of the
  reading sequence that runs through to Works Cited.
- `/book/biography` — Chapter One, a Cogswell biography (six sub-pages).
- `/book/poetry-and-poetics` — Chapter Two, on the poetry and poetics (eleven sub-pages,
  ending in the Selected Poems index).
- `/book/selected-poems` — index of the 57 reprinted poems, grouped by collection.
- `/poems/*` — the poems themselves.
- `/book/correspondence` — Chapter Three, on Cogswell as editor and correspondent.
- `/book/letters` — the gallery of letter scans.
- `/book/bibliography` — Chapter Four, the bibliography (seven sub-pages).
- `/book/works-cited` — Works Cited.
- `/copyright` — copyright and citation information.
- `/files/cogswell.pdf` — the volume as a PDF.
