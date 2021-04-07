FROM alpine:latest AS base

ARG NEOVIM_PREFIX=/opt/neovim
ENV NEOVIM_PREFIX=$NEOVIM_PREFIX

ENV PATH=${NEOVIM_PREFIX}/bin:$PATH

RUN apk add \
    libgcc \
    git

FROM base AS neovim

RUN apk add \
    coreutils \
    curl \
    make \
    samurai gettext libtool autoconf automake cmake g++ pkgconf unzip \
    musl-libintl

ARG NEOVIM_VERSION=nightly
RUN echo "${NEOVIM_VERSION}" \
 && curl -SL https://github.com/neovim/neovim/archive/${NEOVIM_VERSION}.tar.gz | tar -xz

RUN cd $(find . -name 'neovim-*' -type d | head -1) \
 && make \
    CMAKE_BUILD_TYPE=RelWithDebInfo \
    CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_PREFIX}" \
 && make install

RUN curl -fLo ${NEOVIM_PREFIX}-base-config/init.vim --create-dirs \
      https://raw.githubusercontent.com/yash268925/neovim-init/main/init.vim \
 && curl -fLo ${NEOVIM_PREFIX}-base-config/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

FROM base

RUN mkdir -p /etc/X11/fs/.local \
 && chmod o+rw /etc/X11/fs/.local \
 && mkdir -p /root/.config/nvim

COPY --from=neovim $NEOVIM_PREFIX $NEOVIM_PREFIX
COPY --from=neovim ${NEOVIM_PREFIX}-base-config /root/.config/nvim/

RUN ${NEOVIM_PREFIX}/bin/nvim +PlugInstall +q +q

ENTRYPOINT "${NEOVIM_PREFIX}/bin/nvim"
CMD []
