# Iron Swarm: Opinionated Docker Swarm Platform Setup

- Setup ELK (Elasticsearch + Logstash + Kibana)
- Setup stdout/err forwarding from all container to ELK (Logspout)
- Setup systems monitoring metics and dashboard on ELK (MetricBeat)
- Setup dashboard for Docker container visualisation (Portainer)

## Setup
1. Start your master swarm node (host IP must be reachable from other other nodes, ie. Use network IP instead of localhost):
  `docker swarm init --advertise-host=<host IP>`

2. Clone this repo then run the setup script:
  `sh populateSwarm.sh`

3. (Optional) Start other Swarm workers/managers to form the cluster. ie. copy/paste the command + token from master node and run it on other nodes.

4. Admire the consoles:
  - Kibana (ELK): `http://<your IP>:5601`
  - Portainer: `http://<your IP>:9000`

## Tweak for multiple hosts
The ElasticSearch and Portainer uses a temporary local volume by default.
On prod/multi-host setup, the storage will need to be contrainted to specific hosts with storage available. Edit the script and uncomment the associated lines fo this.

## Import MetricBeat's Kibana dashboard
Docker Swarm, as at Jan 2017, does not support one-off short task. A workaround is to start a service to setup dashboard then remove the service afterwards.

### Load sample metric dashboards
`docker service create --network=monitoring --name=load-dashboards --replicas=1 athieriot/metricbeat /bin/sh -c "./scripts/import_dashboards -es http://elasticsearch:9200 && while true; do sleep 60; done;"`

It should show up in Kibana after a minute, check: `Dashboard -> Open -> MetricBeat-Overview`

### Clean up dashboard load script
`docker service rm load-dashboards`

## TODO:
- Push images with custom config to DockerHub
- Authentications
