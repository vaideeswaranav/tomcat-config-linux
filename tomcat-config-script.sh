#!/bin/bash

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'

printf "\n${BLUE}Initiating the installation and configuration of Tomcat9...${WHITE}"

#Updating System
printf "\n${GREEN}Updating your system..."
printf '\n\033[41;32m%s\033[0m\n' "NOTE: Press Enter, if you are prompted to restart the services."

sudo apt update -y
sudo apt upgrade -y

# Installing Default JDK
printf "\n${GREEN}Installing Default JDK...${WHITE}\n"
sudo apt install default-jdk -y
printf "\n${GREEN}Checking Java Runtime Environment version...${WHITE}\n"
java -version
printf "\n${GREEN}Checking Java compiler version...${WHITE}\n"
javac -version

# Adding an unprivileged user to run tomcat under it
printf "\n${GREEN}Adding tomcat user...${WHITE}\n"
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Downloading Tomcat 9
cd /tmp
printf "\n${GREEN}Downloading Tomcat 9...${WHITE}\n"
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz
printf "\n${GREEN}Extracting tomcat files...${WHITE}\n"
sudo tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1

# Grating permission to the user tomcat
sudo chown -R tomcat:tomcat /opt/tomcat

# Fetching JAVA_HOME path
read -r JAVA_HOME _ < <(sudo update-java-alternatives -l | awk '{print $3}')

# Creating & configuring the Tomcat service file
printf "\n${GREEN}Configuring the tomcat service...${WHITE}\n"
cd /etc/systemd/system
echo > tomcat.service
printf "[Unit]\nDescription=Tomcat\nAfter=network.target\n
[Service]\nType=forking\n\nUser=tomcat\nGroup=tomcat\n
Environment=\"JAVA_HOME=$JAVA_HOME\"
Environment=\"JAVA_OPTS=-Djava.security.egd=file:///dev/urandom\"
Environment=\"CATALINA_BASE=/opt/tomcat\"
Environment=\"CATALINA_HOME=/opt/tomcat\"
Environment=\"CATALINA_PID=/opt/tomcat/temp/tomcat.pid\"
Environment=\"CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC\"\n
ExecStart=/opt/tomcat/bin/startup.sh
ExceStop=/opt/tomcat/bin/shutdown.sh\n
RestartSec=10
Restart=always\n
[Install]\nWantedBy=multi-user.target" > tomcat.service

#Starting the tomcat service
printf "\n${GREEN}Starting the tomcat service...${WHITE}"
sudo systemctl daemon-reload
sudo systemctl start tomcat
printf '\n\033[41;32m%s\033[0m\n' "NOTE: Press Q to continue."
printf "\n${GREEN}Tomcat service status:${WHITE}\n"
sudo systemctl status tomcat

#Enabling tomcat service & allowing port 8080
printf "\n${GREEN}Enabling the tomcat service...${WHITE}\n"
sudo systemctl enable tomcat
printf "\n${GREEN}Allowing port 8080...${WHITE}\n"
sudo ufw allow 8080
printf "\n${GREEN}Installation & Configuration of Tomcat9 has been completed.${WHITE}\n"
printf "*** EOL ***\n"