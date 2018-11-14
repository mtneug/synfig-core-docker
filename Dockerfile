FROM alpine:edge

ENV SYNFIG_VERSION=v1.2.1

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --virtual .run-deps \
      boost boost-program_options boost-system boost-filesystem zlib libsigc++ glibmm cairo fftw pango gettext \
      imagemagick6 imagemagick6-dev libjpeg-turbo libtool ffmpeg libdv-tools \
      ttf-dejavu ttf-freefont ttf-liberation ttf-linux-libertine libxml++-2.6 mlt \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --virtual .build-deps \
      binutils-gold git autoconf automake make gcc g++ boost-dev zlib-dev libsigc++-dev glibmm-dev cairo-dev fftw-dev \
      pango-dev gettext-dev libjpeg-turbo-dev ffmpeg-dev libxml++-2.6-dev mlt-dev \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.7/main --virtual .run-deps-old \
      swfdec \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.7/main --virtual .build-deps-old \
      swfdec-dev \
  \
 && ln -s /usr/bin/convert-6 /usr/local/bin/convert \
  \
 && git clone --recursive https://github.com/synfig/synfig.git /usr/local/src/synfig \
 && cd /usr/local/src/synfig \
 && git checkout "$SYNFIG_VERSION" \
  \
 && cd ETL \
 && autoreconf --install --force \
 && ./configure --disable-debug --disable-dependency-tracking \
 && make install \
 && cd .. \
  \
 && cd synfig-core \
 && ./bootstrap.sh \
 && ./configure --disable-debug --disable-dependency-tracking \
      --with-freetype \
      --with-libswscale \
      --without-opencl \
 && make -j$(nproc) \
 && make install \
 && cd / \
  \
 && apk del --no-cache .build-deps \
 && apk del --no-cache .build-deps-old \
 && rm -rf \
      /usr/local/src/synfig \
      /usr/local/include \
      /usr/local/lib/pkgconfig

COPY synfig_modules.cfg /usr/local/etc/synfig_modules.cfg
