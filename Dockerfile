FROM ubuntu:14.04

MAINTAINER ricardo@droboports.com

RUN apt-get -y update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get -y update

COPY packages.txt /packages.txt

RUN apt-get -y install $(cat /packages.txt)

# The official toolchain is 32-bit
RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y install libc6:i386 libncurses5:i386 libstdc++6:i386

RUN groupadd -r drobo && useradd -r -g drobo -G sudo drobo

RUN wget -O /tmp/arm7-tools.gz https://links.connecteddata.com/linkstorage/55b7918402c57c037bd2a85e/arm7_tools.gz/1438180629/cesZkWw%252FvX%252F3%252BbGNpVoQWTVIBrA%253D/arm7-tools.gz && \
    mkdir -p /home/drobo/xtools/toolchain/5n && \
    tar -zxf /tmp/arm7-tools.gz -C /home/drobo/xtools/toolchain/5n

RUN mkdir -p /mnt/DroboFS/Shares/DroboApps && \
    mkdir -p /mnt/DroboFS/System && \
    chmod a+rw /mnt/DroboFS/System /mnt/DroboFS/Shares/DroboApps && \
    mkdir -p /home/drobo/build && \
    chown -R drobo:drobo /home/drobo

VOLUME ["/home/drobo/build", "/mnt/DroboFS/Shares/DroboApps"]

USER drobo

CMD ["/bin/bash"]
