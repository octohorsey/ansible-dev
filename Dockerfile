FROM centos:7

USER 0

ARG EPEL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
ARG OC_DIR=openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit
ARG OC_TAR=openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
ARG OC_URL=https://github.com/openshift/origin/releases/download/v3.11.0/$OC_TAR

ENV S2I_PATH=/usr/libexec/s2i
ENV S2I_BIN_PATH=$S2I_PATH/bin
ENV S2I_SRC_PATH=$S2I_PATH/src

RUN mkdir -p $S2I_BIN_PATH $S2I_SRC_PATH

# Copying repo s2i scripts to container-- will serve as defaults (can be over-rode)
COPY .s2i/bin/ $S2I_BIN_PATH

LABEL io.openshift.s2i.scripts-url="image://${S2I_BIN_PATH}" \
      io.openshift.s2i.destination=$S2I_PATH

RUN yum -y install $EPEL && \
    yum -y install ansible \
                   git \
                   vim \
                   wget \
                   unzip && \
    wget $OC_URL && \
    tar -zvxf $OC_TAR && \
    mv $OC_DIR/oc /usr/bin/oc && \
    mv $OC_DIR/kubectl /usr/bin/kubectl && \
    rm -rf $OC_TAR && \
    yum clean all && \
    rm -rf /var/cache/yum

ARG HOME=/home/jenkins
RUN useradd -u 1001 -r -g 0 -d ${HOME} -c "Default Application User" default && \
    mkdir -p ${HOME} && \
    chown -R 1001:0 ${HOME} && chmod -R g+rwX ${HOME}

RUN mkdir -p $HOME/.ssh
RUN chown 1001:0 $HOME/.ssh

USER default

CMD ["sleep infinity"]
