#!/bin/bash

sudo yum install openldap openldap-servers openldap-clients -y


sudo systemctl start slapd
sudo systemctl enable slapd
sudo systemctl status slapd
#sudo firewall-cmd --add-service=ldap
PASS1=123
PASS2=456
sudo slappasswd -s $PASS1 > /tmp/1.txt
sudo slappasswd -s $PASS2 > /tmp/2.txt
PASSWORD_ADMIN=$(cat /tmp/1.txt)
PASSWORD_USER=$(cat /tmp/2.txt)
#echo $PASSWORD_ADMIN
#echo $PASSWORD_USER
#sudo ssh-keygen -q -t rsa -N '' -f /tmp/id_rsa <<<y 2>&1 >/dev/null
#SSH_KEY=$(cat /tmp/id_rsa.pub)
#echo $SSH_KEY
sed -i "s|\${PASSWORD\}|$PASSWORD_ADMIN|g" /tmp/ldif/ldaprootpasswd.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/ldif/ldaprootpasswd.ldif
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/DB_CONFIG
sudo systemctl restart slapd
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f openssh-lpk.ldif
sed -i "s|\${PASSWORD\}|$PASSWORD_ADMIN|g" /tmp/ldif/ldapdomain.ldif
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/ldif/ldapdomain.ldif
sudo ldapadd -x -D "cn=Manager,dc=devopsldab,dc=com" -w $PASS1 -f /tmp/ldif/baseldapdomain.ldif
sudo ldapadd -x  -w $PASS1 -D "cn=Manager,dc=devopsldab,dc=com" -f /tmp/ldif/ldapgroup.ldif
sed -i "s|\$(cat pass)|$PASSWORD_USER|g" /tmp/ldif/ldapuser.ldif
#sed -i "$ a \sshPublicKey:$SSH_KEY" /tmp/ldif/ldapuser.ldif
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w $PASS1 -f  /tmp/ldif/ldapuser.ldif
