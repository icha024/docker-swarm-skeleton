docker run -d --name elastic elasticsearch
docker run -d --name logstash --link elastic:elasticsearch -v /tmp/logstash.conf:/config-dir/logstash.conf logstash -f /config-dir/logstash.conf
docker run -d --name kibana --link elastic:elasticsearch -p 5601:5601 kibana
docker run --rm --log-driver=gelf --log-opt gelf-address=udp://$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' logstash):12201 --log-opt tag="test" alpine /bin/sh -c "while true; do echo My Message \$RANDOM; sleep 1; done;"


See: https://gist.github.com/shreyu86/735f2871460a2b068080


---
docker service create --replicas=1 --network=monitoring --name=logstash-gelf logstash-gelf
docker service create --replicas=1 --network=monitoring --name=couchdb --log-driver=gelf --log-opt gelf-address=udp://logstash-gelf:12201 --log-opt tag=gelf  klaemo/couchdb
