#!/bin/sh

if [ -f /conf/env ]; then
  . /conf/env
fi

if [ ! -e /conf/elasticsearch.* ]; then
  cp $ES_HOME/config/elasticsearch.yml /conf
fi

if [ ! -e /conf/logging.* ]; then
  cp $ES_HOME/config/logging.yml /conf
fi

OPTS="$OPTS -Des.path.conf=/conf \
  -Des.path.data=/data \
  -Des.path.logs=/data \
  -Des.script.inline=true \
  -Des.truescript.indexed=true \
  -Des.transport.tcp.port=9300 \
  -Des.http.port=9200"

if [ -n "$CLUSTER" ]; then
  OPTS="$OPTS -Des.cluster.name=$CLUSTER"
  if [ -n "$CLUSTER_FROM" ]; then
    if [ -d /data/$CLUSTER_FROM -a ! -d /data/$CLUSTER ]; then
      echo "Performing cluster data migration from $CLUSTER_FROM to $CLUSTER"
      mv /data/$CLUSTER_FROM /data/$CLUSTER
    fi
  fi
fi

if [ -n "$NODE_NAME" ]; then
  OPTS="$OPTS -Des.node.name=$NODE_NAME"
fi

if [ -n "$MULTICAST" ]; then
  OPTS="$OPTS -Des.discovery.zen.ping.multicast.enabled=$MULTICAST"
fi

if [ -n "$UNICAST_HOSTS" ]; then
  OPTS="$OPTS -Des.discovery.zen.ping.unicast.hosts=$UNICAST_HOSTS"
fi

if [ -n "$PUBLISH_AS" ]; then
  OPTS="$OPTS -Des.transport.publish_host=$(echo $PUBLISH_AS | awk -F: '{print $1}')"
  OPTS="$OPTS -Des.transport.publish_port=$(echo $PUBLISH_AS | awk -F: '{if ($2) print $2; else print 9300}')"
fi

if [ -n "$PLUGINS" ]; then
  for p in $(echo $PLUGINS | awk -v RS=, '{print}')
  do
    echo "Installing the plugin $p"
    $ES_HOME/bin/plugin install $p
  done
fi

echo "Starting Elasticsearch with the options $OPTS"
$ES_HOME/bin/elasticsearch $OPTS
