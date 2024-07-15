#!/usr/bin/env bash

#
# Demo, it would be better to produce and AMI with Packer/EC2 Image Builder etc.
#

apt update
apt upgrade -y
apt install nginx -y
systemctl enable nginx
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb
echo ${cloudwatch_config_base64} | base64 --decode >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
