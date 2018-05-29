#!/bin/bash

# Run Confd to make config files
/usr/local/bin/confd -onetime -backend env

# Export all env vars containing "_" to a file for use with cron jobs
printenv | grep \_ | sed 's/^\(.*\)$/export \1/g' | sed 's/=/=\"/' | sed 's/$/"/g' > /root/project_env.sh
chmod +x /root/project_env.sh

# Add gitlab to hosts file
grep -q -F "$GIT_HOSTS" /etc/hosts  || echo $GIT_HOSTS >> /etc/hosts

# Add cron jobs
if [[ ! -n "$PRODUCTION" || $PRODUCTION != "true" ]] ; then
  sed -i "/git pull/s/[0-9]\+/5/" /root/config/crons.conf
fi

# Clone repo to container
git clone --depth=1 -b $GIT_BRANCH $GIT_REPO /var/www/site/
chown www-data:www-data -R /var/www/site

# Symlink files folder
mkdir -p /mnt/sites-files/public
mkdir -p /mnt/sites-files/private
chown www-data:www-data -R /mnt/sites-files/public
chown www-data:www-data -R /mnt/sites-files/private
mkdir -p $APACHE_DOCROOT/sites/default
cd $APACHE_DOCROOT/wp-content && ln -sf /mnt/sites-files/public uploads

if [[ -n "$LOCAL" &&  $LOCAL = "true" ]] ; then
  echo "[$(date +"%Y-%m-%d %H:%M:%S:%3N %Z")] NOTICE: Setting up XDebug based on state of LOCAL envvar"
  /usr/bin/apt-get update && apt-get install -y \
    php7.2-xdebug \
    --no-install-recommends && rm -r /var/lib/apt/lists/*
  cp /root/config/xdebug-php.ini /etc/php/7.2/fpm/php.ini
  /usr/bin/supervisorctl restart php-fpm
fi

# Install appropriate apache config and restart apache
if [[ -n "$WWW" &&  $WWW = "true" ]] ; then
  cp /root/config/wwwsite.conf /etc/apache2/sites-enabled/000-default.conf
fi

# Import starter.sql, if needed
/root/mysqlimport.sh

# Create Wordpress settings, if they don't exist as a symlink
ln -s $APACHE_DOCROOT /root/apache_docroot
/root/wordpress-settings.sh

# Load configs
/root/load-configs.sh

# Settings for production sites
if [[ -n "$PRODUCTION" && $PRODUCTION = "true" ]] ; then
  grep -q -F 'Header set X-Robots-Tag "noindex, nofollow"' /etc/apache2/sites-enabled/000-default.conf || sed -i 's/.*\/VirtualHost.*/\tHeader set X-Robots-Tag \"noindex, nofollow\"\n\n&/' /etc/apache2/sites-enabled/000-default.conf
fi

# set permissions on php log
chmod 640 /var/log/php7.2-fpm.log
chown www-data:www-data /var/log/php7.2-fpm.log

crontab /root/config/crons.conf
/usr/bin/supervisorctl restart apache2
