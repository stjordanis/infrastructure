#!/bin/bash
set -x
exec > >(tee /tmp/user-data.log|logger -t user-data ) 2>&1

#SETTING UP HOSTNAME

REGION="${region}"
IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
echo "aws-$REGION-$IP" > /etc/hostname
hostname "aws-$REGION-$IP"

#SETUP DATADOG
apt-get update
apt-get install awscli -y

DATADOG_API_KEY_ENCRYPTED="${datadog_api_key}"
echo "$DATADOG_API_KEY_ENCRYPTED" | base64 --decode > /tmp/datadog_api_key_encrypted


DATADOG_API_KEY=`aws --region eu-west-1 kms decrypt --ciphertext-blob fileb:///tmp/datadog_api_key_encrypted --output text --query Plaintext | base64 --decode`

sed -i -- "s/DATADOG_API_KEY/$DATADOG_API_KEY/g" /etc/datadog-agent/datadog.yaml

sed -i -- "s/region:unknown/region:${region}/g" /etc/datadog-agent/datadog.yaml
sed -i -- "s/color:unknown/color:${color}/g" /etc/datadog-agent/datadog.yaml
sed -i -- "s/env:unknown/env:${env}/g" /etc/datadog-agent/datadog.yaml
#INSTALL EPOCH

VERSION="0.16.0"

FILE="epoch-$VERSION-ubuntu-x86_64.tar.gz"
URL="https://github.com/aeternity/epoch/releases/download/v$VERSION/$FILE"

wget -q $URL -O /home/epoch/$FILE

mkdir /home/epoch/node
tar -xvf /home/epoch/$FILE -C /home/epoch/node
chown -R epoch:epoch /home/epoch/node
#START EPOCH & DATADOG
sudo su -c "/home/epoch/node/bin/epoch start" epoch
sudo service datadog-agent start
