FROM ubuntu:24.04
RUN apt-get update -q
RUN apt-get -y install rsyslog ca-certificates
RUN apt-get install nginx -y
CMD rsyslogd -n