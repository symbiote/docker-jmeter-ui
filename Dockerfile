# inspired by https://github.com/hauptmedia/docker-jmeter  and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile
# and 
# https://github.com/fgrehm/docker-netbeans/blob/master/Dockerfile

# Docker run with 
# 
# 
# docker run --rm -it  \
# 	--name jmeter \
# 	-e DISPLAY=$DISPLAY \
# 	-v /tmp/.X11-unix:/tmp/.X11-unix \
# 	-v /tmp:/tmp \
# 	-v $HOME/.Xauthority:/root/.Xauthority \
# 	-w /tmp \
# 	symbiote/jmeter:3.3
# 

FROM ubuntu:16.04

ARG JMETER_VERSION="3.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

ARG TZ="Australia/Melbourne"


RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev curl unzip && \
    apt-get clean && \
    mkdir -p /tmp/dependencies && \
    curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  && \ 
    mkdir -p /opt && \
    tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*


RUN curl https://jmeter-plugins.org/files/packages/jpgc-casutg-2.5.zip > /tmp/jpgc-casutg-2.5.zip && \
    unzip -oq /tmp/jpgc-casutg-2.5.zip -d $JMETER_HOME && \
    curl https://jmeter-plugins.org/files/packages/jpgc-graphs-basic-2.0.zip > /tmp/jpgc-graphs-basic-2.0.zip && \
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
    chown developer:developer -R /home/developer


WORKDIR	${JMETER_HOME}

USER developer
ENV HOME /home/developer

CMD ${JMETER_BIN}/jmeter

