FROM debian:bullseye-slim AS base

ENV LC_ALL C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
ARG http_proxy=""
ARG https_proxy=""
ARG COMPOSER_SHA256="9a18e1a3aadbcb94c1bafd6c4a98ff931f4b43a456ef48575130466e19f05dd6"
ARG COMPOSER_VER="2.6.5"

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/force-unsafe-io && \
    apt-get -q update && \
    apt-get install -y eatmydata  && \
    eatmydata -- apt-get install -y apt-transport-https ca-certificates && \
    apt-get clean && rm -Rf /var/lib/apt/lists/*

COPY ./provisioning/sources.list /etc/apt/sources.list
COPY ./provisioning/debsury.gpg /etc/apt/trusted.gpg.d/debsury.gpg

RUN apt-get -qq update && \
    eatmydata -- apt-get -qy install \
        apache2 libapache2-mod-php8.1 \
        curl \
        git-core \
        netcat \
        jq \
        php8.1 php8.1-cli php8.1-curl php8.1-xml php8.1-mysql php8.1-mbstring php8.1-bcmath php8.1-zip php8.1-mysql php8.1-sqlite3 php8.1-opcache php8.1-xml php8.1-xsl php8.1-intl php8.1-xdebug php8.1-apcu  php8.1-grpc php8.1-protobuf \
        zip unzip && \
    rm -Rf /var/lib/apt/lists/* && \
    a2enmod headers rewrite deflate php8.1 && a2enconf security && \
    rm /etc/apache2/conf-enabled/other-vhosts-access-log.conf /etc/apache2/conf-enabled/serve-cgi-bin.conf && \
    update-alternatives --set php /usr/bin/php8.1 || true

COPY ./provisioning/php.ini /etc/php/8.1/apache2/conf.d/local.ini
COPY ./provisioning/php.ini /etc/php/8.1/cli/conf.d/local.ini
COPY ./provisioning/apache-security.conf /etc/apache2/conf-available/security.conf

RUN curl -so /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VER}/composer.phar && chmod 755 /usr/local/bin/composer

# 0844c3dd85bbfa039d33fbda58ae65a38a9f615fcba76948aed75bf94d7606ca  /usr/local/bin/composer
RUN echo "${COMPOSER_SHA256}  /usr/local/bin/composer" | sha256sum --check

RUN echo GMT > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata \
    && mkdir -p "/var/log/apache2" \
    && ln -sfT /dev/stderr "/var/log/apache2/error.log" \
    && ln -sfT /dev/stdout "/var/log/apache2/access.log" 

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
