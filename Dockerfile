FROM ubuntu:18.04

RUN echo "UTC" > /etc/localtime

RUN apt-get update && apt-get install -y \
	php-apcu php-console-table php-pear php7.2-ldap \
	php7.2-fpm php7.2-cli php7.2-common php7.2-curl php7.2-dev php7.2-gd php7.2-gmp php7.2-mysql \
	libcurl4-openssl-dev libxml2-dev mime-support unzip vim \
	apache2 \
	ca-certificates curl supervisor git cron mysql-client ssmtp \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN a2enmod ssl rewrite headers proxy_fcgi remoteip

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor /var/run/php /mnt/sites-files /etc/confd/conf.d /etc/confd/templates

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer \
&& ln -s /usr/local/bin/composer /usr/bin/composer

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Install Confd
ADD https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd

# Add line to crontab to prevent mail from being sent
RUN sed -i '/SHELL/iMAILTO=""' /etc/crontab

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY www.conf /etc/php/7.2/fpm/pool.d/www.conf
COPY site.conf /etc/apache2/sites-enabled/000-default.conf
COPY php.ini /etc/php/7.2/fpm/php.ini
COPY remoteip.conf /etc/apache2/conf-enabled/remoteip.conf
COPY confd /etc/confd/
COPY apache2.conf /etc/apache2/apache2.conf

# Copy in specific files
COPY config /root/
COPY bash_aliases /root/.bash_aliases
#COPY wordpress-settings /root/wordpress-settings/

# Volumes
VOLUME /var/www/site /etc/apache2/sites-enabled /mnt/sites-files

EXPOSE 80

WORKDIR /var/www/site

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
