FROM alpine:3.16

LABEL description="Simple forum software for building great communities" \
      maintainer="smoxy <smoxy@sf-paris.dev>" \
      credit="Magicalex <magicalex@mondedie.fr>"

ARG VERSION=v1.7.0

ENV GID=991 \
    UID=991 \
    UPLOAD_MAX_SIZE=50M \
    PHP_MEMORY_LIMIT=128M \
    OPCACHE_MEMORY_LIMIT=128 \
    DB_HOST=mariadb \
    DB_USER=flarum \
    DB_NAME=flarum \
    DB_PORT=3306 \
    FLARUM_TITLE=Docker-Flarum \
    DEBUG=false \
    LOG_TO_STDOUT=false \
    GITHUB_TOKEN_AUTH=false \
    FLARUM_PORT=8888

RUN apk add --no-progress --no-cache \
    curl \
    git \
    icu-data-full \
    libcap \
    nginx \
    php8 \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-fileinfo \
    php8-fpm \
    php8-gd \
    php8-gmp \
    php8-iconv \
    php8-intl \
    php8-mbstring \
    php8-mysqlnd \
    php8-opcache \
    php8-pecl-apcu \
    php8-openssl \
    php8-pdo \
    php8-pdo_mysql \
    php8-phar \
    php8-session \
    php8-tokenizer \
    php8-xmlwriter \
    php8-zip \
    php8-zlib \
    su-exec \
    s6 \
    busybox-initscripts \
    openrc \
  && cd /tmp \
  && curl --progress-bar http://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && sed -i 's/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/' /etc/php8/php.ini \
  && chmod +x /usr/local/bin/composer \
  && mkdir -p /run/php /flarum/app \
  && COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum:$VERSION /flarum/app \
  && composer clear-cache \
  && rm -rf /flarum/.composer /tmp/* \
  && setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx \
  && 
  && cd /flarum/app \
  && composer require flarum-lang/italian \
  && composer require askvortsov/flarum-categories \
  && composer require xelson/flarum-ext-chat \
  && composer require nearata/flarum-ext-copy-code-to-clipboard:"*" \
  && composer require "fof/subscribed:*" \
  && composer require clarkwinkelmann/flarum-ext-first-post-approval \
  && composer require the-turk/flarum-nodp \
  && composer require ianm/level-ranks:"*" \
  && composer require webbinaro/flarum-calendar \
  && composer require fof/sitemap \
  && composer require fof/socialprofile \
  && composer require fof/merge-discussions:"*" \
  && composer require fof/best-answer:"*" \
  && composer require justoverclock/edit-posts:"*" \
  && composer require askvortsov/flarum-checklist:* \
  && composer require ralkage/flarum-hcaptcha:"*" \
  && composer require nearata/flarum-ext-embed-video \
  && composer require the-turk/flarum-flamoji \
  && composer require fof/polls \
  && composer require fof/pretty-mail:"*" \
  && composer require fof/secure-https:"*" \
  && composer require fof/spamblock:"*" \
  && composer require fof/recaptcha:"*" \
  && composer require blomstra/fontawesome:"*" \
  && composer require v17development/flarum-seo \
  && composer require yannisme/oxotheme \
  && composer require acpl/mobile-tab:"*" \
  && composer require blomstra/welcome-login:"*" \
  && composer require antoinefr/flarum-ext-money \
  && composer require clarkwinkelmann/flarum-ext-money-rewards \
  && composer require clarkwinkelmann/flarum-ext-money-to-all \
  && composer require fof/doorman:"*"
  #&& composer require justoverclock/custom-html-widget:"*" \
  #&& composer require justoverclock/custom-header:"*" \

COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/run /etc/s6.d/.s6-svscan/*
VOLUME /etc/nginx/flarum /flarum/app/extensions /flarum/app/public/assets /flarum/app/storage/logs
CMD ["/usr/local/bin/startup"]
