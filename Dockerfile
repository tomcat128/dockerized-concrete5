FROM php:5.6.38-apache

MAINTAINER Tomasz Fehrenbacher admin@fewobacher.de

ENV C5_VERSION 8.3.1
ENV C5_URL https://www.concrete5.org/download_file/-/view/99963/8497/
ENV C5_BASEDIR /srv/app/public

RUN mkdir -p "$C5_BASEDIR"

WORKDIR /srv/app/

ENV APACHE_DOCUMENT_ROOT "$C5_BASEDIR"

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite
RUN a2enmod ssl

RUN apt-get update -y \
       && apt-get install -y libzip-dev \
       && apt-get install -y libfreetype6-dev \
       && apt-get install -y libmcrypt-dev \
       && apt-get install -y libjpeg-dev \
       && apt-get install -y libpng-dev \
       && apt-get install -y imagemagick imagemagick-doc \
       && apt-get install -y zlib1g-dev \
       && apt-get install -y wget \
       && apt-get install -y unzip

RUN docker-php-ext-configure \
       gd \
        --enable-gd-native-ttf \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-png-dir=/usr/include \
        --with-jpeg-dir=/usr/include

RUN docker-php-ext-install \
       pdo_mysql \
       zip \
       gd \
       calendar

RUN cd /usr/local/src \
    && wget --no-verbose $C5_URL -O concrete5.zip \
    && unzip -qq concrete5.zip -d concrete5 \
    && rm -rf "$C5_BASEDIR" \
    && mv "/usr/local/src/concrete5/concrete5-$C5_VERSION" "$C5_BASEDIR" \
    && rm -rf /usr/local/src/concrete5 /usr/local/src/concrete5.zip

RUN chown -R www-data:www-data /srv/app

RUN echo "Europe/Berlin" > /etc/timezone \
    && ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata