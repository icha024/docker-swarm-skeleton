FROM logstash:latest

ADD logstash-syslog.conf /config/logstash.conf
EXPOSE 5000
EXPOSE 5000/udp

#ADD logstash-gelf.conf /config/logstash.conf
#EXPOSE 12201/udp

CMD ["-f","/config/logstash.conf"] 
