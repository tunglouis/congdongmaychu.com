#!/bin/bash

# overwrite ec2.env
echo "EC2_INSTANCEID=$(curl -sL http://169.254.169.254/latest/meta-data/instance-id)" > /etc/cloud/ec2.env
echo "EC2_REGION=$(curl -sL http://169.254.169.254/latest/meta-data/placement/availability-zone | head -c-1)" >> /etc/cloud/ec2.env

# overwrite ec2tags.env
source /etc/cloud/ec2.env
aws --region ${EC2_REGION} ec2 describe-tags --filter "Name=resource-id,Values=${EC2_INSTANCEID}" | jq 'reduce .Tags[] as $i ({}; . * {($i.Key): ($i.Value)})' > /etc/cloud/ec2tags.json
jq -r -e ". | to_entries[] | \"EC2TAG_\" + (.key | gsub(\"[^a-zA-Z0-9_]\"; \"_\") | ascii_upcase | @text) + \"=\" + (.value |@sh)" < /etc/cloud/ec2tags.json > /etc/cloud/ec2tags.env

if [ ! -s /etc/cloud/ec2.env ] || [ ! -s /etc/cloud/ec2tags.json ] || [ ! -s /etc/cloud/ec2tags.env ]; then
    exit 1
fi
