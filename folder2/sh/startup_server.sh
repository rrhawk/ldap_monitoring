#!/bin/bash
sudo rm -f /etc/yum.repos.d/google-cloud.repo
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

sudo cp /tmp/sh/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

sudo yum install --enablerepo=elasticsearch elasticsearch -y
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
sudo systemctl status elasticsearch.service
sudo sed -i '$ a \network.host: "0.0.0.0"' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '$ a \discovery.seed_hosts: ["127.0.0.1", "[::1]"]' /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch.service
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

sudo cp /tmp/sh/kibana.repo /etc/yum.repos.d/kibana.repo

sudo yum install kibana -y

sudo systemctl daemon-reload
sudo systemctl enable kibana.service
sudo systemctl start kibana.service
sudo systemctl status kibana.service
sudo firewall-cmd --permanent --zone=public --add-port=5601/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9200/tcp
sudo firewall-cmd --reload
sudo sed -i '$ a \server.host: "0.0.0.0"' /etc/kibana/kibana.yml
sudo systemctl restart kibana.service
