FROM ubuntu:14.04

MAINTAINER ricardo@droboports.com

RUN apt-get update && \
    apt-get install software-properties-common && \
    add-apt-repository ppa:git-core/ppa && \
    apt-get update

RUN dpkg --set-selections < packages.txt

RUN groupadd -r drobo && useradd -r -g drobo drobo && \
    mkdir -p /home/drobo/build

RUN wget -O /tmp/arm7-tools.gz https://links.connecteddata.com/linkstorage/55b7918402c57c037bd2a85e/arm7_tools.gz/1438180629/cesZkWw%252FvX%252F3%252BbGNpVoQWTVIBrA%253D/arm7-tools.gz && \
    mkdir -p /home/drobo/xtools/toolchain/5n && \
    tar -zxf /tmp/arm7-tools.gz -C /home/drobo/xtools/toolchain/5n

RUN mkdir -p /mnt/DroboFS/Shares/DroboApps && \
    mkdir -p /mnt/DroboFS/System && \
    chmod a+rw /mnt/DroboFS/System /mnt/DroboFS/Shares/DroboApps

VOLUME ["/home/drobo/build", "/mnt/DroboFS/Shares/DroboApps"]

USER drobo

CMD ["/bin/bash"]
