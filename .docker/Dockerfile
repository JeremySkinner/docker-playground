FROM ubuntu:latest
MAINTAINER Jeremy Skinner <jeremy@jeremyskinner.co.uk>

# Setup timezone
ENV TZ=Europe/London
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install apache and PHP
RUN apt-get update && apt-get -y install software-properties-common \ 
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
    curl apache2 libapache2-mod-php7.0 php7.0 php7.0-mysql \
    php7.0-gd php7.0-dom php7.0-xml php7.0-simplexml


# Enable apache mods.
RUN a2enmod php7.0
RUN a2enmod rewrite

# Enable verbose errors
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/7.0/apache2/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/7.0/cli/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER web
ENV APACHE_RUN_GROUP web
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Expose apache.
EXPOSE 80

# Download drush/console:
#RUN \
#    wget -O /usr/local/bin/drush "https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar"; \
#    wget -O /usr/local/bin/drupal "https://github.com/hechoendrupal/drupal-console-launcher/releases/download/1.8.0/drupal.phar" \
#    chmod +x /usr/local/bin/drush && chmod +x /usr/local/bin/drupal

RUN service apache2 start