FROM alpine:3.11

ENV CUCKOO_CWD /cuckoo
 
# Install persistent packages
RUN apk update && apk add --no-cache  \
  python2-dev \
  py2-pip \
  su-exec \
  tini \
  openssl \
  libjpeg \
  libmagic \
  libpq \
  && pip install --upgrade pip wheel setuptools


# Install Build deps
RUN apk add --no-cache -t .build-deps \
  gcc \
  g++ \
  make \
  linux-headers \
  openssl-dev \
  libxslt-dev \
  libxml2-dev \
  build-base \
  libstdc++ \
  zlib-dev \
  libc-dev \
  jpeg-dev \
  file-dev \
  automake \
  autoconf \
  libressl-dev \
  musl-dev \
  libffi-dev \
  libtool \
  libpq \
  postgresql-dev \
  && pip install psycopg2
  

# Install Cuckoo Sandbox Required Dependencies
ENV LIBRARY_PATH=/lib:/usr/lib
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Install local build of Cuckoo
RUN mkdir /cuckoo && mkdir /cuckoo_build \
  && adduser -D -h /cuckoo cuckoo \
  && export PIP_NO_CACHE_DIR=off \
  && export PIP_DISABLE_PIP_VERSION_CHECK=on \
  && export CUCKOO_CWD=/cuckoo \
  && export CUCKOO1=/cuckoo

ADD sandbox /cuckoo_build
#RUN pip install -e cuckoo_build1
RUN pip install cuckoo

RUN cuckoo --cwd /cuckoo
WORKDIR /cuckoo

# Cleanup
RUN rm -rf /tmp/* \
  && apk del --purge .build-deps

COPY conf /cuckoo/conf
COPY update_conf.py /update_conf.py
COPY docker-entrypoint.sh /entrypoint.sh

# RUN chown -R cuckoo /cuckoo \
#  && chmod +x /entrypoint.sh

RUN apk add bash

VOLUME ["/cuckoo/conf"]

EXPOSE 1337 31337

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["cuckoo"]

# docker run --env-file ./config-file.env -it amf-cuckoo web