#!/bin/bash

# if not a symlinked settings.php, replace with confd version
if [ ! -h $APACHE_DOCROOT/wp-config.php ]
  then
    /usr/local/bin/confd -onetime -backend env -confdir="/root/wordpress-settings"
fi
