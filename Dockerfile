ARG PHP_VERSION
FROM php:${PHP_VERSION}-cli-alpine AS base

COPY --from=forumone/f1-ext-install:latest \
  /f1-ext-install \
  /usr/bin/f1-ext-install

RUN set -ex \
  && f1-ext-install \
    builtin:bcmath \
    builtin:exif \
    builtin:gd \
    builtin:mysqli \
    builtin:opcache \
    builtin:zip \
    pecl:imagick \
  # Settings taken from library's WordPress image
  && { \
    echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
    echo 'display_errors = Off'; \
    echo 'display_startup_errors = Off'; \
    echo 'log_errors = On'; \
    echo 'error_log = /dev/stderr'; \
    echo 'log_errors_max_len = 1024'; \
    echo 'ignore_repeated_errors = On'; \
    echo 'ignore_repeated_source = Off'; \
    echo 'html_errors = Off'; \
  } > /usr/local/etc/php/conf.d/error-logging.ini \
  && apk add --no-cache \
    bash \
    less \
    mysql-client \
    openssh

ARG WP_CLI_VERSION

RUN set -ex \
  && cd /tmp \
  && curl -o wp -fsSL https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar \
  && curl -o wp.sha512 -fsSL https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar.sha512 \
  && echo "$(cat wp.sha512)  wp" | sha512sum -c \
  && chmod +x wp \
  && mv wp /usr/local/bin/wp \
  && rm wp.sha512

WORKDIR /var/www/html
