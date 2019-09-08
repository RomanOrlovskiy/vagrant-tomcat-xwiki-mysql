
TOMCAT_VERSION="8.5.37"

# Installing Oracle Java JDK 8
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

# Add Tomcat user
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Download Tomcat

#DRAFT
#cd /home/vagrant
cd /vagrant/webapps

sudo apt-get -y install curl
#curl -O --progress-bar http://mirrors.ibiblio.org/apache/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.gz

# Extract into target directory

sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1

# Assign ownership over target directory
cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/

# Copy basic Tomcat configuration files
cd /vagrant
sudo cp webapps/config/context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
sudo cp webapps/config/context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo cp webapps/config/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml

# Copy service file and reload daemon
sudo cp webapps/config/tomcat.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start tomcat #runs properly till here, then tomcat is not starting correctly
sudo systemctl enable tomcat
#sudo ufw --force enable
sudo ufw allow 8080

# Donwnload and Install XWiki

#DRAFT
cd /vagrant/webapps #&& wget http://download.forge.ow2.org/xwiki/xwiki-enterprise-web-8.4.6.war

#sudo mv xwiki-enterprise-web-8.4.6.war /opt/tomcat/webapps/xwiki.war

sudo cp xwiki-enterprise-web-8.4.6.war /opt/tomcat/webapps/xwiki.war
sudo chown tomcat:tomcat /opt/tomcat/webapps/xwiki.war
sudo systemctl restart tomcat

sleep 30

#DRAFT
#JDBC driver should be inside xwiki war file
#curl -o mysql-connector-java-5.1.28.tar.gz -L 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.28.tar.gz/from/http://cdn.mysql.com/'

#sudo tar xzvf mysql-connector-java-5.1.28.tar.gz

cd /vagrant/webapps && sudo cp mysql-connector-java-5.1.28/mysql-connector-java-5.1.28-bin.jar /opt/tomcat/webapps/xwiki/WEB-INF/lib/ 

sudo chown tomcat:tomcat /opt/tomcat/webapps/xwiki/WEB-INF/lib/mysql-connector-java-5.1.28-bin.jar

#Configure database connection
sudo cp /vagrant/webapps/config/hibernate.cfg.xml /opt/tomcat/webapps/xwiki/WEB-INF/hibernate.cfg.xml

sudo systemctl restart tomcat