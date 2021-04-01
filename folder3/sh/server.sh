#!/bin/bash
sudo rm -f /etc/yum.repos.d/google-cloud.repo
#sudo setenforce 0
#sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

#sudo yum install mariadb mariadb-server -y
#sudo /usr/bin/mysql_install_db --user=mysql
#sudo systemctl start mariadb
#sudo systemctl enable mariadb
#sudo systemctl status mariadb
#export zabbix_db_pass="zabbix"
#mysql -uroot -p <<MYSQL_SCRIPT
#    create database zabbix character set utf8 collate utf8_bin;
#    grant all privileges on zabbix.* to zabbix@'localhost' identified by '${zabbix_db_pass}';
#    FLUSH PRIVILEGES;
#MYSQL_SCRIPT
#sudo yum install -y https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
#sudo yum install zabbix-server-mysql zabbix-agent zabbix-get -y
#sudo yum-config-manager --enable zabbix-frontend
#sudo yum -y install centos-release-scl
#sudo yum -y install zabbix-web-mysql-scl zabbix-apache-conf-scl
#sudo su -
#sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
