# Iron Swarm: Opinionated Docker Swarm Platform Setup

- Script to setup ELK
- Forwards all container's stdout/err to ELK (logspout)
- Setup systems monitoring metics on ELK (metricbeat)

## Loading Kibana metric dashboard
Docker Swarm, as at Jan 2017, does not support one-off short task. A workaround is to start a service to setup dashboard then remove the service afterwards.
### Load sample metric dashboards
`docker service create --network=monitoring --name=load-dashboards --replicas=1 athieriot/metricbeat /bin/sh -c "./scripts/import_dashboards -es http://elasticsearch:9200 && while true; do sleep 60; done;"`

### Clean up once loaded
`docker service rm load-dashboards`
