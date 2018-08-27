FROM ubuntu:14.04
MAINTAINER Patrick Wolfram <pwolfram@geontech.com>
# Heavily based on Thomas' work

# Update the repositories
RUN apt-get update 

# Install the following utilities (for poky)
RUN apt-get install -y \
    build-essential \
    chrpath \
    curl \
    diffstat \
    gcc-multilib \
    gawk \
    git-core \ 
    libsdl1.2-dev \
    texinfo \
    unzip \
    wget \
    xterm

# Additional host packages required by poky/scripts/wic
RUN apt-get install -y \
    bzip2 \
    dosfstools \
    mtools \
    parted \ 
    syslinux \
    tree

# Username, user directory, baking area
ENV USERNAME build
ENV HOMEDIR /home/${USERNAME}
ENV BAKEDIR /opt/oe-project/redhawk-rfnoc-build
ENV OECORE ${BAKEDIR}/openembedded-core
ENV OECORE_ENV ${OECORE}/oe-init-build-env
ENV MACHINE=ettus-e3xx-sg1
ENV BUILD_IMAGE=redhawk-usrp-uhd-rfnoc-image
ENV CONTAINER_LOCALE=en_US.UTF-8
ENV LANG=${CONTAINER_LOCALE}
ENV LC_ALL=${CONTAINER_LOCALE}

# Prepare the locale
RUN locale-gen ${CONTAINER_LOCALE} && \
    update-locale LC_ALL=${LC_ALL} LANG=${LANG}

# Create user for actual build
RUN id ${USERNAME} 2>/dev/null || useradd --uid 30000 --create-home ${USERNAME}
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Swap dash for bash so you don't Hulk Smash in a moment...
RUN ln -sf /bin/bash /bin/sh

# Set permissions, Switch to the user
RUN mkdir -p ${BAKEDIR}
RUN chown -R ${USERNAME}. ${BAKEDIR}
USER ${USERNAME}
WORKDIR /opt/oe-project

# Configure git
RUN git config --global user.name "oe-base" && \
    git config --global user.email "oe-base@gmail.com" && \
    git config --global color.ui false

RUN git clone https://github.com/geontech/redhawk-rfnoc-build.git && \
    cd redhawk-rfnoc-build && \
    git checkout rocko && \
    git submodule update --init

WORKDIR ${BAKEDIR}

# Copy in files
COPY files/entry-point.sh ${BAKEDIR}/

# Expose the environment variables to following images
ONBUILD ENV USERNAME build
ONBUILD ENV HOMEDIR /home/${USERNAME}
ONBUILD ENV BAKEDIR /opt/oe-project/redhawk-rfnoc-build
ONBUILD ENV OECORE ${BAKEDIR}/openembedded-core
ONBUILD ENV OECORE_ENV ${OECORE}/oe-init-build-env

# Expose the build directory
VOLUME ${BAKEDIR}/build-pi

# Default startup is a do-nothing since /etc/profile will ensure we're in the build environment.
CMD ["/bin/bash", "-l", "./entry-point.sh"]

