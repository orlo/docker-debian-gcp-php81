FROM debian:bullseye-slim AS base

ENV LC_ALL C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
ARG http_proxy=""
ARG https_proxy=""


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
        php8.1 php8.1-cli php8.1-curl php8.1-xml php8.1-mysql php8.1-mbstring php8.1-bcmath php8.1-zip php8.1-mysql php8.1-sqlite3 php8.1-opcache php8.1-xml php8.1-xsl php8.1-intl php8.1-xdebug php8.1-apcu php8.1-grpc php8.1-protobuf \
        zip unzip && \
    rm -Rf /var/lib/apt/lists/* && \
    a2enmod headers rewrite deflate php8.1 && \
    update-alternatives --set php /usr/bin/php8.1

COPY ./provisioning/php.ini /etc/php/8.1/apache2/conf.d/local.ini
COPY ./provisioning/php.ini /etc/php/8.1/cli/conf.d/local.ini

RUN echo GMT > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata \
    && mkdir -p "/var/log/apache2" \
    && ln -sfT /dev/stderr "/var/log/apache2/error.log" \
    && ln -sfT /dev/stdout "/var/log/apache2/access.log" \
    && ln -sfT /dev/stdout "/var/log/apache2/other_vhosts_access.log"

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
