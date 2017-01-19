FROM athieriot/metricbeat:5.1.1

ADD metricbeat.yml /metricbeat/metricbeat.yml

ENV ELASTICSEARCH_URL http://elasticsearch:9200

CMD /metricbeat/start.sh