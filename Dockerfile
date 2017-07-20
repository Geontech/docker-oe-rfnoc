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
ENV BAKEDIR /opt/oe-project
ENV OECORE ${BAKEDIR}/oe-core
ENV OECORE_ENV ${OECORE}/oe-init-build-env
ENV MACHINE=ettus-e3xx-sg1
ENV BUILD_IMAGE=redhawk-usrp-uhd-image

# Create user for actual build
RUN id ${USERNAME} 2>/dev/null || useradd --uid 30000 --create-home ${USERNAME}
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Swap dash for bash so you don't Hulk Smash in a moment...
RUN ln -sf /bin/bash /bin/sh

RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Set permissions, Switch to the user
RUN mkdir -p ${BAKEDIR}
RUN chown -R ${USERNAME}. ${BAKEDIR}
USER ${USERNAME}
WORKDIR ${BAKEDIR}

# Configure git
RUN git config --global user.name "oe-base" && \
    git config --global user.email "oe-base@gmail.com" && \
    git config --global color.ui false

RUN echo "FORCE"

RUN repo init -u http://curiosity/openembedded/e300-manifest.git -b rfnoc-redhawk && \
    repo sync

# Copy in files
COPY files/uhd_git.bb ${BAKEDIR}/meta-sdr/recipes-support/uhd/
COPY files/fix_block_id.patch ${BAKEDIR}/meta-sdr/recipes-support/uhd/uhd/
COPY files/fix_log.patch ${BAKEDIR}/meta-sdr/recipes-support/uhd/uhd/
COPY files/entry-point.sh ${BAKEDIR}/

# Expose the environment variables to following images
ONBUILD ENV USERNAME build
ONBUILD ENV HOMEDIR /home/${USERNAME}
ONBUILD ENV BAKEDIR /opt/oe-project
ONBUILD ENV OECORE ${BAKEDIR}/oe-core
ONBUILD ENV OECORE_ENV ${OECORE}/oe-init-build-env

# Expose the build directory
VOLUME ${BAKEDIR}/build

# Default startup is a do-nothing since /etc/profile will ensure we're in the build environment.
CMD ["/bin/bash", "-l", "./entry-point.sh"]

