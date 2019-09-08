echo "hello from mysql-setup.sh"

MYSQL_USER=admin
MYSQL_PASSWORD=admin
DBNAME=xwiki
DBUSER=xwiki
DBPASSWORD=xwiki

sudo yum -y update
sudo yum install -y wget
#sudo yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
sudo rpm -Uvh mysql57-community-release-el7-9.noarch.rpm

sudo yum install -y mysql-server

sudo systemctl start mysqld
sudo systemctl enable mysqld

password_match=`awk '/A temporary password is generated for/ {a=$0} END{ print a }' /var/log/mysqld.log | awk '{print $(NF)}'`

sudo mysql -u root -p$password_match --connect-expired-password<<-EOF
SET GLOBAL validate_password_policy=LOW;
SET GLOBAL validate_password_length = 4;
SET GLOBAL validate_password_number_count = 0;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
create database xwiki default character set utf8 collate utf8_bin;
CREATE USER 'xwiki'@'localhost' IDENTIFIED BY 'xwiki';
grant all privileges on xwiki.* to xwiki@192.168.1.10 identified by 'xwiki';
FLUSH PRIVILEGES;
EXIT
EOF

sudo cp /vagrant/webapps/config/my.cnf /etc/my.cnf
sudo systemctl restart mysqld 

sudo iptables -A INPUT -i eth0 -p tcp --destination-port 3306 -j ACCEPT