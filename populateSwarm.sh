docker network create monitoring --opt encrypted -d overlay 

## Create folder for storage, change the src name for ElasticSearch and Portainer if needed.
## Alternatively: docker volume create --name monitoring-volume
# mkdir -p /home/docker/ironswarm

## For multi-machine, setup dedicate box with storage then use a contraint. eg: --constraint node.hostname==myhostname 
## For storage: --mount "type=bind,src=/home/docker/ironswarm/,dst=/usr/share/elasticsearch/data,ro=false" \
docker service create -p 9200:9200 --network=monitoring \
  --mount "type=volume,dst=/usr/share/elasticsearch/data" \
  --name elasticsearch elasticsearch:5

## For multi-machine, setup dedicate box with storage then use a contraint. eg: --constraint node.hostname==myhostname 
## For storage: --mount "type=bind,src=/home/docker/ironswarm/,dst=/data,ro=false" \
docker service create \
    --name portainer \
    --publish 9000:9000 \
    --mount "type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock" \
    --mount "type=volume,dst=/data" \
    portainer/portainer --host=unix:///var/run/docker.sock

docker service create --network=monitoring --name kibana -e ELASTICSEARCH_URL="http://elasticsearch:9200" -p 5601:5601 -e LOGSPOUT=ignore kibana:5

docker service create --network=monitoring --mode global --name=logstash-syslog logstash-syslog

docker service create --network=monitoring --name logspout \
    --mode global \
    --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
    -e SYSLOG_FORMAT=rfc3164 \
    gliderlabs/logspout syslog://logstash-syslog:5000

docker service create --network=monitoring --mode global --name=metricbeat \
--mount "type=bind,source=/sys/fs/cgroup,target=/hostfs/sys/fs/cgroup,readonly=true" metricbeat-custom

## Testing. Remove me.
docker service create --network=monitoring --name=tester --replicas=1 alpine /bin/sh -c "while true; do echo My Message \$RANDOM; sleep 1; done;"
