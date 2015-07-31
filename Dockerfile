FROM ubuntu:14.04

MAINTAINER ricardo@droboports.com

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
    groupadd -r drobo && \
    useradd -r -g drobo -G sudo drobo && \
    echo drobo:drobo | chpasswd

RUN set -x; \
    wget -O /tmp/arm7-tools.html https://links.connecteddata.com/GpZRrby7WsaCAys/arm7-tools.gz/wui && \
    _url=$(cat /tmp/arm7-tools.html | grep "id=\"http_link_download_button\"" | sed -e "s/.*href=\"\(.*\)\" title.*/\1/g") && \
    wget -O /tmp/arm7-tools.gz https://links.connecteddata.com/${_url} && \
    mkdir -p /home/drobo/xtools/toolchain/5n && \
    tar -zxf /tmp/arm7-tools.gz -C /home/drobo/xtools/toolchain/5n && \
    rm -f /tmp/arm7-tools.html /tmp/arm7-tools.gz

RUN set -x; \
    mkdir -p /mnt/DroboFS/Shares/DroboApps && \
    mkdir -p /mnt/DroboFS/System && \
    chmod a+rw /mnt/DroboFS/System /mnt/DroboFS/Shares/DroboApps && \
    mkdir -p /home/drobo/build && \
    chown -R drobo:drobo /home/drobo

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x; \
    apt-get autoclean && \
    apt-get clean

VOLUME ["/home/drobo/build", "/mnt/DroboFS/Shares/DroboApps"]

USER drobo

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
