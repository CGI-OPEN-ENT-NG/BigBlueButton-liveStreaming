ARG FFMPEG_VERSION=4.2.2

FROM ubuntu:bionic
ARG FFMPEG_VERSION

WORKDIR /usr/src/app

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get update
RUN add-apt-repository ppa:jonathonf/ffmpeg-4

RUN ln -s -f /bin/true /usr/bin/chfn
RUN apt-get update
RUN apt-get install -y python3-pip
RUN apt-get install -y       python3-dev
RUN apt-get install -y       xvfb
RUN apt-get install -y       fluxbox
RUN apt-get install -y       ffmpeg
RUN apt-get install -y       dbus-x11
RUN apt-get install -y       libasound2
RUN apt-get install -y       libasound2-plugins
RUN apt-get install -y       libnss-wrapper
RUN apt-get install -y       alsa-utils
RUN apt-get install -y       alsa-oss
RUN apt-get install -y       pulseaudio
RUN apt-get install -y       pulseaudio-utils
RUN mkdir /home/lithium /var/run/pulse /run/user/lithium
RUN chown -R 1001:0 /home/lithium /run/user/lithium /var/run/pulse
RUN chmod -R g=u /home/lithium /run/user/lithium /var/run/pulse

RUN ln -s /usr/bin/python3 /usr/local/bin/python \
    && pip3 install --upgrade pip

COPY py_requirements.txt ./

RUN pip install --no-cache-dir -r py_requirements.txt



RUN apt-get update
RUN apt-get install -y gnupg wget curl unzip --no-install-recommends
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update -y
RUN apt-get install -y google-chrome-stable

# Téléchargez la version de chromedriver compatible avec Chrome 119
RUN wget -q --continue "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/119.0.6045.105/linux64/chromedriver-linux64.zip"
RUN unzip chromedriver-linux64.zip
RUN mv chromedriver-linux64/chromedriver /usr/local/bin
RUN chmod +x /usr/local/bin/chromedriver


ENV BBB_RESOLUTION 1920x1080
ENV BBB_AS_MODERATOR false
ENV BBB_USER_NAME Live
ENV BBB_CHAT_NAME Chat
ENV BBB_SHOW_CHAT false
ENV BBB_ENABLE_CHAT false
ENV BBB_REDIS_HOST redis
ENV BBB_REDIS_CHANNEL chat
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
ENV TZ Europe/Vienna
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY stream.py ./
COPY chat.py ./
COPY startStream.sh ./
COPY docker-entrypoint.sh ./
COPY nsswrapper.sh ./

ENTRYPOINT ["sh","docker-entrypoint.sh"]

CMD ["sh","startStream.sh" ]
USER 1001
