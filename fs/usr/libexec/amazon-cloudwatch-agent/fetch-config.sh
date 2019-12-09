#!/bin/bash

source /etc/cloud/ec2.env
source /etc/cloud/ec2tags.env

if [ -z "$EC2_INSTANCEID" ] || [ -z "$EC2_REGION" ]; then
    exit 1
fi

temp=$(mktemp)
temp2=$(mktemp)

AgentConfigName=${EC2TAG_NAME:-default}
for config in Base $(sed -r 's/(^|-)(\w)/\U\2/g' <<<"${AgentConfigName}"); do
    aws --region ${EC2_REGION} ssm get-parameter --name /CloudWatchAgent/$config 2>/dev/null> $temp \
        && jq -r .Parameter.Value < $temp | jq -n -c -f /dev/stdin --argjson ec2tags "$(cat /etc/cloud/ec2tags.json)" >> $temp2

    rm -f $temp
done

[ -z "$temp2" ] && exit 1

jq -n --slurpfile configs $temp2 'reduce $configs[] as $config ({}; . * $config)' > $temp

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -c file:$temp

rm -f $temp $temp2
