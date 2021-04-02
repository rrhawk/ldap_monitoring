#!/bin/bash
sudo rm -f /etc/yum.repos.d/google-cloud.repo
sudo yum install tomcat -y
sudo yum install tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc -y
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo systemctl status tomcat
sudo chown -R tomcat:tomcat /var/log/tomcat
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

sudo cp /tmp/sh/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
sudo yum install --enablerepo=elasticsearch logstash -y
sudo usermod -a -G tomcat logstash
sudo systemctl start logstash.service
sudo systemctl enable logstash.service
sudo systemctl status logstash.service
IP_ES=$(cat /tmp/ip.txt)
sed -i "s|HOST|$IP_ES|g" /tmp/sh/es.conf
sudo cp /tmp/sh/es.conf /etc/logstash/conf.d/es.conf
sudo systemctl restart logstash.service
sudo cp /tmp/sh/clusterjsp.war /usr/share/tomcat/webapps
