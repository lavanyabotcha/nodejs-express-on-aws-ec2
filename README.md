# nodejs-express-on-aws-ec2

EC2 script on creation to install the CodeDeploy Agent:

#!/bin/bash
sudo yum -y update
sudo yum -y install ruby
sudo yum -y install wget
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto

Check if CodeDeploy Agent is running

sudo service codedeploy-agent status
