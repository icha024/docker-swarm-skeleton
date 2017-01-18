# https://blog.codeship.com/monitoring-docker-containers-with-elasticsearch-and-cadvisor/
docker network create monitoring -d overlay

docker service create -p 9200:9200 --network=monitoring \
  --mount type=volume,target=/usr/share/elasticsearch/data \
  --name elasticsearch elasticsearch:2.4.0

docker service create --network=monitoring --name kibana -e ELASTICSEARCH_URL="http://elasticsearch:9200" -p 5601:5601 kibana:4.6.0

docker service create --network=monitoring --mode global --name cadvisor \
  --mount type=bind,source=/,target=/rootfs,readonly=true \
  --mount type=bind,source=/var/run,target=/var/run,readonly=false \
  --mount type=bind,source=/sys,target=/sys,readonly=true \
  --mount type=bind,source=/var/lib/docker/,target=/var/lib/docker,readonly=true \
  google/cadvisor:latest \
  -storage_driver=elasticsearch \
  -storage_driver_es_host="http://elasticsearch:9200"

#docker service create --network=monitoring --replicas=1 --name=logstash-gelf logstash-gelf
docker service create --network=monitoring --replicas=1 --name=logstash-syslog logstash-syslog

docker service create --network=monitoring --name logspout \
    --mode global \
    --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
    -e SYSLOG_FORMAT=rfc3164 \
    gliderlabs/logspout syslog://logstash-syslog:5000

## Test: docker run --rm --log-driver=gelf --log-opt gelf-address=udp://$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' logstash):12201 --log-opt tag="test" alpine /bin/sh -c "while true; do echo My Message \$RANDOM; sleep 1; done;"
docker service create --network=monitoring --replicas=1 alpine /bin/sh -c "while true; do echo My Message \$RANDOM; sleep 1; done;"

