FROM ghcr.io/unb-libraries/drupal:11.x-1.x-unblib

# Install additional OS packages.
ENV ADDITIONAL_OS_PACKAGES="postfix php${PHP_VERSION}-ldap php${PHP_VERSION}-pecl-redis php${PHP_VERSION}-xmlreader php${PHP_VERSION}-zip"
ENV DRUPAL_SITE_ID="cogswell"
ENV DRUPAL_SITE_URI="cogswell.lib.unb.ca"
ENV DRUPAL_SITE_UUID="ac1ac8fe-3818-46e4-92b1-b4b64ac6e0c3"

# Build application.
COPY ./build/ /build/
RUN ${RSYNC_MOVE} /build/scripts/container/ /scripts/ && \
  /scripts/addOsPackages.sh && \
  /scripts/initOpenLdap.sh && \
  /scripts/setupStandardConf.sh && \
  /scripts/build.sh

# Deploy configuration.
COPY ./configuration ${DRUPAL_CONFIGURATION_DIR}
RUN /scripts/pre-init.d/72_secure_config_sync_dir.sh

# Deploy custom modules, themes.
COPY ./custom/themes ${DRUPAL_ROOT}/themes/custom
COPY ./custom/modules ${DRUPAL_ROOT}/modules/custom

# Container metadata.
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL ca.unb.lib.generator="drupal11" \
  org.opencontainers.image.title="cogswell.lib.unb.ca" \
  org.opencontainers.image.description="cogswell.lib.unb.ca provides selected Works of Fred Cogswell and a Critical Appraisal of his creative and cultural work." \
  org.opencontainers.image.vendor="University of New Brunswick Libraries" \
  org.opencontainers.image.authors="UNB Libraries <libsupport@unb.ca>" \
  org.opencontainers.image.url="https://cogswell.lib.unb.ca" \
  org.opencontainers.image.source="https://github.com/unb-libraries/cogswell.lib.unb.ca" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.created="$BUILD_DATE"
