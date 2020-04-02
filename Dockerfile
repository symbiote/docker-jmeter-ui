# inspired by https://github.com/hauptmedia/docker-jmeter  and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile
# and
# https://github.com/fgrehm/docker-netbeans/blob/master/Dockerfile
# and
# https://github.com/justb4/docker-jmeter
#
# Docker run with (follow steps from README.md on mac first
#
# docker run --rm -it  \
#   --name jmeter \
#   -e DISPLAY=$DISPLAY \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -v /tmp:/tmp \
#   -v $HOME/.Xauthority:/root/.Xauthority \
#   -w /tmp \
#   symbiote/jmeter:5.1
#
FROM alpine:3.11

ARG JMETER_VERSION="5.1.1"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN ${JMETER_HOME}/bin
ENV JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# See https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-272703023
# Change TimeZone TODO: TZ still is not set!
ARG TZ="Australia/Melbourne"

RUN apk update && \
    apk upgrade && \
    apk add ca-certificates && \
    update-ca-certificates && \
    apk add --update \
        bash \
        curl \
        openjdk8-jre \
        # `ttf-dejavu` is required on macOS:
        # https://github.com/docker-library/openjdk/issues/73
        ttf-dejavu \
        tzdata \
        unzip \
        && \
    apk add --no-cache nss && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /tmp/dependencies && \
    #
    # Install jmeter
    echo "Downloading jmeter ${JMETER_VERSION}, this might take a while ..." && \
    curl -L --silent ${JMETER_DOWNLOAD_URL} > /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz && \
    mkdir -p /opt && \
    tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
    rm -rf /tmp/dependencies && \
    #
    # Install jmeter plugins
    curl --silent https://jmeter-plugins.org/files/packages/jpgc-casutg-2.9.zip > /tmp/jpgc-casutg-2.9.zip && \
    unzip -oq /tmp/jpgc-casutg-2.9.zip -d $JMETER_HOME && \
    curl --silent https://jmeter-plugins.org/files/packages/jpgc-graphs-basic-2.0.zip > /tmp/jpgc-graphs-basic-2.0.zip && \
    unzip -oq /tmp/jpgc-graphs-basic-2.0.zip -d $JMETER_HOME && \
    rm -rf /tmp/*

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# The magic bit that makes the .x11 mapping work out
RUN mkdir -p /home/developer && mkdir -p /etc/sudoers.d && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    echo "proxy.cert.directory=/tmp" >> ${JMETER_HOME}/bin/user.properties && \
    chown developer:developer -R /home/developer $JMETER_HOME

WORKDIR ${JMETER_HOME}

USER developer
ENV HOME /home/developer

CMD ${JMETER_BIN}/jmeter
