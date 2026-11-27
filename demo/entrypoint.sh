#!/bin/sh
set -eu

SITE="${MYBBFORUMS_DEMO_SITE:-/var/lib/mybbforums-demo/site}"
SEED="/opt/mybb-seed"

mkdir -p "$SITE"
if [ ! -f "$SITE/inc/class_core.php" ]; then
    cp -a "$SEED/." "$SITE/"
fi

mkdir -p \
    "$SITE/inc" \
    "$SITE/cache/themes" \
    "$SITE/uploads/avatars" \
    "$SITE/uploads/profile_images" \
    "$SITE/admin/backups"

chown -R www-data:www-data /var/lib/mybbforums-demo
chmod 0755 "$SITE"

if [ ! -f "$SITE/install/lock" ]; then
    chmod 0775 "$SITE/inc" "$SITE/cache" "$SITE/cache/themes" \
        "$SITE/uploads" "$SITE/uploads/avatars" "$SITE/uploads/profile_images" \
        "$SITE/admin/backups"
fi

sed -ri "s!/var/www/html!$SITE!g" \
    /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf

apache2ctl configtest
printf 'Starting MyBBForums demo site at %s\n' "$SITE"
exec apache2-foreground
