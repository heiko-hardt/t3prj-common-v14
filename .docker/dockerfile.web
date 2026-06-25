# Distro: Debian 13.x trixie (https://hub.docker.com/_/php)
# Source: https://github.com/docker-library/php/blob/master/8.4/trixie/apache/Dockerfile
FROM php:8.4.22-apache-trixie

# Application User & Group
ARG APP_USER_NAME=developer 
ARG APP_USER_ID=1000
ARG APP_GROUP_NAME=developer
ARG APP_GROUP_ID=1000

# Webserver
ARG WEB_SERVER_NAME=localhost
ARG WEB_DOCUMENT_ROOT=/var/www/html/public

# Common tools and local settings
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# System user and group
RUN groupadd -g $APP_GROUP_ID $APP_GROUP_NAME \
    && useradd -u $APP_USER_ID -g $APP_GROUP_ID -m -s /bin/bash $APP_USER_NAME \
    && echo $APP_USER_NAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/$APP_USER_NAME \
    && chmod 0440 /etc/sudoers.d/$APP_USER_NAME

# Apache Webserver
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    # Enable module(s)
    && a2enmod rewrite \
    # Configure document root
    ###############################################################################################
    && sed -i -e "s|/var/www/html|$WEB_DOCUMENT_ROOT|g" /etc/apache2/sites-available/*.conf \
    # Configure ports
    && sed -i "s|Listen 80|Listen 8080|g" /etc/apache2/ports.conf \
    && sed -i "s|\:80>|\:8080>|g" /etc/apache2/sites-available/*.conf \
    # Configure user
    && sed -i "s|\${APACHE_RUN_USER\:=www-data}|\${APACHE_RUN_USER\:=$APP_USER_NAME}|g" /etc/apache2/envvars \
	&& sed -i "s|\${APACHE_RUN_GROUP\:=www-data}|\${APACHE_RUN_GROUP\:=$APP_GROUP_NAME}|g" /etc/apache2/envvars


# PHP extensions: exif, gd, intl, pdo_mysql, zip
# https://docs.typo3.org/m/typo3/reference-coreapi/main/en-us/Administration/Installation/SystemRequirements/Index.html
###################################################################################################
RUN apt-get update \
    && apt-get install -y --no-install-recommends \       
        ghostscript \
        graphicsmagick \
        libfreetype-dev \
        libicu-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
        libzip-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install exif \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) zip


# https://getcomposer.org/download/ (Latest LTS)
ARG COMPOSER_VERSION="2.10.1"
# https://packagist.org/packages/xdebug/xdebug
ARG PHP_XDEBUG_VERSION="3.5.1"
# https://github.com/php/pie/releases
ARG PIE_VERSION="1.4.0"
# https://github.com/aptible/supercronic/releases
ARG SUPERCRONIC_VERSION="0.2.34"
# Target architecture setup by buildx (linux/amd64, linux/arm64, linux/arm/v7)
ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        default-mysql-client \
        git \
        git-flow \
        make \
        mc \
        openssh-client \
        sqlite3 \
        unzip  \
        vim \
        wget \
        zsh \
    && rm -rf /var/lib/apt/lists/* \
    # Setup PIE (PHP Installer for Extensions)
    && curl -L https://github.com/php/pie/releases/download/${PIE_VERSION}/pie.phar -o /usr/local/bin/pie \
    && chmod +x /usr/local/bin/pie \
    # Install Extension(s)
    && pie install xdebug/xdebug:${PHP_XDEBUG_VERSION} \
    # Copy php ini (php.ini-development|php.ini-production)
    && cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    # Add custom ini parameter
    && printf "[PHP]\nmemory_limit = 512M\nmax_execution_time = 3600\nmax_input_vars = 1500\npcre.jit = 1\nupload_max_filesize = 50M\npost_max_size = 50M\n\n[Date]\ndate.timezone = Europe/Berlin\n" > "$PHP_INI_DIR/conf.d/additional.ini" \
    # Fetch & install composer binary
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --version=${COMPOSER_VERSION} --filename=composer \
    # Supercronic
    && curl -fsSLO "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
    && chmod +x "supercronic-linux-${TARGETARCH}" \
    && mv "supercronic-linux-${TARGETARCH}" /usr/local/bin/supercronic


USER ${APP_USER_NAME}:${APP_GROUP_NAME}

ENV TZ=Europe/Berlin \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | zsh

EXPOSE 8080

WORKDIR /var/www/html
