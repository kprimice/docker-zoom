FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV UNAME=app

# RUN add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl iceweasel sudo desktop-file-utils lib32z1 \
    libx11-6 libegl1-mesa libxcb-shm0 \
    libglib2.0-0 libgl1-mesa-glx libxrender1 libxcomposite1 libxslt1.1 \
    libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 libxi6 libsm6 \
    libfontconfig1 libpulse0 libsqlite3-0 \
    libxcb-shape0 libxcb-xfixes0 libxcb-randr0 libxcb-image0 \
    libxcb-keysyms1 libxcb-xtest0 ibus ibus-gtk \
    libnss3 libxss1 xcompmgr \
    libxcb-xinerama0 libxkbcommon-x11-0 \
    pulseaudio-utils \
    --no-install-recommends && \
    apt-get clean && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://zoom.us/client/latest/zoom_amd64.deb > /tmp/zoom.deb
RUN dpkg -i /tmp/zoom.deb && rm /tmp/zoom.deb
RUN rm -rf /var/lib/apt/lists/*

RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:{UNAME},,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio

COPY scripts/ /var/cache/zoom/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

COPY zoomus.conf /home/${UNAME}/.config/zoomus.conf
COPY pulse-client.conf /etc/pulse/client.conf

ENV HOME /home/${UNAME}

ENTRYPOINT ["/sbin/entrypoint.sh"]
