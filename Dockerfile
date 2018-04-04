FROM ubuntu:14.04

MAINTAINER ricardo@droboports.com

ENV USER_ID 1000
ENV GROUP_ID 1000
ENV XTOOL_VERSION 6.4.0.1
ENV PYTHON_VERSION 2.7.10
ENV GOLANG_VERSION 1.7.4
ENV GOARCH arm
ENV GOARM 7

RUN set -x; \
    apt-get -y update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    add-apt-repository -y ppa:gophers/archive && \
    apt-get -y update && \
    apt-get clean && \
    apt-get autoclean

COPY packages.txt /packages.txt

RUN set -x; \
    apt-get -y install $(cat /packages.txt) && \
    apt-get clean && \
    apt-get autoclean

# The official toolchain is 32-bit
RUN set -x; \
    dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y install libc6:i386 libncurses5:i386 libstdc++6:i386 && \
    apt-get clean && \
    apt-get autoclean

RUN set -x; \
    groupadd -r -g $GROUP_ID drobo && \
    useradd -r -u $USER_ID -g drobo -G sudo drobo && \
    echo drobo:drobo | chpasswd

RUN set -x; \
    wget -O /tmp/SDK-2.1.zip ftp://updates.drobo.com/droboapps/development/SDK-2.1.zip && \
    unzip -d /tmp/ /tmp/SDK-2.1.zip && \
    mkdir -p /home/drobo/xtools/toolchain/5n && \
    tar -zxf "/tmp/DroboApps SDK 2.1/arm7-tools.gz" -C /home/drobo/xtools/toolchain/5n && \
    rm -fr /tmp/SDK-2.1.zip "/tmp/DroboApps SDK 2.1"

# The new toolchain is 64-bit
RUN set -x; \
    wget -O /tmp/arm-drobo_x86_64-linux-gnueabi.tar.xz https://github.com/drobo/cross-compiler/releases/download/v${XTOOL_VERSION}/arm-drobo_x86_64-linux-gnueabi.tar.xz && \
    mkdir -p /home/drobo/xtools/toolchain/arm-drobo_x86_64-linux-gnueabi && \
    tar -axf /tmp/arm-drobo_x86_64-linux-gnueabi.tar.xz -C /home/drobo/xtools/toolchain/arm-drobo_x86_64-linux-gnueabi && \
    rm -fr /tmp/arm-drobo_x86_64-linux-gnueabi.tar.xz

# Python cross-compiler
RUN set -x; \
    wget -O /tmp/xpython2.tgz https://github.com/droboports/python2/releases/download/v${PYTHON_VERSION}/xpython2.tgz && \
    mkdir -p /home/drobo/xtools/python2/5n && \
    tar -zxf /tmp/xpython2.tgz -C /home/drobo/xtools/python2/5n && \
    rm -f /tmp/xpython2.tgz && \
    chown -R drobo:drobo /home/drobo

# Golang cross-compiler
RUN set -x; \
    wget -O /tmp/xgolang.tgz https://github.com/droboports/golang/releases/download/v${GOLANG_VERSION}/xgolang.tgz && \
    mkdir -p /home/drobo/xtools/golang/5n && \
    tar -zxf /tmp/xgolang.tgz -C /home/drobo/xtools/golang/5n && \
    rm -f /tmp/xgolang.tgz && \
    chown -R drobo:drobo /home/drobo

RUN set -x; \
    mkdir -p   /mnt/DroboFS/Shares/DroboApps /mnt/DroboFS/System /dist && \
    chmod a+rw /mnt/DroboFS/Shares/DroboApps /mnt/DroboFS/System /dist && \
    mkdir -p /home/drobo/build && \
    chown -R drobo:drobo /home/drobo

COPY sudoers /etc/sudoers.d/drobo
COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/home/drobo/build", "/mnt/DroboFS/Shares/DroboApps", "/dist"]

ENV PATH /home/drobo/xtools/golang/5n/bin:${PATH}

USER drobo

ENTRYPOINT ["/docker-entrypoint.sh"]
