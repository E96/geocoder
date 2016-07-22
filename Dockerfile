FROM devopsftw/baseimage
MAINTAINER Andrey Kolobov <andruha@e96.ru>

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ADD init/ /etc/my_init.d/

# consul
ADD consul.json /etc/consul/conf.d/

# nginx
RUN apt-get update -qq && apt-get install -y nginx
ADD nginx.sh /etc/service/nginx/run
ADD nginx/ /etc/nginx/

# node
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get install --no-install-recommends -y nodejs

# install app
ADD geocode.sh /etc/service/geocode/run
ADD https://github.com/dimik/geocode-tool/archive/master.zip /tmp/geocode-tool.zip
RUN unzip /tmp/geocode-tool.zip -d /
WORKDIR /geocode-tool-master
RUN npm install

# collectd
RUN apt-get install -y libcurl3 yajl-tools
ADD collectd/ /etc/collectd/
# upgrade collectd
RUN wget https://collectd.org/files/collectd-5.5.0.tar.gz && tar -xzvf collectd-5.5.0.tar.gz && cd collectd-5.5.0 && \
    ./configure && make all install && ln -sf /opt/collectd/sbin/collectd /usr/sbin/collectd

# cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80