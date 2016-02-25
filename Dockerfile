FROM ubuntu:14.04

MAINTAINER ricardo@droboports.com

ENV USER_ID 1000
ENV GROUP_ID 1000

RUN set -x; \
    apt-get -y update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get -y update

COPY packages.txt /packages.txt

RUN set -x; \
    apt-get -y install $(cat /packages.txt)

# The official toolchain is 32-bit
RUN set -x; \
    dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y install libc6:i386 libncurses5:i386 libstdc++6:i386

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

RUN set -x; \
    mkdir -p   /mnt/DroboFS/Shares/DroboApps /mnt/DroboFS/System /dist && \
    chmod a+rw /mnt/DroboFS/Shares/DroboApps /mnt/DroboFS/System /dist && \
    mkdir -p /home/drobo/build && \
    chown -R drobo:drobo /home/drobo

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x; \
    apt-get autoclean && \
    apt-get clean

VOLUME ["/home/drobo/build", "/mnt/DroboFS/Shares/DroboApps", "/dist"]

USER drobo

ENTRYPOINT ["/docker-entrypoint.sh"]
