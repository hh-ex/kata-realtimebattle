FROM ubuntu:14.04

# Install realtimebattle and needed wget
RUN apt-get update && apt-get install -y realtimebattle wget python vnc4server expect twm

# Install erlang/elixir with Fix for language error
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends locales esl-erlang elixir \
    && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Prepare running GTK stuff
# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer && \
    mkdir /home/developer/bot
USER developer
ENV HOME /home/developer
WORKDIR /home/developer/bot

# Configure realtimebattle to use correct folders.
RUN echo "Robot search path: /home/developer/bot" >> /home/developer/.rtbrc
#RUN echo "Cookie frequency [cookies per second]: 0.3" >> /home/developer/.rtbrc

# Start rtp in debug mode
# CMD /usr/games/realtimebattle -d -D 5 -t tournament.rtb
ENV DISPLAY :0
CMD Xvnc ${DISPLAY} -rfbauth .passwd & \
    sleep 2 && \
    twm & \
    ./setup_passwd.sh && \
    /usr/games/realtimebattle -d -D 5 -t tournament.rtb

# CMD bash