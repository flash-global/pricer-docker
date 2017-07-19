FROM ubuntu:16.04

MAINTAINER Jerome Schaeffer <j.schaeffer@flash-global.net>

ENV DEBIAN_FRONTEND noninteractive
ENV APP_ENV dev

RUN apt-get -qq update && \
    apt-get install -y apache2 php7.0 libapache2-mod-php  \
    php7.0-cli php7.0-mysql php7.0-xml php7.0-soap \
    php7.0-mcrypt php7.0-json php7.0-curl php7.0-zip \
    php-xdebug \
    php7.0-gd \
    pdftk a2ps ghostscript htmldoc ssh \
    telnet \
    php-common \
    && rm -rf /var/lib/apt/lists/*

# php-memcache depends on php-common (>= 1:7.0+33~)
# replace the php memcache with a fixed one
COPY php-memcache/php-memcache_3.0.9-20151130.fdbd46b-2.flash1_amd64.deb /home/php-memcache_3.0.9-20151130.fdbd46b-2.flash1_amd64.deb
RUN dpkg -i /home/php-memcache_3.0.9-20151130.fdbd46b-2.flash1_amd64.deb \
    && echo php-memcache hold | dpkg --set-selections \
    && rm /home/php-memcache_3.0.9-20151130.fdbd46b-2.flash1_amd64.deb
# the last part is usefull if you decide to do some updates though you ain't supposed to do so

COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY config/php.ini /etc/php/7.0/apache2/php.ini
COPY config/mime.conf /etc/apache2/mods-available/mime.conf
COPY config/xdebug.ini /etc/php/7.0/mods-available/xdebug.ini

#Symlinks for PDF executable
RUN ln -s /usr/bin/psjoin /usr/local/bin/psjoin \
    && ln -s /usr/bin/gs /usr/local/bin/gs \
    && ln -s /usr/bin/php /usr/local/bin/php

RUN a2enmod rewrite

#Create necessary folders
RUN mkdir -p /var/www/intranet/BROUILLONS \
    && chmod 777 /var/www/intranet/BROUILLONS \
    && mkdir /NASTEMPO \
    && chmod 777 /NASTEMPO

EXPOSE 80

ADD start.sh /start.sh
RUN chmod 0755 /start.sh
CMD ["bash", "start.sh"]