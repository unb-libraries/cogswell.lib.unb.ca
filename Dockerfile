FROM ghcr.io/unb-libraries/drupal:10.x-1.x-unblib

# Install additional OS packages.
ENV ADDITIONAL_OS_PACKAGES="postfix php-ldap php-xmlreader php-zip php81-pecl-redis"
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
LABEL ca.unb.lib.generator="drupal9" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="MIT" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.description="cogswell.lib.unb.ca provides selected Works of Fred Cogswell and a Critical Appraisal of his creative and cultural work." \
  org.label-schema.name="cogswell.lib.unb.ca" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://cogswell.lib.unb.ca" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/unb-libraries/cogswell.lib.unb.ca" \
  org.label-schema.vendor="University of New Brunswick Libraries" \
  org.label-schema.version=$VERSION \
  org.opencontainers.image.authors="UNB Libraries <libsupport@unb.ca>" \
  org.opencontainers.image.source="https://github.com/unb-libraries/cogswell.lib.unb.ca"
