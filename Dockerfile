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
RUN add-apt-repository -y ppa:collectd/collectd-5.5
RUN apt-get update -qq && apt-get install -o Dpkg::Options::="--force-confnew" -y libcurl3 yajl-tools collectd-core
ADD collectd/ /etc/collectd/
RUN touch /etc/collectd/types.db

# cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80