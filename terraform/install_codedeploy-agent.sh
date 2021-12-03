#!/bin/bash -v
echo "userdata-start"
logfile=/var/log/install_agent.log
exec >> $logfile 2>&1

sudo yum -y update
sudo yum -y install ruby
sudo yum -y install wget
sudo yum -y install httpd
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
sudo service httpd start
echo "userdata-end"