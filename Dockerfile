FROM node:26-alpine AS base

ENV APP_ROOT=/nuxt

ENV NODE_ENV=production

ENV NUXT_SITE_ID=cogswell
ENV NUXT_SITE_URI=cogswell.lib.unb.ca
ENV NUXT_SITE_UUID=906240bd-956b-432e-a633-382367d3e843
ENV HUSKY=0

WORKDIR $APP_ROOT

# Deliberately no COPY: keeps this layer pure toolchain, and cached.
RUN apk update && \
    apk add bash && \
    npm install -g corepack && \
    corepack enable pnpm


# Local development image
FROM base AS development

ENV NODE_ENV=development

COPY . .

RUN apk update && \
    apk add curl && \
    pnpm install

CMD ["pnpm", "dev"]


# Throw-away build image
FROM base AS build

# Install from the manifests alone, so editing content/ does not reinstall node_modules.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
# pnpm runs `postinstall` and `prepare` during install, so both files must exist by then.
COPY scripts/postinstall.mjs ./scripts/
COPY .husky/install.mjs ./.husky/

RUN pnpm install --frozen-lockfile --prod=false

COPY . .

# `no such column` is a BookPager field error that generate reports on stdout while still
# exiting 0, shipping empty pagers. pipefail keeps tee from hiding a real generate failure.
RUN bash -o pipefail -c 'pnpm run generate 2>&1 | tee /tmp/gen.log' && \
    ! grep -qi 'no such column' /tmp/gen.log && \
    node scripts/verify-generate.mjs


# Deployment image
FROM ghcr.io/unb-libraries/nuxt-ssg:3.23.x

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Into $APP_WEBROOT, not over it: the base image ships .well-known/ there.
COPY --from=build /nuxt/.output/public/ ${APP_WEBROOT}/

LABEL ca.unb.lib.generator="nuxt-ssg" \
  org.opencontainers.image.title="cogswell.lib.unb.ca" \
  org.opencontainers.image.description="Fred Cogswell: The Many-Dimensioned Self - selected works and a critical appraisal." \
  org.opencontainers.image.vendor="University of New Brunswick Libraries" \
  org.opencontainers.image.authors="UNB Libraries <libsupport@unb.ca>" \
  org.opencontainers.image.url="https://cogswell.lib.unb.ca" \
  org.opencontainers.image.source="https://github.com/unb-libraries/cogswell.lib.unb.ca" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.created="$BUILD_DATE"
