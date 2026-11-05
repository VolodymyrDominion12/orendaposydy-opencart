# ---------------------------------------------------------------------------
# OpenCart 3.0.x — локальне середовище розробки
#
# Чому саме так:
#   * Apache, а не nginx — на проді LiteSpeed, який читає .htaccess.
#     OpenCart покладається на .htaccess для SEO-URL, тому Apache дає
#     однакову поведінку маршрутизації "локально == прод".
#   * PHP 7.4 за замовчуванням. Прод працює на PHP 7.3.33; 7.4 — найближча
#     версія, яку OpenCart 3.0.3.x офіційно підтримує. Якщо потрібна точна
#     відповідність — зберіть з PHP_VERSION=7.3 (див. .env).
#   * UID/GID контейнера = UID/GID вашого користувача на хості. Інакше
#     Apache (www-data, uid 33) не зможе писати в кеш, а ви не зможете
#     редагувати створені ним файли.
# ---------------------------------------------------------------------------

ARG PHP_VERSION=7.4
FROM php:${PHP_VERSION}-apache

# Переоголошуємо після FROM, щоб ARG був доступний у RUN
ARG PHP_VERSION
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Kyiv

# --- 1. Системні пакети + розширення PHP, потрібні OpenCart 3 ----------------
#
# ВАЖЛИВО про репозиторії Debian.
# Образи php:7.4-apache побудовані на Debian 11 (bullseye), який уже
# переведено в архів. Симптом оманливий: `apt-get update` ПРОХОДИТЬ успішно,
# а потім кожне завантаження .deb падає з "404 Not Found", і весь build
# завершується кодом 100. Тому для EOL-версій Debian ми одразу беремо пакети
# з archive.debian.org — офіційного архіву Debian, який віддає їх і надалі.
# Перевірка Valid-Until вимикається: підписи в архіві старіші за 90 днів.
RUN set -eux; \
    . /etc/os-release; \
    case "${VERSION_ID}" in \
        9|10|11) \
            echo ">>> Debian ${VERSION_ID} — EOL, пакети беремо з archive.debian.org"; \
            sed -i -e 's|deb\.debian\.org|archive.debian.org|g' \
                   -e 's|security\.debian\.org|archive.debian.org|g' \
                   -e '/-updates/d' \
                   -e '/-backports/d' /etc/apt/sources.list; \
            echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive; \
            cat /etc/apt/sources.list; \
            ;; \
    esac; \
    apt-get update -qq; \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libxml2-dev \
        libicu-dev \
        libxslt1-dev \
        zlib1g-dev \
        libbz2-dev \
        unzip \
        zip \
        git \
        default-mysql-client \
        less \
        nano \
        tzdata; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    # gd: у PHP 7.3 прапорці були з -dir, у 7.4+ — без
    if [ "$PHP_VERSION" = "7.3" ]; then \
        docker-php-ext-configure gd \
            --with-freetype-dir=/usr/include/ \
            --with-jpeg-dir=/usr/include/ \
            --with-webp-dir=/usr/include/; \
    else \
        docker-php-ext-configure gd \
            --with-freetype \
            --with-jpeg \
            --with-webp; \
    fi; \
    docker-php-ext-install -j"$(nproc)" \
        mysqli \
        pdo_mysql \
        gd \
        zip \
        curl \
        mbstring \
        xml \
        intl \
        soap \
        xsl \
        bcmath \
        bz2 \
        exif \
        gettext \
        opcache; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# --- 2. Apache --------------------------------------------------------------
# .htaccess мусить працювати: OpenCart 3 тримає в ньому і SEO-URL, і правила
# безпеки (заборона доступу до system/, config.php тощо).
RUN set -eux; \
    a2enmod rewrite headers expires deflate filter; \
    printf 'ServerName localhost\n' > /etc/apache2/conf-available/servername.conf; \
    a2enconf servername; \
    sed -ri 's/^\s*AllowOverride\s+None/AllowOverride All/g' /etc/apache2/apache2.conf; \
    sed -ri 's!^\s*<Directory /var/www/>!<Directory /var/www/html/>!' /etc/apache2/apache2.conf; \
    grep -n 'AllowOverride' /etc/apache2/apache2.conf

# --- 3. Користувач з UID хост-системи ---------------------------------------
RUN set -eux; \
    groupmod -g "${GID}" www-data 2>/dev/null || true; \
    usermod  -u "${UID}" -g "${GID}" www-data; \
    id www-data

# --- 4. Конфіг PHP для розробки ---------------------------------------------
COPY php-dev.ini /usr/local/etc/php/conf.d/zz-opencart-dev.ini

# --- 4b. ionCube Loader ------------------------------------------------------
# ОБОВ'ЯЗКОВИЙ для цього магазину. Частина файлів зашифрована ionCube:
#   system/library/simple/php/simple_*.php   (Simple / SimpleCheckout)
#   system/library/simple/php/filterit_*.php
#   catalog/language/uk-ua/extension/module/dream_filter.php
# Без завантажувача такий файл друкує "Site error: the ionCube PHP Loader
# needs to be installed" і завершує роботу. Симптом підступний: HTTP-код
# усе одно 200, тому моніторинг і `make check` бачили «робочий сайт», хоча
# у браузері був текст помилки замість магазину.
# На хостингу лоадер ставить панель; у нашому образі його треба покласти самим.
# zend_extension мусить стояти в conf.d ПЕРШИМ (файл 00-...), інакше частина
# зашифрованих файлів устигає завантажитись до лоадера.
#
# УВАГА про версію: офіційний образ php оголошує ENV PHP_VERSION=7.4.33, і це
# ENV перекриває ARG PHP_VERSION=7.4. ionCube ж називає лоадери лише
# major.minor (ioncube_loader_lin_7.4.so), тому беремо "${PHP_VERSION%.*}",
# інакше `cp` шукає ioncube_loader_lin_7.4.33.so і build падає.
RUN set -eux; \
    ext_dir="$(php -r 'echo ini_get("extension_dir");')"; \
    ts=""; \
    if php -i | grep -q 'Thread Safety => enabled'; then ts="_ts"; fi; \
    ioncube_ver="${PHP_VERSION%.*}"; \
    curl -fsSL -o /tmp/ioncube.tar.gz \
        https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz; \
    mkdir -p /tmp/ioncube; \
    tar -xzf /tmp/ioncube.tar.gz -C /tmp/ioncube; \
    cp "/tmp/ioncube/ioncube/ioncube_loader_lin_${ioncube_ver}${ts}.so" "$ext_dir/"; \
    printf 'zend_extension=ioncube_loader_lin_%s%s.so\n' "$ioncube_ver" "$ts" \
        > /usr/local/etc/php/conf.d/00-ioncube.ini; \
    rm -rf /tmp/ioncube /tmp/ioncube.tar.gz; \
    php -m | grep -i ioncube; \
    php -v | grep -i ioncube

# --- 5. Точка входу + генератор конфіга -------------------------------------
COPY entrypoint.sh    /usr/local/bin/entrypoint.sh
COPY make-config.sh   /usr/local/bin/make-config.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/make-config.sh

# --- 5b. Composer -----------------------------------------------------------
# Потрібен лише тестам (tests/composer.json → PHPUnit 9.6). У контейнері,
# а не на хості — щоб залежності ставилися тією ж версією PHP (7.3/7.4),
# що й прод. Тека tests/ на прод ніколи не потрапляє (deploy.sh).
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
