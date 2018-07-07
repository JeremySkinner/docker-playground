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
    apache2 php7.0 php7.0-mysql libapache2-mod-php7.0 curl

# Enable apache mods.
RUN a2enmod php7.0
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
# RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.0/apache2/php.ini
# Enable error logging
RUN sed -i "s/display_errors = .$/display_errors = On/" /etc/php/7.0/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER web
ENV APACHE_RUN_GROUP web
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Expose apache.
EXPOSE 80

# Copy this repo into place.
# ADD . /var/sites

# Update the default apache site with the config we created.
ADD .docker/apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Script for managing virtual hosts
RUN wget -O /usr/local/bin/virtualhost https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost.sh
RUN chmod +x /usr/local/bin/virtualhost

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND