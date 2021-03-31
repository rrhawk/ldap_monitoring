#!/bin/bash
sudo yum install tomcat -y
sudo yum install tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc -y
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo systemctl status tomcat
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

sudo cp /tmp/sh/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
sudo yum install --enablerepo=elasticsearch logstash -y
sudo systemctl start logstash.service
sudo systemctl enable logstash.service
sudo systemctl status logstash.service
IP_ES=$(cat /tmp/ip.txt)
sed -i "s|HOST|$IP_ES|g" /tmp/sh/input.yml
sudo cp /tmp/sh/input.yml /etc/logstash/conf.d/input.yml
sudo systemctl restart logstash.service
sudo yum install --enablerepo=elasticsearch filebeat -y
