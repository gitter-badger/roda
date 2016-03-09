##########################################
# Dockerfile for udata build environment
# Based on Debian
##########################################

FROM udata/base

# File Author / Maintainer
MAINTAINER Axel Haustant

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends rlwrap netcat \
    && rm -rf /var/lib/apt/lists/*;

# Install and activate nvm
ENV NVM_VERSION v0.30.2
ENV NVM_DIR /usr/local/nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | bash
RUN . $NVM_DIR/nvm.sh
ENV NVM_NODEJS_ORG_MIRROR http://nodejs.org/dist
RUN udata $NVM_DIR/nvm.sh install node
