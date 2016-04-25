#!/bin/bash
set -e

if [ ! -e '/var/www/html/index.php' ]; then
    tar cf - --one-file-system -C /usr/src/flarum . | tar xf -
    sleep 20
    php flarum install --defaults
    mysql -hdb -uflarum -pflarum flarum < /usr/src/flarum/config.sql
fi

cp /usr/src/flarum/config.php .
chown -R www-data /var/www/html

exec "$@"
