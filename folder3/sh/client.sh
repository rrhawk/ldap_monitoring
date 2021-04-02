#!/bin/bash
sudo rm -f /etc/yum.repos.d/google-cloud.repo
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum install zabbix-agent -y
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
sudo firewall-cmd --permanent --zone=public --add-port=10050/tcp
sudo firewall-cmd --permanent --zone=public --add-port=10051/tcp
sudo firewall-cmd --reload
