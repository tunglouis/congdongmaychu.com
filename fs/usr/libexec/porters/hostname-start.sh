#!/bin/bash

source /etc/cloud/ec2tags.env

IP=$(curl -sL http://169.254.169.254/latest/meta-data/local-ipv4)
hostname=$(echo "${EC2TAG_NAME-unknown}${EC2TAG_VERSION+-}${EC2TAG_VERSION}-ip-${IP}" | tr '._' '--')

hostname $hostname

