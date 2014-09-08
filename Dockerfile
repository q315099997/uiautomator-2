FROM cocoon/python
MAINTAINER cocoon 


# install uiautomator wrapper
RUN pip install uiautomator


# install adb from android tools
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /tmp/android 
WORKDIR /tmp/android
RUN apt-get update
RUN apt-get -y install build-essential
RUN echo "deb-src http://debian.ens-cachan.fr/ftp/debian/ sid main contrib non-free" > /etc/apt/sources.list.d/sid-sources.list
RUN apt-get update
RUN apt-get -y build-dep android-tools
RUN apt-get source --build android-tools
RUN rm /etc/apt/sources.list.d/sid-sources.list


RUN dpkg -i android-tools-*.deb


# Set up insecure default key
RUN mkdir -m 0750 /.android
ADD files/insecure_shared_adbkey /.android/adbkey
ADD files/insecure_shared_adbkey.pub /.android/adbkey.pub


# Clean up
WORKDIR /tmp
RUN rm -rf /tmp/android
RUN apt-get -y --purge remove build-essential && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/cache/apt/*

# Expose default ADB port
EXPOSE 5037

# Start the server by default. This needs to run in a shell or Ctrl+C won't
# work.
CMD /usr/bin/adb -a -P 5037 fork-server server

