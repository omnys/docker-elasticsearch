FROM java:openjdk-8u72-jdk

MAINTAINER Omnys srl <sistemi@omnys.com>

ENV ES_VERSION 2.2.2
ENV ES_HOME /usr/share/elasticsearch-$ES_VERSION
ENV OPTS=-Dnetwork.host=_non_loopback_

RUN wget -qO /tmp/es.tgz https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.tar.gz && \
  cd /usr/share && \
  tar xf /tmp/es.tgz && \
  /usr/share/elasticsearch-$ES_VERSION/bin/plugin install mobz/elasticsearch-head && \
  rm /tmp/es.tgz && \
  useradd -d $ES_HOME -M -r elasticsearch && \
  chown -R elasticsearch: $ES_HOME && \
  mkdir /data /conf && \
  touch /data/.CREATED /conf/.CREATED && \
  chown -R elasticsearch: /data /conf

VOLUME ["/data","/conf"]

ADD start.sh /start.sh

RUN chmod +x /start.sh

WORKDIR $ES_HOME
USER elasticsearch

EXPOSE 9200 9300

CMD ["/start.sh"]
