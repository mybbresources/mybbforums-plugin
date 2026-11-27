FROM php:8.4-apache

ARG MYBB_VERSION=1.8.41

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
        libonig-dev libxml2-dev libzip-dev libsodium-dev unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd mbstring mysqli sodium xml zip \
    && a2enmod headers rewrite \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/mybb-seed
RUN curl --fail --location --silent --show-error \
        "https://resources.mybb.com/downloads/mybb_1841.zip" \
        --output /tmp/mybb.zip \
    && echo '00d4c742782e23319698c758293cd272d5fc9a6093caad739403fc99963331d8d7cfaafbd25d3acdf003c64b29b4f471568ce5c388b469947f756fee7917933e  /tmp/mybb.zip' | sha512sum --check --status \
    && unzip -q /tmp/mybb.zip -d /tmp/mybb-package \
    && cp -a /tmp/mybb-package/Upload/. /opt/mybb-seed/ \
    && rm -rf /tmp/mybb.zip /tmp/mybb-package

COPY mybbforums/mybbforums.php /opt/mybb-seed/inc/plugins/mybbforums.php
COPY mybbforums/inc/plugins/lib.php /opt/mybb-seed/inc/plugins/mybbforums/lib.php
COPY mybbforums/inc/tasks/mybbforums.php /opt/mybb-seed/inc/tasks/mybbforums.php
COPY mybbforums/admin/modules/config/mybbforums.php /opt/mybb-seed/admin/modules/config/mybbforums.php
COPY mybbforums/mybbforums-verify.php /opt/mybb-seed/mybbforums-verify.php
COPY demo/entrypoint.sh /usr/local/bin/mybbforums-demo-entrypoint

RUN chmod 0755 /usr/local/bin/mybbforums-demo-entrypoint \
    && mkdir -p /var/lib/mybbforums-demo/site \
    && printf '%s\n' \
        '<Directory /var/lib/mybbforums-demo/site>' \
        '    AllowOverride All' \
        '    Require all granted' \
        '</Directory>' \
        > /etc/apache2/conf-available/mybbforums-demo.conf \
    && a2enconf mybbforums-demo

ENV MYBBFORUMS_DEMO_SITE=/var/lib/mybbforums-demo/site
EXPOSE 80
ENTRYPOINT ["/usr/local/bin/mybbforums-demo-entrypoint"]
