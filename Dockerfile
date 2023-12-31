# Dockerfile - Debian 11 Bullseye Fat - DEB version
# https://github.com/openresty/docker-openresty
#
# This builds upon the base OpenResty Bullseye image,
# adding useful packages and utilities.
#
# Currently it just adds the openresty-opm package.
#

ARG RESTY_FAT_IMAGE_BASE="openresty/openresty"
ARG RESTY_FAT_IMAGE_TAG="bullseye"

FROM ${RESTY_FAT_IMAGE_BASE}:${RESTY_FAT_IMAGE_TAG}

ARG RESTY_FAT_IMAGE_BASE="openresty/openresty"
ARG RESTY_FAT_IMAGE_TAG="bullseye"

# RESTY_FAT_DEB_FLAVOR build argument is used to select other
# OpenResty Debian package variants.
# For example: "-debug" or "-valgrind"
ARG RESTY_FAT_DEB_FLAVOR=""
ARG RESTY_FAT_DEB_VERSION="=1.21.4.2-1~bullseye1"

LABEL maintainer="Evan Wies <evan@neomantra.net>"
LABEL resty_fat_deb_flavor="${RESTY_FAT_DEB_FLAVOR}"
LABEL resty_fat_deb_version="${RESTY_FAT_DEB_VERSION}"
LABEL resty_fat_image_base="${RESTY_FAT_IMAGE_BASE}"
LABEL resty_fat_image_tag="${RESTY_FAT_IMAGE_TAG}"

# install ps
RUN apt-get update && apt-get install -y procps && rm -rf /var/lib/apt/lists/*

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openresty-opm \
    && opm get jkeys089/lua-resty-hmac \
    && opm get fffonion/lua-resty-openssl \
    && opm get ledgetech/lua-resty-http \
    && opm get bungle/lua-resty-session \
    && opm get cdbattags/lua-resty-jwt \
    && opm get zmartzone/lua-resty-openidc

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openresty-resty${RESTY_FAT_DEB_FLAVOR}${RESTY_FAT_DEB_VERSION} \
        openresty-opm${RESTY_FAT_DEB_FLAVOR}${RESTY_FAT_DEB_VERSION} \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/openresty/nginx/html/lua

ADD ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD ./lua_test.conf /usr/local/openresty/nginx/conf/lua_test.conf
ADD ./app.conf /etc/nginx/conf.d/app.conf

EXPOSE 80 8080 5999