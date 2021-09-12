##
## Build graph-composer.phar artifact
##
FROM php:7-alpine AS builder

# See https://github.com/opencontainers/image-spec/blob/main/annotations.md
# See https://spdx.org/licenses/
LABEL org.opencontainers.image.authors  = "Patrick Nelson (pat@catchyour.com)"
LABEL org.opencontainers.image.source   = "https://github.com/patricknelson/graph-composer-docker"
LABEL org.opencontainers.image.licenses = "GPL-3.0-or-later"

# Install git (only for cloning/building the graph-composer phar)
RUN apk add --update --no-cache \
		git

# Get composer
# TODO: Install default version (currently composer v2) once bug fixed in phar build stage. See: https://github.com/clue/graph-composer/issues/58
RUN COMPOSER_HOME=$HOME_DIR/.composer \
	&& /usr/bin/curl -sS https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

# Configure PHP to allow phar builds
COPY conf.d/*.ini /usr/local/etc/php/conf.d/

# Pull down graph-composer, install its composer dependencies and build a fresh phar from the main branch of the repo
WORKDIR /root
RUN git clone https://github.com/clue/graph-composer.git \
	&& cd graph-composer \
    && composer install --dev \
    && composer build \
    # Normalize artifact filename...
    && mv *.phar /root/graph-composer.phar \
    # Clean up mess (image should only contain composer + our phar)
    && cd /root/ \
    && rm -rf /root/graph-composer \
    && rm -rf /root/.composer/cache


##
## Install graph-composer.phar and associated dependencies
##

FROM php:7-alpine AS final

COPY --from=builder /root/graph-composer.phar /usr/local/bin

# Installs graph-composer.phar dependencies (without the fonts, we'll get little boxes)
RUN apk add --update --no-cache \
		graphviz \
        ttf-freefont

# Important: Ensure container runs as unprivileged user (to protect mounted files).
USER www-data
WORKDIR /graph-composer

