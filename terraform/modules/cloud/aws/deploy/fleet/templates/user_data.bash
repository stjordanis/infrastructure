#!/bin/bash

#SETTING UP HOSTNAME

REGION="{{ region }}"
IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
echo "aws-$REGION-$IP" > /etc/hostname
hostname "aws-$REGION-$IP"

#GET DATADOG

#WIP

#INSTALL EPOCH

VERSION="0.16.0"

FILE="epoch-$VERSION-ubuntu-x86_64.tar.gz"
URL="https://github.com/aeternity/epoch/releases/download/v$VERSION/$FILE"

wget -q $URL -o /home/epoch/$FILE

chown epoch:epoch /home/epoch/$FILE
sudo su -c "tar -xvf /home/epoch/$FILE" epoch
sudo su -c "/home/epoch/bin/epoch start" epoch
