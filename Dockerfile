FROM php:7.2-fpm as base

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/extractsystem/

# Set working directory
WORKDIR /var/www/extractsystem

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www/extractsystem

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/extractsystem

# Change current user to www
USER www

# Change current user to root
USER root
RUN sed -i s/'user = www-data'/'user = www'/g /usr/local/etc/php-fpm.d/www.conf
RUN sed -i s/'group = www-data'/'group = www'/g /usr/local/etc/php-fpm.d/www.conf

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]

