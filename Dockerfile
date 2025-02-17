FROM alpine:latest AS base

ARG NEOVIM_PREFIX=/opt/neovim
ENV NEOVIM_PREFIX=$NEOVIM_PREFIX

ENV PATH=${NEOVIM_PREFIX}/bin:$PATH

RUN apk add libgcc

FROM base AS neovim

RUN apk add \
    coreutils \
    curl \
    make \
    samurai gettext libtool autoconf automake cmake g++ pkgconf unzip \
    musl-libintl

ARG NEOVIM_VERSION=nightly
RUN set -ex \
 && echo "Fetch neovim ver.${NEOVIM_VERSION}" \
 && curl -SL https://github.com/neovim/neovim/archive/${NEOVIM_VERSION}.tar.gz | tar -xz \
 && cd $(find . -name 'neovim-*' -type d | head -1) \
 && make \
    CMAKE_BUILD_TYPE=RelWithDebInfo \
    CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_PREFIX}" \
 && make install

FROM base

RUN mkdir -p /etc/X11/fs/.local \
 && chmod o+rw /etc/X11/fs/.local

COPY --from=neovim $NEOVIM_PREFIX $NEOVIM_PREFIX

ENTRYPOINT "${NEOVIM_PREFIX}/bin/nvim"
CMD []

