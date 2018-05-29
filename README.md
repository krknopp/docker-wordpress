# docker-wordpress

Custom build for Wordpress deployments.  

Consists of Ubuntu 18.04, PHP7.2 (FPM) and Apache 2.4.

# Environment variables
* VIRTUAL_HOST= FQDN of website with a "." at the beginning
* WWW= "true" if the site should redirect to www.fqdn
* PRODUCTION= "true" if the site is production (affects Git pulls and drupal settings)
* GIT_HOSTS= Hosts file entry to be added
* GIT_REPO= URL of Git repo to pull from
* GIT_BRANCH= Git branch
* MYSQL_SERVER= Host name of MySQL server
* MYSQL_DATABASE= MySQL database name
* MYSQL_USER= MySQL user name
* MYSQL_PASSWORD= MySQL password
* WP_HTTPS= on or off
* WP_HOME= FQDN
* WP_SITEURL= FQDN

* APACHE_DOCROOT= Apache Docroot - defaults to `/var/www/site/docroot`
* SESAuthUser= AWS SES SMTP username starting with 'AuthUser='
* SESAuthPass= AWS SES SMTP password starting with 'AuthPass='
* SESmailhub= AWS SES SMTP address, with port
* CONF_REPO= Repo for config files (php.ini and 000-default.conf)
* CONF_REPO_BRANCH= Branch for CONF_REPO

# BASH aliases
`mysqlc` connects to MySQL based on Environment Variables
`mysqld > file.sql` dumps database to file.sql based on Environment Variables


https://hub.docker.com/r/codekoalas/drupal8/

