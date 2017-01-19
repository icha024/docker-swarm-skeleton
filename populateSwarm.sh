docker network create monitoring -d overlay

## For multi-machine, setup dedicate box with storage then use a contraint. eg: --constraint node.hostname==worker1 
docker service create -p 9200:9200 --network=monitoring \
  --mount type=volume,target=/usr/share/elasticsearch/data \
  --name elasticsearch elasticsearch:5

docker service create --network=monitoring --name kibana -e ELASTICSEARCH_URL="http://elasticsearch:9200" -p 5601:5601 -e LOGSPOUT=ignore kibana:5

docker service create --network=monitoring --mode global --name=logstash-syslog logstash-syslog

docker service create --network=monitoring --name logspout \
    --mode global \
    --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
    -e SYSLOG_FORMAT=rfc3164 \
    gliderlabs/logspout syslog://logstash-syslog:5000

docker service create --network=monitoring --mode global --name=metricbeat \
--mount "type=bind,source=/sys/fs/cgroup,target=/hostfs/sys/fs/cgroup,readonly=true" metricbeat-custom

## Test: docker run --rm --log-driver=gelf --log-opt gelf-address=udp://$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' logstash):12201 --log-opt tag="test" alpine /bin/sh -c "while true; do echo My Message \$RANDOM; sleep 1; done;"
docker service create --network=monitoring --name=tester --replicas=1 alpine /bin/sh -c "while true; do echo My Message \$RANDOM; sleep 1; done;"
