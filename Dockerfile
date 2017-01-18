FROM logstash:latest

ADD logstash-gelf.conf /config/logstash.conf
EXPOSE 12201/udp

CMD ["-f","/config/logstash.conf"] 
