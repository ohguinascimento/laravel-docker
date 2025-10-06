FROM php:8.2-fpm-alpine

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instala dependências do sistema
RUN apk add --no-cache oniguruma-dev libxml2-dev libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip xml gd

WORKDIR /var/www

# Copia os arquivos de dependência e instala antes do resto para aproveitar o cache
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-plugins --no-scripts --prefer-dist

# Copia o restante dos arquivos da aplicação
COPY . .

# Cria os diretórios do Laravel e ajusta suas permissões
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache