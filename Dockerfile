FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV APP_USER=app

# RUN add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
RUN apt-get update && apt-get install -y \
    ca-certificates \
    fontconfig-config fonts-dejavu-core libasyncns0 libdrm-intel1 \
    libdrm-nouveau2 libdrm-radeon1 libelf1 libflac8 libfontconfig1 libfreetype6 \
    libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa \
    libice6 \
    libogg0 liborc-0.4-0 libpciaccess0 libpulse0 libsm6 libsndfile1 \
    libvorbis0a libvorbisenc2 libx11-6 libx11-data libx11-xcb1 \
    libxau6 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-image0 \
    libxcb-present0 libxcb-randr0 libxcb-shape0 libxcb-shm0 libxcb-sync1 \
    libxcb-xfixes0 libxcb1 libxcomposite1 libxdamage1 libxdmcp6 \
    libxext6 libxfixes3 libxi6 libxml2 libxrender1 libxshmfence1 libxslt1.1 \
    libxxf86vm1 sgml-base x11-common xml-core curl desktop-file-utils \
    libegl1-mesa libxcb-keysyms1 libxcb-xtest0 libnss3 libxcursor1 libasound2 \
    libxtst6 \
    ibus libxcb-xinerama0 libxkbcommon-x11-0 \
    ffmpeg \
    --no-install-recommends && \
    apt-get clean && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://zoom.us/client/latest/zoom_amd64.deb > /tmp/zoom.deb
RUN dpkg -i /tmp/zoom.deb && rm /tmp/zoom.deb
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /home/app

COPY scripts/ /var/cache/zoom/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

COPY zoomus.conf /home/app/.config/zoomus.conf

ENV HOME /home/app

ENTRYPOINT ["/sbin/entrypoint.sh"]
