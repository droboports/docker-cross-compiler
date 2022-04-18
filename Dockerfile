FROM ubuntu:20.04

ENV USER_ID 1000
ENV GROUP_ID 1000
ENV PYTHON_VERSION 2.7.10
ENV GOARCH arm
ENV GOARM 7

RUN set -x; \
    apt-get -y update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get -y update && \
    apt-get clean && \
    apt-get autoclean

COPY packages.txt /packages.txt

RUN set -x; \
    apt-get -y install $(cat /packages.txt) && \
    apt-get clean && \
    apt-get autoclean

# NodeJS and npm
RUN set -x; \
    curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash - && \
    apt-get install -y nodejs \
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

# The soft-float toolchain
RUN set -x; \
    wget -O /tmp/arm-drobo_x86_64-linux-gnueabi.tar.xz https://github.com/drobo/cross-compiler/releases/download/v6.4.0.1/arm-drobo_x86_64-linux-gnueabi.tar.xz && \
    mkdir -p /home/drobo/xtools/toolchain/arm-drobo_x86_64-linux-gnueabi && \
    tar -axf /tmp/arm-drobo_x86_64-linux-gnueabi.tar.xz -C /home/drobo/xtools/toolchain/arm-drobo_x86_64-linux-gnueabi && \
    rm -fr /tmp/arm-drobo_x86_64-linux-gnueabi.tar.xz

# The hard-float toolchain
RUN set -x; \
    wget -O /tmp/arm-drobo_x86_64-linux-gnueabihf.tar.xz https://github.com/drobo/cross-compiler/releases/download/v10.2.0/arm-drobo_x86_64-linux-gnueabihf.tar.xz && \
    mkdir -p /home/drobo/xtools/toolchain/arm-drobo_x86_64-linux-gnueabihf && \
    tar -axf /tmp/arm-drobo_x86_64-linux-gnueabihf.tar.xz -C /home/drobo/xtools/toolchain/arm-drobo_x86_64-linux-gnueabihf && \
    rm -fr /tmp/arm-drobo_x86_64-linux-gnueabihf.tar.xz

# Python cross-compiler
RUN set -x; \
    wget -O /tmp/xpython2.tgz https://github.com/droboports/python2/releases/download/v${PYTHON_VERSION}/xpython2.tgz && \
    mkdir -p /home/drobo/xtools/python2/5n && \
    tar -zxf /tmp/xpython2.tgz -C /home/drobo/xtools/python2/5n && \
    rm -f /tmp/xpython2.tgz

# Golang cross-compiler
RUN set -x; \
    wget -O /tmp/xgolang.tgz https://github.com/droboports/golang/releases/download/v1.7.4/xgolang.tgz && \
    mkdir -p /home/drobo/xtools/golang/5n && \
    tar -zxf /tmp/xgolang.tgz -C /home/drobo/xtools/golang/5n && \
    rm -f /tmp/xgolang.tgz

# Official Golang 1.10
RUN set -x; \
    wget -O /tmp/go-1.10.tgz https://golang.org/dl/go1.10.8.linux-amd64.tar.gz && \
    mkdir -p /usr/lib/go-1.10 && \
    tar -zxf /tmp/go-1.10.tgz -C /usr/lib/go-1.10 && \
    mv /usr/lib/go-1.10/go/* /usr/lib/go-1.10/ && \
    rmdir /usr/lib/go-1.10/go && \
    rm -f /tmp/go-1.10.tgz

# Official Golang
RUN set -x; \
    wget -O /tmp/go-1.16.tgz https://golang.org/dl/go1.16.15.linux-amd64.tar.gz && \
    mkdir -p /usr/lib/go-1.16 && \
    tar -zxf /tmp/go-1.16.tgz -C /usr/lib/go-1.16 && \
    mv /usr/lib/go-1.16/go/* /usr/lib/go-1.16/ && \
    rmdir /usr/lib/go-1.16/go && \
    rm -f /tmp/go-1.16.tgz && \
    ln -fs go-1.16 /usr/lib/go

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
