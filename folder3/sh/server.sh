#!/bin/bash
sudo rm -f /etc/yum.repos.d/google-cloud.repo

sudo yum install mariadb mariadb-server -y
sudo /usr/bin/mysql_install_db --user=mysql
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm

sudo yum install zabbix-web-mysql-scl zabbix-apache-conf-scl -y
sudo yum install zabbix-server-mysql zabbix-agent centos-release-scl -y
export zabbix_db_pass="123"
mysql -uroot -p <<MYSQL_SCRIPT
    create database zabbix character set utf8 collate utf8_bin;
    grant all privileges on zabbix.* to zabbix@'localhost' identified by '${zabbix_db_pass}';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
sudo cp /tmp/sh/zabbix_server.conf /etc/zabbix/zabbix_server.conf
sudo cp /tmp/sh/zabbix.conf /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sudo yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl
sudo firewall-cmd --permanent --zone=public --add-port=10050/tcp
sudo firewall-cmd --permanent --zone=public --add-port=10051/tcp
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

sudo systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
sudo systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm
