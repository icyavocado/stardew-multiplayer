FROM debian:bookworm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y supervisor \
  sudo \
  openbox \
  xterm \
  novnc \
  x11vnc xvfb \
  curl \
  && apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m app && \
echo 'app ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

USER app

RUN mkdir -p /home/app/logs
RUN mkdir -p /home/app/.config/StardewValley

ADD startup.sh /home/app/startup.sh
ADD check_and_run /home/app/check_and_run
ADD supervisord.conf /home/app/supervisord.conf

WORKDIR /home/app
