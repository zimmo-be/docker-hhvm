FROM ubuntu:14.04

RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 \
    && apt-get update -y && apt-get install -y curl software-properties-common \
    && add-apt-repository "deb http://dl.hhvm.com/ubuntu trusty-lts-3.12 main" \
    && apt-get update -y \
    && apt-get install -y hhvm=3.12.1~trusty \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN buildDeps="hhvm-dev libtool" \
    && apt-get update -y && apt-get install -y $buildDeps --no-install-recommends \
    && curl -OL https://github.com/mongodb/mongo-hhvm-driver/releases/download/1.1.2/hhvm-mongodb-1.1.2.tgz \
    && tar -xvzf hhvm-mongodb-1.1.2.tgz \
    && cd hhvm-mongodb-1.1.2 \
    && hphpize \
    && cmake . \
    && make configlib \
    && make -j 1 \
    && make install \
    && mkdir -p /etc/hhvm/ext \
    && mv mongodb.so /etc/hhvm/ext \
    && cd .. \
    && rm -rf hhvm-mongodb-1.1.2* \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
        -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir /opt/composer \
    && curl -sS https://getcomposer.org/installer | hhvm --php -- --install-dir=/opt/composer

ADD server.ini /etc/hhvm/server.ini

EXPOSE 9000

COPY hhvm-foreground /usr/local/bin/

CMD ["hhvm-foreground"]